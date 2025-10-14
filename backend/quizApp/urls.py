from django.urls import path
from . import views

urlpatterns = [
    path('topics/', views.topic_list),
    path('topics/<int:topic_id>/', views.topic_detail),

    path('quizzes/', views.quiz_list),
    path('quizzes/<int:quiz_id>/', views.quiz_detail),

    path('questions/', views.question_list),
    path('questions/<int:question_id>/', views.question_detail),

    path('options/', views.option_list),
    path('options/<int:option_id>/', views.option_detail),
]
