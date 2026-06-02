from django.contrib import admin
from django.urls import path, include

urlpatterns = [
    path('admin/', admin.site.urls),

    # connects chatbot app urls
    path('', include('chatbot.urls')),
]