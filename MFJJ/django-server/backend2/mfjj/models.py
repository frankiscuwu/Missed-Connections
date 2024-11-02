from django.db import models

# Create your models here.
class Location(models.Model):
    user_id = models.CharField(max_length=100)
    latitude = models.FloatField()
    longitude = models.FloatField()

    def __start__(self):
        return f"{self.user_id}: ({self.latitude}, {self.longitude})"
        