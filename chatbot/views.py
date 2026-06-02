from rest_framework.decorators import api_view
from rest_framework.response import Response


@api_view(['POST'])
def chatbot_response(request):
    message = request.data.get("message", "").lower()

    if any(word in message for word in ["stress", "anxiety", "worried", "nervous", "pressure"]):
        reply = "Take short breaks. Practice deep breathing. You are not alone."

    elif any(word in message for word in ["exam", "study", "marks", "fail", "grades", "test"]):
        reply = "Make a study schedule. Revision is key. Believe in yourself!"

    elif any(word in message for word in ["sad", "depressed", "unhappy", "cry", "alone", "lonely"]):
        reply = "It is okay to feel sad. Please talk to a counsellor. We are here for you."

    elif any(word in message for word in ["motivate", "motivation", "give up", "tired", "hopeless", "lost"]):
        reply = "Every day is a new beginning. Small steps lead to big success!"

    elif any(word in message for word in ["counselling", "book", "appointment", "session", "help"]):
        reply = "You can book a counselling session from the Appointments section."

    elif any(word in message for word in ["hi", "hello", "hey", "good morning", "good evening"]):
        reply = "Hello! I am UniBot. How can I help you today?"

    else:
        reply = "I understand. Please consider talking to a counsellor for better support."

    return Response({"reply": reply})