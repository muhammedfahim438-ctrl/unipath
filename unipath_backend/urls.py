from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),

    # Task 1 — Chatbot
    path('', include('chatbot.urls')),

    # Task 2 — CSV Report
    path('', include('reports.urls')),

    # Task 3 — Analytics
    path('', include('analytics_api.urls')),
]