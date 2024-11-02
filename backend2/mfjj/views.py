from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from .haversine import haversine
from .models import Location
# Create your views here.
@csrf_exempt
def post_location(request):
    if request.method == "POST":
        data = json.loads(request.body) 
        user_id = data.get("user_id")
        latitude = data.get("latitude")
        longitude = data.get("longitude")

        location = Location(user_id=user_id, latitude = latitude, longitude=longitude)
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
        
        