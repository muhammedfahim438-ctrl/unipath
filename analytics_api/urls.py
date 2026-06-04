from django.urls import path
from . import views

urlpatterns = [
    # GET /analytics/ → returns all stats as JSON
    path('analytics/', views.analytics),
]