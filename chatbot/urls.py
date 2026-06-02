from django.urls import path
from . import views  # import views from this chatbot app

urlpatterns = [
    # POST /chatbot/ → calls chatbot_reply function in views.py
    path('chatbot/', views.chatbot_reply),
]