from django.urls import path
from . import views

urlpatterns = [
    path('progress/', views.quiz_progress_list),
    path('progress/<int:progress_id>/', views.quiz_progress_detail),
    path('details/', views.quiz_detail_list),
    path('details/<int:detail_id>/', views.quiz_detail_detail),
    path('scores/', views.user_score_list),
    path('scores/<int:score_id>/', views.user_score_detail),
]