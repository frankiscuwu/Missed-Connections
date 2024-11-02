from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.models import User
import json
from .haversine import haversine
from .models import Location
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
        # max distance is 0.1km
        MAX_DISTANCE = 0.1
        # get the user
        user_id = request.GET.get('user_id')
        try:
            user_location = Location.objects.get(user_id=user_id)
        except Location.DoesNotExist:
            return JsonResponse({"error": "User not found."}, status=404)
        
        user_lat = user_location.latitude
        user_long = user_location.longitude

        nearby_users = []
        # find all nearby users not inclduing the user itself
        locations = Location.objects.exclude(user_id=user_id)
        for location in locations:
            distance = haversine(user_lat, user_long, location.latitude, location.longitude)
            # get nearby users only
            if distance <= MAX_DISTANCE:
                nearby_users.append({
                    "user_id": location.user_id
                })
        return JsonResponse(nearby_users, safe=False, status=200)
    return JsonResponse({"error": "Invalid request method."}, status=405)

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
