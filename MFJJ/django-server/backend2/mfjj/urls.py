from django.urls import path

from . import views

urlpatterns = [
    path("post_location/", post_location.index, name="post_location"),
    path("get_users/", get_users.index, name="get_location"),
]