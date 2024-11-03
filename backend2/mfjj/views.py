from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
import json
from django.utils import timezone
from datetime import timedelta
from .haversine import haversine
from .models import Location, UserProfile, Friendship
from .gpt_wrapper import call_gpt
# Create your views here.
@csrf_exempt
def post_location(request):
    if not request.user.is_authenticated:
        return JsonResponse({"error": "Please login"}, status=401)

    if request.method == "POST":
        data = json.loads(request.body) 
        #user_id = data.get("user_id")
        latitude = data.get("latitude")
        longitude = data.get("longitude")

        location = Location(user_id=request.user.id, latitude = latitude, longitude=longitude)
        location.save()
        return JsonResponse({"message": "Location added succesfully!"}, status=201)
    return JsonResponse({"error": "Invalid request method"}, status=400)

def get_users(request):
    if request.method == "GET":
        if not request.user.is_authenticated:
            return JsonResponse({"error": "Please login"}, status=401)
        if not UserProfile.objects.filter(user_profile=request.user).exists():
            return JsonResponse({"error": "Please create a profile first"}, status=401)
        # max distance is 0.1km
        MAX_DISTANCE = 0.1
        # get the user
        user_id = request.user.id

        # Calculate the time 24 hours ago from now
        time_threshold = timezone.now() - timedelta(days=1)


        # Get the user's locations from the past 24 hours
        try:
            user_locations = Location.objects.filter(user_id=user_id, created_at__gte=time_threshold)
        except Location.DoesNotExist:
            return JsonResponse({"error": "User not found."}, status=404)

        nearby_users = []
        user_lat = user_long = None
        seen_usernames = set()  # To track added usernames

        # add the current user as the first person in the nearby users array
        current_userprofile = UserProfile.objects.get(user_profile=request.user)
        nearby_users.append({
            "username": request.user.username,
            "interest1": current_userprofile.interest1,
            "interest2": current_userprofile.interest2,
            "interest3": current_userprofile.interest3,
            "school": current_userprofile.school,
            "major": current_userprofile.major,
            "hometown": current_userprofile.hometown
        })
        for user_location in user_locations:
            user_lat = user_location.latitude
            user_long = user_location.longitude

            # Find all nearby users excluding the logged-in user
            locations = Location.objects.exclude(user_id=user_id).filter(created_at__gte=time_threshold)

            for location in locations:
                distance = haversine(user_lat, user_long, location.latitude, location.longitude)
                # Get nearby users only
                if distance <= MAX_DISTANCE:
                    if location.user.username not in seen_usernames:
                        seen_usernames.add(location.user.username)
                        try:
                            nearby_userprofile = UserProfile.objects.get(user_profile=location.user)
                            nearby_users.append({
                                "username": location.user.username,
                                "interest1": nearby_userprofile.interest1,
                                "interest2": nearby_userprofile.interest2,
                                "interest3": nearby_userprofile.interest3,
                                "school": nearby_userprofile.school,
                                "major": nearby_userprofile.major,
                                "hometown": nearby_userprofile.hometown
                            })
                        except UserProfile.DoesNotExist:
                            # the user does not have a profile!
                            continue

        # enrich the GPT response with more information                
        gpt_response = call_gpt(nearby_users)
        # Assuming gpt_response already has the recommendations
        filtered_recommendations = []

        for recommendation in gpt_response["recommendations"]:
            # Skip the current user
            if recommendation["person"] == current_userprofile.user_profile.username:
                continue

            # Fetch the user profile info
            nearby_user_profile = UserProfile.objects.filter(user_profile=User.objects.get(username = recommendation["person"])).first()

            # Create the new recommendation entry
            enriched_recommendation = {
                "person": recommendation["person"],
                "reason": recommendation["reason"],
                "school": nearby_user_profile.school if nearby_user_profile else None,
                "major": nearby_user_profile.major if nearby_user_profile else None,
                "hometown": nearby_user_profile.hometown if nearby_user_profile else None,
            }


            # Add to the filtered list
            filtered_recommendations.append(enriched_recommendation)

        # Update the recommendations in the original response
        gpt_response["recommendations"] = filtered_recommendations
        
        if gpt_response == 404:
            return JsonResponse({"error": "Try again."}, status=500)
        else:
            return JsonResponse(gpt_response, status=200)

    return JsonResponse({"error": "Invalid request method."}, status=405)

@csrf_exempt
def post_profile(request):
    if not request.user.is_authenticated:
        return JsonResponse({"error": "Please login"}, status=401)

    if request.method == "POST":
        data = json.loads(request.body)
        interest1 = data.get("interest1")
        interest2 = data.get("interest2")
        interest3 = data.get("interest3")
        links = data.get("links")
        school = data.get("school")
        major = data.get("major")
        hometown = data.get("hometown")

        if not interest1 or not interest2 or not interest3 or not links or not school or not major or not hometown:
            return JsonResponse({"error": "One or more fields are missing."}, status=400)

        profile, created = UserProfile.objects.update_or_create(
            user_profile=request.user,  # Filter by the current user
            defaults={
                'interest1': interest1,
                'interest2': interest2,
                'interest3': interest3,
                'links': links,
                'school': school,
                'major': major,
                'hometown': hometown
            }
        )
        if created:
            return JsonResponse({"message": "Profile created successfully!"}, status=201)
        else:
            return JsonResponse({"message": "Profile updated successfully!"}, status=200)

    return JsonResponse({"error": "Invalid request method"}, status=400)
@csrf_exempt
def post_friends(request):
    if not request.user.is_authenticated:
        return JsonResponse({"error": "Please login"}, status=401)

    if request.method == "POST":
        data = json.loads(request.body)
        friend_username = data.get("friend_username")

        try:
            friend = User.objects.get(username=friend_username)
        except User.DoesNotExist:
            return JsonResponse({"error": "User does not exist"}, status=404)

        Friendship.objects.get_or_create(user=request.user, friend=friend)

        return JsonResponse({"message": "Friend added succesfully!"}, status=201)
    return JsonResponse({"error": "Invalid request method"}, status=400)


##### AUTH
@csrf_exempt
def signup(request):
    if request.method == "POST":
        try:
            data = json.loads(request.body)
            username = data.get('username')
            password = data.get('password')

            if not username or not password:
                return JsonResponse({"error": "Username and password are required."}, status=400)

            if User.objects.filter(username=username).exists():
                return JsonResponse({"error": "Username already taken."}, status=400)

            user = User(username=username)
            user.set_password(password)  # Hash the password
            user.save()

            return JsonResponse({"message": "User created successfully!"}, status=201)

        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format."}, status=400)

        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)
    return JsonResponse({"error": "Invalid request method"}, status=400)

@csrf_exempt
def login_view(request):
    try:
        data = json.loads(request.body)
        username = data.get('username')
        password = data.get('password')

        if not username or not password:
            return JsonResponse({"error": "Username and password are required."}, status=400)

        user = authenticate(request, username=username, password=password)
        if user is not None:
            login(request, user)
            return JsonResponse({"message": "Login successful!"}, status=200)
        else:
            return JsonResponse({"error": "Invalid credentials."}, status=401)

    except json.JSONDecodeError:
        return JsonResponse({"error": "Invalid JSON format."}, status=400)

    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)


@csrf_exempt
def logout_view(request):
    try:
        logout(request)
        return JsonResponse({"message": "Logout successful!"}, status=200)
    except Exception as e:
        return JsonResponse({"error": str(e)}, status=500)
