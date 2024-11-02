from django.urls import path
from . import views

urlpatterns = [
    path("post_location/", views.post_location, name="post_location"),
    path("get_users/", views.get_users, name="get_location"),
]