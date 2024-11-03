from django.urls import path
from . import views


# urls endpoints for the API 
urlpatterns = [
    path("post_friends/", views.post_friends, name="post_friends"),
    path("post_location/", views.post_location, name="post_location"),
    path("post_profile/", views.post_profile, name="post_profile"),
    path("get_users/", views.get_users, name="get_location"),
    path("login/", views.login_view, name="login"),
    path("logout/", views.logout_view, name="logout"),
    path("signup/", views.signup, name="signup"),
]