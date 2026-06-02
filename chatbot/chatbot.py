# This file contains all the chatbot keyword matching logic

def get_chatbot_response(message):
    # Convert to lowercase so HI and hi both work
    message = message.lower()

    # --- GREETING ---
    if any(word in message for word in ['hi', 'hello', 'hey', 'good morning', 'good evening']):
        return "Hello! I am UniBot. How can I help you today? 😊"

    # --- STRESS / ANXIETY ---
    elif any(word in message for word in ['stress', 'anxious', 'worried', 'nervous', 'pressure', 'anxiety']):
        return "I understand you are feeling stressed. Take short breaks, practice deep breathing, and remember — you are not alone. 💙"

    # --- EXAM / STUDY ---
    elif any(word in message for word in ['exam', 'study', 'marks', 'fail', 'grades', 'test', 'assignment']):
        return "Make a study schedule and take it one step at a time. Revision is key. Believe in yourself — you can do this! 📚"

    # --- SAD / DEPRESSED ---
    elif any(word in message for word in ['sad', 'depressed', 'unhappy', 'cry', 'alone', 'lonely', 'hopeless']):
        return "It is okay to feel sad sometimes. Please talk to a counsellor — we are here for you. You matter! 💛"

    # --- MOTIVATION ---
    elif any(word in message for word in ['motivate', 'give up', 'tired', 'lost', 'motivation', 'discouraged']):
        return "Every day is a new beginning. Small steps lead to big success. Keep going — you are stronger than you think! 💪"

    # --- COUNSELLING / BOOKING ---
    elif any(word in message for word in ['counselling', 'book', 'appointment', 'session', 'help', 'counselor']):
        return "You can book a counselling session from the Appointments section in the app. We are here to support you! 📅"

    # --- DEFAULT ---
    else:
        return "I understand. Please consider talking to a counsellor for better support. You are not alone. 🌟"