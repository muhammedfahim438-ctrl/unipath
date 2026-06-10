from django.http import JsonResponse
from .analytics import get_analytics_data  # import our function


def analytics(request):
    try:
        # Call our function to get all analytics data
        data = get_analytics_data()

        # Return data as JSON to Flutter
        return JsonResponse(data)

    except FileNotFoundError:
        # If serviceAccountKey.json is missing
        return JsonResponse(
            {"error": "serviceAccountKey.json not found. Get it from Fahim!"},
            status=500
        )

    except Exception as e:
        # Any other error
        return JsonResponse(
            {"error": str(e)},
            status=500
        )