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
    if request.method == "POST":
        # make sure the user is authenticated before posting a location
        if not request.user.is_authenticated:
            return JsonResponse({"error": "Please login"}, status=401)
        # extract the data from the json request body
        data = json.loads(request.body) 
        #user_id = data.get("user_id")
        latitude = data.get("latitude")
        longitude = data.get("longitude")

        # create a new entry in the location table with the appropriate user data
        location = Location(user_id=request.user.id, latitude = latitude, longitude=longitude)
        location.save()
        # inform client that location was added successfully
        return JsonResponse({"message": "Location added succesfully!"}, status=201)
    # there request method was invalid, i.e, not a POST method
    return JsonResponse({"error": "Invalid request method"}, status=400)

def get_users(request):
    if request.method == "GET":
        # ensure user is authenticated and a user profile exists
        if not request.user.is_authenticated:
            return JsonResponse({"error": "Please login"}, status=401)
        if not UserProfile.objects.filter(user_profile=request.user).exists():
            return JsonResponse({"error": "Please create a profile first"}, status=401)
        
        # max distance is 0.1km, i.e, the max distance between two users to ping!
        MAX_DISTANCE = 0.1

        # get the current
        user_id = request.user.id

        # Calculate the time 24 hours ago from now
        time_threshold = timezone.now() - timedelta(days=1)


        # Get the user's locations from the past 24 hours
        try:
            user_locations = Location.objects.filter(user_id=user_id, created_at__gte=time_threshold)
        except Location.DoesNotExist:
            return JsonResponse({"error": "User not found."}, status=404)

        # make a list of nearby users, and storing seen users in a set thus, O(1) to not add duplicate users
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

        # for each location that the user has been in, find all the other users that have been by this user
        for user_location in user_locations:
            user_lat = user_location.latitude
            user_long = user_location.longitude

            # Find all nearby users excluding the logged-in user
            locations = Location.objects.exclude(user_id=user_id).filter(created_at__gte=time_threshold)

            # for all the locations of nearby users, if the locations are within the MAX_DISTANCE, mark them as being close to each other
            for location in locations:
                distance = haversine(user_lat, user_long, location.latitude, location.longitude)
                # Get nearby users only
                if distance <= MAX_DISTANCE:
                    # O(1) to check for duplicate user
                    if location.user.username not in seen_usernames:
                        seen_usernames.add(location.user.username)
                        try:
                            # get the user that was close to our current logged in user, and their respective information
                            nearby_userprofile = UserProfile.objects.get(user_profile=location.user)
                            nearby_users.append({
                                "username": location.user.username,
                                "interest1": nearby_userprofile.interest1,
                                "interest2": nearby_userprofile.interest2,
                                "interest3": nearby_userprofile.interest3,
                                "school": nearby_userprofile.school,
                                "major": nearby_userprofile.major,
                                "hometown": nearby_userprofile.hometown,
                                "latitude": location.latitude,
                                "longitude": location.longitude
                            })
                        except UserProfile.DoesNotExist:
                            # the user does not have a profile!
                            continue

        # call ChatGPT to find out the similarities between the two users, ChatGPT will decide if a user and the people 
        # they pinged near have many similarities. If so, ChatGPT will decide how they are similar, and match them together.          
        gpt_response = call_gpt(nearby_users)
        # setup a new list to hold enriched recomendations
        filtered_recommendations = []

        # for each recomendation in the GPT response
        for recommendation in gpt_response["recommendations"]:
            # Skip the current user
            if recommendation["person"] == current_userprofile.user_profile.username:
                continue

            # Fetch the user profile info
            nearby_user_profile = UserProfile.objects.filter(user_profile=User.objects.get(username = recommendation["person"])).first()

            # Create the new recommendation entry with enriched data entries from the nearby_user_profile
            enriched_recommendation = {
                "person": recommendation["person"],
                "reason": recommendation["reason"],
                "school": nearby_user_profile.school if nearby_user_profile else None,
                "major": nearby_user_profile.major if nearby_user_profile else None,
                "hometown": nearby_user_profile.hometown if nearby_user_profile else None,
                "latitude": recommendation["latitude"],
                "longitude": recommendation["longitude"]
            }


            # Add to the filtered list
            filtered_recommendations.append(enriched_recommendation)

        # Update the recommendations in the original response
        gpt_response["recommendations"] = filtered_recommendations
        
        # check if GPT responded with a 500, means 
        if gpt_response == 404:
            return JsonResponse({"error": "Try again."}, status=500)
        else:
            return JsonResponse(gpt_response, status=200)

    return JsonResponse({"error": "Invalid request method."}, status=405)

