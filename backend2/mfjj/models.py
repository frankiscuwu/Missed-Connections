from django.db import models
from django.contrib.auth.models import User

# Create your models here.
class Location(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="location")
    latitude = models.FloatField()
    longitude = models.FloatField()
    created_at = models.DateTimeField(auto_now_add=True)
    def __start__(self):
        return f"{self.user_id}: ({self.latitude}, {self.longitude})"

class UserProfile(models.Model):
    user_profile = models.OneToOneField(User, on_delete=models.CASCADE)
    interest1 = models.TextField(blank=False)
    interest2 = models.TextField(blank=False)
    interest3 = models.TextField(blank=False)
    created_at = models.DateTimeField(auto_now_add=True)
    def save(self, *args, **kwargs):
        if self.interest1 and self.interest2 & self.interest3:
            self.interest1 = self.interest1.lower()
            self.interest2 = self.interest2.lower()
            self.interest3 = self.interest3.lower()
        def __str__(self):
            return f"{self.user_id.username}'s Profile"
