from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from .models import Location
import json


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
        locations = Location.objects.all().values()
        print(locations)
        