@csrf_exempt
def post_profile(request):
    # make sure the request is a post request
    if request.method == "POST":
        # make sure the user is authenticated before creating a profile
        if not request.user.is_authenticated:
            return JsonResponse({"error": "Please login"}, status=401)
        
        # check the client data from the post request body
        data = json.loads(request.body)
        interest1 = data.get("interest1")
        interest2 = data.get("interest2")
        interest3 = data.get("interest3")
        links = data.get("links")
        school = data.get("school")
        major = data.get("major")
        hometown = data.get("hometown")

        # if any of these data entries are empty, then send back to client that they cannot be empty
        if not interest1 or not interest2 or not interest3 or not links or not school or not major or not hometown:
            return JsonResponse({"error": "One or more fields are missing."}, status=400)

        # create a new profile or update the existing one
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
        # respond for successful / unsuccessful profile creations!
        if created:
            return JsonResponse({"message": "Profile created successfully!"}, status=201)
        else:
            return JsonResponse({"message": "Profile updated successfully!"}, status=200)

    return JsonResponse({"error": "Invalid request method"}, status=400)
@csrf_exempt
def post_friends(request):
    if request.method == "POST":
        # make sure the user is authenticateed
        if not request.user.is_authenticated:
            return JsonResponse({"error": "Please login"}, status=401)
        
        # extract the data from the client request body
        data = json.loads(request.body)
        friend_username = data.get("username")

        # get the user that the current user wants to add as a friend
        try:
            friend = User.objects.get(username=friend_username)
        except User.DoesNotExist:
            return JsonResponse({"error": "User does not exist"}, status=404)

        # create the new friendship entry in the database
        Friendship.objects.get_or_create(user=request.user, friend=friend)

        # respond with a successful or unsucessful json response
        return JsonResponse({"message": "Friend added succesfully!"}, status=201)
    return JsonResponse({"error": "Invalid request method"}, status=400)


@csrf_exempt
def get_friends(request):
    if not request.user.is_authenticated:
        return JsonResponse({"error": "Please login"}, status=401)

    if request.method == "GET":
        # Get all friends of the logged-in user
        friends = Friendship.objects.filter(user=request.user).select_related('friend')

        # Collect friends' profile information
        friend_list = []
        for friendship in friends:
            friend = friendship.friend
            try:
                profile = UserProfile.objects.get(user_profile=friend)
                friend_info = {
                    "username": friend.username,
                    "interest1": profile.interest1,
                    "interest2": profile.interest2,
                    "interest3": profile.interest3,
                    "links": profile.links,
                    "school": profile.school,
                    "major": profile.major,
                    "hometown": profile.hometown
                }
            except UserProfile.DoesNotExist:
                # If profile doesn't exist, just return username without profile data
                friend_info = {"username": friend.username}

            friend_list.append(friend_info)

        return JsonResponse({"friends": friend_list}, status=200)

    return JsonResponse({"error": "Invalid request method"}, status=400)


##### AUTH
@csrf_exempt
def signup(request):
    if request.method == "POST":
        try:
            # extract the data from the client json request body
            data = json.loads(request.body)
            username = data.get('username')
            password = data.get('password')

            # make sure neither username or password fields are empty
            if not username or not password:
                return JsonResponse({"error": "Username and password are required."}, status=400)

            # if a username is taken, simply respond that the username is taken and client must try another username
            if User.objects.filter(username=username).exists():
                return JsonResponse({"error": "Username already taken."}, status=400)

            # create a new User model field for the client with given username and password
            # Note, password is hashed automatically
            user = User(username=username)
            user.set_password(password)  # Hash the password
            user.save()

            # return that a user was created successfully
            return JsonResponse({"message": "User created successfully!"}, status=201)
        # something with wrong with the data formatting and we could not do json.loads(...)
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format."}, status=400)
        # something went wrong, possibly in the API access to User.objects..., thus return 
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)
    # wrong type of request sent, i.e, not a post request
    return JsonResponse({"error": "Invalid request method"}, status=400)

@csrf_exempt
def login_view(request):
    if request.method == "POST":
        try:
            # extract the data from the client request body
            data = json.loads(request.body)
            username = data.get('username')
            password = data.get('password')

            # make sure both the username and password fields were filled
            if not username or not password:
                return JsonResponse({"error": "Username and password are required."}, status=400)

            # authenticate the user with the Django authenticate API
            user = authenticate(request, username=username, password=password)
            # if the user is not None, log them in, else they had invalid credentials
            if user is not None:
                login(request, user)
                return JsonResponse({"message": "Login successful!"}, status=200)
            else:
                return JsonResponse({"error": "Invalid credentials."}, status=401)
        # something went from with json.loads!
        except json.JSONDecodeError:
            return JsonResponse({"error": "Invalid JSON format."}, status=400)
        # something went from with authenticate or any other Exception was raised, possibly in API calls
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)
    # wrong method call
    return JsonResponse({"error": "Invalid request method"}, status=400)


@csrf_exempt
def logout_view(request):
    if request.method == "GET":
        # simply log out, i.e. client is no longer signed in 
        try:
            logout(request)
            return JsonResponse({"message": "Logout successful!"}, status=200)
        # something went wrong and an exception was raised
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=500)
    # wrong method call
    return JsonResponse({"error": "Invalid request method"}, status=400)
    