from django.contrib import admin
from .models import User, BlacklistedToken

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ("id", "username")

@admin.register(BlacklistedToken)
class BlacklistedTokenAdmin(admin.ModelAdmin):
    list_display = ("jti", "blacklisted_at", "expires_at")
