import random  # to pick random replies so it doesn't feel repetitive

def get_chatbot_response(message):
    message = message.lower()

    # ─── GREETING ───────────────────────────────────────────
    if any(word in message for word in ['hi', 'hello', 'hey', 'good morning', 'good evening', 'hai']):
        replies = [
            "Hey there! 👋 I'm UniBot, your friendly college companion! How are you feeling today?\n\n"
            "I can help you with:\n"
            "1️⃣ Stress & anxiety\n"
            "2️⃣ Exam & study tips\n"
            "3️⃣ Feeling sad or low\n"
            "4️⃣ Motivation boost\n"
            "5️⃣ Book a counselling session\n\n"
            "Just tell me what's on your mind! 😊",

            "Hello! 😄 Great to see you here! I'm UniBot!\n\n"
            "What would you like help with today?\n"
            "💬 Talk about stress\n"
            "📚 Study tips\n"
            "💛 Feeling down\n"
            "💪 Need motivation\n"
            "📅 Book appointment\n\n"
            "I'm all ears! Go ahead and tell me 🙂",
        ]
        return random.choice(replies)

    # ─── STRESS / ANXIETY ────────────────────────────────────
    elif any(word in message for word in ['stress', 'anxious', 'worried', 'nervous', 'pressure', 'anxiety', 'overwhelmed', 'panic']):
        replies = [
            "Hey, I hear you! Stress is really tough 😔 But you're not alone!\n\n"
            "Here are some things that can help right now:\n"
            "🌬️ Take 5 deep breaths slowly\n"
            "🚶 Go for a short 10 minute walk\n"
            "💧 Drink some water and take a break\n"
            "🎵 Listen to your favourite music\n"
            "📝 Write down what's worrying you\n\n"
            "Would you like to:\n"
            "1️⃣ Talk more about what's stressing you\n"
            "2️⃣ Book a counselling session\n"
            "3️⃣ Get some study tips\n\n"
            "You've got this! 💙",

            "Aww, sounds like you're going through a lot right now 🫂\n\n"
            "Remember — feeling stressed means you care, and that's okay!\n\n"
            "Try these right now:\n"
            "✅ Break your tasks into small steps\n"
            "✅ Take one thing at a time\n"
            "✅ Rest is not laziness — it's necessary!\n"
            "✅ Talk to someone you trust\n\n"
            "Want me to help you:\n"
            "1️⃣ Make a study plan\n"
            "2️⃣ Connect with a counsellor\n"
            "3️⃣ Just vent — I'm listening! 😊",
        ]
        return random.choice(replies)

    # ─── EXAM / STUDY ────────────────────────────────────────
    elif any(word in message for word in ['exam', 'study', 'marks', 'fail', 'grades', 'test', 'assignment', 'syllabus', 'revision', 'score']):
        replies = [
            "Ooh exam season! 📚 Don't worry, let's tackle this together!\n\n"
            "Here are some proven study tips:\n"
            "⏰ Use the Pomodoro technique — 25 min study, 5 min break\n"
            "📝 Make short notes for each topic\n"
            "🔁 Revise previous day's topics every morning\n"
            "😴 Sleep at least 7 hours — your brain needs it!\n"
            "🥤 Stay hydrated while studying\n\n"
            "Need help with:\n"
            "1️⃣ Making a study timetable\n"
            "2️⃣ Dealing with exam anxiety\n"
            "3️⃣ Staying motivated to study\n\n"
            "You've prepared for this — trust yourself! 🌟",

            "Hey, failing or scoring low doesn't define you! 💛\n\n"
            "Every topper has failed at some point. What matters is getting back up!\n\n"
            "Let's make a plan:\n"
            "📌 List all subjects and topics\n"
            "📌 Mark which ones need more attention\n"
            "📌 Give more time to weak areas\n"
            "📌 Practice previous year questions\n"
            "📌 Form a study group with friends\n\n"
            "Want to:\n"
            "1️⃣ Talk to a counsellor about exam stress\n"
            "2️⃣ Get more study strategies\n"
            "3️⃣ Just take a breather first 😄\n\n"
            "Believe in yourself — you CAN do this! 💪",
        ]
        return random.choice(replies)

    # ─── SAD / DEPRESSED ─────────────────────────────────────
    elif any(word in message for word in ['sad', 'depressed', 'unhappy', 'cry', 'alone', 'lonely', 'hopeless', 'empty', 'miserable', 'worthless']):
        replies = [
            "Hey, I'm really glad you told me this 🫂\n\n"
            "It takes courage to share how you feel. You are NOT alone in this!\n\n"
            "Please know:\n"
            "💛 What you feel is valid\n"
            "💛 This feeling will pass\n"
            "💛 You are loved and valued\n"
            "💛 Asking for help is strength, not weakness\n\n"
            "I'd really like you to:\n"
            "1️⃣ Talk to our college counsellor — they truly help!\n"
            "2️⃣ Share with a trusted friend or family member\n"
            "3️⃣ Do one small thing you enjoy today\n\n"
            "You matter so much! 💙 Would you like to book a session?",

            "Sending you a big virtual hug right now 🤗\n\n"
            "Feeling sad is okay — don't be hard on yourself!\n\n"
            "Some gentle reminders:\n"
            "🌸 You are enough just as you are\n"
            "🌸 Bad days don't last forever\n"
            "🌸 It's okay to cry — let it out\n"
            "🌸 Tomorrow is a fresh start\n\n"
            "Right now, try:\n"
            "1️⃣ Talking to someone you trust\n"
            "2️⃣ Booking a counselling appointment\n"
            "3️⃣ Going outside for some fresh air\n\n"
            "I'm always here for you! 💛",
        ]
        return random.choice(replies)

    # ─── MOTIVATION ──────────────────────────────────────────
    elif any(word in message for word in ['motivate', 'give up', 'tired', 'lost', 'motivation', 'discouraged', 'cant do', "can't do", 'no energy', 'lazy']):
        replies = [
            "Hey, feeling tired is OKAY! You've been working hard! 💪\n\n"
            "But don't give up — you're closer than you think!\n\n"
            "Quick motivation boost:\n"
            "🔥 Remember WHY you started\n"
            "🔥 Look how far you've already come\n"
            "🔥 One small step today beats zero steps\n"
            "🔥 Your future self will thank you!\n\n"
            "Try this right now:\n"
            "1️⃣ Write down 3 things you're proud of\n"
            "2️⃣ Set one tiny goal for today\n"
            "3️⃣ Take a 10 minute break then comeback\n\n"
            "You are capable of AMAZING things! 🌟",

            "You know what? Even feeling like giving up shows how hard you've tried! 🫂\n\n"
            "Here's your reminder:\n"
            "⭐ Every expert was once a beginner\n"
            "⭐ Progress is progress, no matter how small\n"
            "⭐ Rest if you must, but don't quit!\n"
            "⭐ Your hard work WILL pay off\n\n"
            "Want to:\n"
            "1️⃣ Talk to a counsellor for guidance\n"
            "2️⃣ Get a study plan to feel organised\n"
            "3️⃣ Just chat — I'm here! 😊\n\n"
            "Keep going legend! 👑",
        ]
        return random.choice(replies)

    # ─── COUNSELLING / BOOKING ───────────────────────────────
    elif any(word in message for word in ['counselling', 'book', 'appointment', 'session', 'meet', 'counselor', 'therapist', 'talk to someone']):
        replies = [
            "That's a great decision! 👏 Talking to a counsellor is one of the bravest things you can do!\n\n"
            "Here's how to book:\n"
            "📱 Open the UniPath app\n"
            "📅 Go to Appointments section\n"
            "✅ Pick your preferred date and time\n"
            "💬 Add a short note about what you'd like to discuss\n"
            "🎉 Done! You'll get a confirmation\n\n"
            "Our counsellors are:\n"
            "1️⃣ Friendly and non-judgmental\n"
            "2️⃣ Completely confidential\n"
            "3️⃣ Here to genuinely help you!\n\n"
            "You're making a wonderful choice for yourself! 💛",

            "Yay! I'm so happy you're taking this step! 🌟\n\n"
            "Booking is super easy:\n"
            "👉 Go to Appointments in the app\n"
            "👉 Choose a time that works for you\n"
            "👉 Show up — that's all!\n\n"
            "Remember:\n"
            "💙 Everything you share is private\n"
            "💙 No problem is too small to discuss\n"
            "💙 The counsellor is on YOUR side\n\n"
            "Is there anything else I can help you with? 😊",
        ]
        return random.choice(replies)

    # ─── DEFAULT ─────────────────────────────────────────────
    else:
        replies = [
            "Hey! Thanks for reaching out 😊\n\n"
            "I'm UniBot and I'm here to help! Here's what I can do:\n\n"
            "1️⃣ Help with stress & anxiety\n"
            "2️⃣ Give exam & study tips\n"
            "3️⃣ Support when you're feeling low\n"
            "4️⃣ Boost your motivation\n"
            "5️⃣ Help book a counselling session\n\n"
            "Just tell me what's going on — I'm listening! 💙",

            "Hmm, I want to make sure I help you the right way! 🤔\n\n"
            "Could you tell me more? For example:\n"
            "😰 Are you feeling stressed or anxious?\n"
            "📚 Do you need help with studies?\n"
            "😔 Are you feeling sad or lonely?\n"
            "💪 Do you need some motivation?\n"
            "📅 Want to book a counselling session?\n\n"
            "I'm here for you — just let me know! 😊",
        ]
        return random.choice(replies)