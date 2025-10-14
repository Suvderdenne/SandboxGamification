from django.urls import path
from . import views

urlpatterns = [
    path("register/", views.register),
    path("login/", views.login),
    path("profile/", views.profile),
    path("logout/", views.logout),
    path("get_csrf/", views.get_csrf),
]
