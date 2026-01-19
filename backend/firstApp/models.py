from django.db import models
from django.contrib.auth.hashers import make_password, check_password
from django.utils import timezone

class User(models.Model):
    username = models.CharField(max_length=150, unique=True)
    email = models.EmailField(default="example@gmail.com")
    password = models.CharField(max_length=255)
    verified = models.CharField(default="N", max_length=1)

    def set_password(self, raw_password):
        self.password = make_password(raw_password)

    def check_password(self, raw_password):
        return check_password(raw_password, self.password)
    
    def check_verified(self, verified):
        return verified == 'Y'

    def __str__(self):
        return self.username
    
    class Meta:
        db_table = "User"

class BlacklistedToken(models.Model):
    jti = models.CharField(max_length=255, unique=True)  # token-ийн unique id
    blacklisted_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()  # token expire үед устгахад ашиглана

    def __str__(self):
        return f"{self.jti} (expires {self.expires_at})"
    class Meta:
        db_table = "BlackListedToken"
