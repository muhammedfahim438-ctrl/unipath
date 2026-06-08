class ChatbotService {
  static String getResponse(String message) {
    final msg = message.toLowerCase().trim();

    // ── Greetings ──
    if (_matches(msg, [
      'hi', 'hello', 'hey', 'good morning',
      'good evening', 'good afternoon', 'howdy'
    ])) {
      return 'Hello! 👋 I am UniBot, your wellness assistant at NASC UniPath.\n\nHow can I help you today? You can ask me about:\n• Stress management\n• Study tips\n• Counselling booking\n• Mental wellness';
    }

    // ── Stress / Anxiety ──
    if (_matches(msg, [
      'stress', 'stressed', 'anxiety', 'anxious',
      'worried', 'worry', 'nervous', 'pressure',
      'overwhelmed', 'panic', 'tense', 'tension'
    ])) {
      return 'I understand you are feeling stressed. 💙\n\nHere are some tips to help:\n✅ Take short breaks every 45 minutes\n✅ Practice deep breathing (inhale 4s, hold 4s, exhale 4s)\n✅ Stay hydrated — drink water regularly\n✅ Go for a short walk outside\n✅ Talk to a friend or family member\n\nRemember: It is okay to ask for help. Would you like to book a counselling session?';
    }

    // ── Exams / Study ──
    if (_matches(msg, [
      'exam', 'exams', 'study', 'studying', 'marks',
      'fail', 'failed', 'grade', 'grades', 'test',
      'assignment', 'homework', 'score', 'result',
      'syllabus', 'revision', 'prepare'
    ])) {
      return 'Here are some effective study tips! 📚\n\n✅ Make a daily study schedule\n✅ Use the Pomodoro technique (25 min study, 5 min break)\n✅ Review notes within 24 hours of class\n✅ Practice past papers\n✅ Study in a quiet, well-lit place\n✅ Get 7-8 hours of sleep before exams\n\nYou can do it! Believe in yourself. 💪';
    }

    // ── Sad / Depressed ──
    if (_matches(msg, [
      'sad', 'depressed', 'depression', 'unhappy',
      'cry', 'crying', 'alone', 'lonely', 'hopeless',
      'worthless', 'empty', 'hurt', 'pain', 'upset'
    ])) {
      return 'I am sorry you are feeling this way. 💙\n\nYour feelings are valid and you are not alone. Here are some things that might help:\n\n✅ Talk to someone you trust\n✅ Write your feelings in a journal\n✅ Do something you enjoy\n✅ Get sunlight and fresh air\n✅ Rest and take care of yourself\n\nPlease consider talking to our counsellor. They are here to help you. Would you like to book a session?';
    }

    // ── Motivation ──
    if (_matches(msg, [
      'motivat', 'give up', 'tired', 'exhausted',
      'hopeless', 'lost', 'purpose', 'meaning',
      'demotivat', 'lazy', 'procrastinat', 'stuck'
    ])) {
      return 'You are stronger than you think! 🌟\n\nHere are some motivational reminders:\n\n💜 Every day is a new beginning\n💜 Small steps lead to big success\n💜 Progress is more important than perfection\n💜 Your struggles today are your strength tomorrow\n💜 Believe in yourself — you got this!\n\nTake it one day at a time. 😊';
    }

    // ── Counselling / Booking ──
    if (_matches(msg, [
      'counsell', 'counsel', 'book', 'appointment',
      'session', 'therapist', 'psychologist', 'help',
      'support', 'talk to someone', 'meet'
    ])) {
      return 'You can book a counselling session easily! 📅\n\nSteps to book:\n1. Go to Dashboard\n2. Tap "Book Counselling"\n3. Select your preferred date and time\n4. Choose a slot\n5. Confirm your booking\n\nOur counsellors are trained professionals who are here to support you. Your privacy is always protected. 💙';
    }

    // ── Sleep ──
    if (_matches(msg, [
      'sleep', 'insomnia', 'cant sleep', 'sleepy',
      'tired', 'fatigue', 'rest', 'nightmare'
    ])) {
      return 'Good sleep is important for your wellbeing! 😴\n\nHere are some sleep tips:\n\n✅ Maintain a regular sleep schedule\n✅ Avoid screens 1 hour before bed\n✅ Keep your room cool and dark\n✅ Avoid caffeine after 4 PM\n✅ Try relaxation techniques before sleeping\n\nAim for 7-8 hours of sleep every night.';
    }

    // ── Food / Health ──
    if (_matches(msg, [
      'food', 'eat', 'diet', 'nutrition', 'healthy',
      'headache', 'sick', 'health', 'exercise', 'fitness'
    ])) {
      return 'Taking care of your health is important! 🌿\n\nHere are some health tips:\n\n✅ Eat regular balanced meals\n✅ Stay hydrated — 8 glasses of water daily\n✅ Exercise for 30 minutes daily\n✅ Take breaks from screen time\n✅ Go for walks in fresh air\n\nYour physical health directly affects your mental health!';
    }

    // ── Relationship / Family ──
    if (_matches(msg, [
      'relationship', 'family', 'friend', 'friends',
      'fight', 'argument', 'breakup', 'miss', 'home',
      'parent', 'parents', 'love', 'heartbreak'
    ])) {
      return 'Relationships can be challenging sometimes. 💙\n\nHere are some tips:\n\n✅ Communicate openly and honestly\n✅ Listen actively to others\n✅ Give yourself time to process emotions\n✅ Seek support from trusted people\n✅ Focus on your own wellbeing\n\nWould you like to talk to our counsellor for more personalised support?';
    }

    // ── Career / Future ──
    if (_matches(msg, [
      'career', 'future', 'job', 'placement', 'work',
      'internship', 'confused', 'doubt', 'course',
      'degree', 'after college', 'what to do'
    ])) {
      return 'It is normal to feel uncertain about the future! 🎯\n\nHere are some tips:\n\n✅ Talk to your professors and mentors\n✅ Attend career guidance sessions\n✅ Explore your interests and strengths\n✅ Focus on building skills\n✅ Take it one step at a time\n\nOur counsellors can also help with career guidance. Would you like to book a session?';
    }

    // ── Anger ──
    if (_matches(msg, [
      'angry', 'anger', 'frustrat', 'irritat',
      'mad', 'furious', 'annoyed', 'rage'
    ])) {
      return 'It is okay to feel angry sometimes. 💙\n\nHere are some ways to manage anger:\n\n✅ Take deep breaths before reacting\n✅ Count to 10 slowly\n✅ Walk away from the situation temporarily\n✅ Exercise to release tension\n✅ Write your feelings down\n\nIf anger is affecting your daily life, our counsellor can help!';
    }

    // ── Gratitude / Positive ──
    if (_matches(msg, [
      'happy', 'good', 'great', 'amazing', 'wonderful',
      'thank', 'thanks', 'grateful', 'better', 'fine'
    ])) {
      return 'That is wonderful to hear! 😊🌟\n\nKeep spreading positivity! Here are some ways to maintain good mental health:\n\n✅ Practice gratitude daily\n✅ Celebrate small wins\n✅ Stay connected with supportive people\n✅ Continue doing things you enjoy\n\nRemember UniBot is always here if you need support! 💜';
    }

    // ── About UniBot ──
    if (_matches(msg, [
      'who are you', 'what are you', 'unibot',
      'about you', 'your name', 'what can you do'
    ])) {
      return 'I am UniBot! 🤖💜\n\nI am your wellness assistant at NASC UniPath. I can help you with:\n\n• 💆 Stress and anxiety support\n• 📚 Study and exam tips\n• 😴 Sleep and health advice\n• 📅 Counselling session booking\n• 💪 Motivation and encouragement\n• 🎯 Career guidance tips\n\nJust type what is on your mind and I will do my best to help!';
    }

    // ── Emergency ──
    if (_matches(msg, [
      'suicide', 'kill myself', 'end my life',
      'self harm', 'hurt myself', 'dont want to live',
      'emergency', 'crisis'
    ])) {
      return '🚨 Please reach out for help immediately!\n\nYou are not alone and your life is valuable. 💙\n\nPlease contact:\n• iCall Helpline: 9152987821\n• Vandrevala Foundation: 1860-2662-345\n• SNEHI: 044-24640050\n\nOr go to your nearest hospital emergency department immediately.\n\nPlease also book a counselling session with our team right away. We care about you. 💜';
    }

    // ── Default ──
    return 'Thank you for sharing that with me. 💙\n\nI am here to support you. Here is what I can help with:\n\n• 💆 Stress and anxiety\n• 📚 Study and exam tips\n• 📅 Book a counselling session\n• 💪 Motivation\n• 😴 Sleep tips\n• 🎯 Career guidance\n\nCould you tell me more about what you are going through? Or would you like to book a counselling session with our expert?';
  }

  // ── Helper: check if message contains any keyword ─────────
  static bool _matches(String message, List<String> keywords) {
    for (final keyword in keywords) {
      if (message.contains(keyword)) return true;
    }
    return false;
  }
}