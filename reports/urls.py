from django.urls import path
from . import views

urlpatterns = [
    # GET /generate-csv/ → downloads the CSV file
    path('generate-csv/', views.download_csv),
]