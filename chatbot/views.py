import json
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
from .chatbot import get_chatbot_response  # import from chatbot.py we just created


# --- CHATBOT VIEW ---
@csrf_exempt  # Flutter needs this — without it POST requests will be blocked
@require_http_methods(["POST"])  # only accept POST requests
def chatbot_reply(request):
    try:
        # Read JSON data sent from Flutter
        data = json.loads(request.body)

        # Get the message from the JSON
        message = data.get("message", "")

        # If Flutter sent empty message, return error
        if not message:
            return JsonResponse({"error": "No message provided"}, status=400)

        # Get reply from our chatbot logic
        reply = get_chatbot_response(message)

        # Send reply back to Flutter
        return JsonResponse({"reply": reply})

    except json.JSONDecodeError:
        # If JSON was invalid or broken
        return JsonResponse({"error": "Invalid JSON format"}, status=400)

    except Exception as e:
        # Catch any other unexpected errors
        return JsonResponse({"error": str(e)}, status=500)