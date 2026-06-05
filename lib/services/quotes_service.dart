import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuotesService {
  // ─── Get random quote from Firestore ──────────────────────
  static Future<Map<String, dynamic>?> getDailyQuote() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quotes')
          .get();

      if (snapshot.docs.isEmpty) return null;

      // Get random quote
      snapshot.docs.shuffle();
      final doc = snapshot.docs.first;
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  // ─── Check if quote shown today ───────────────────────────
  static Future<bool> shouldShowQuoteToday() async {
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getString('last_quote_date');
    final today = DateTime.now().toString().split(' ')[0];

    if (lastShown == today) return false;
    await prefs.setString('last_quote_date', today);
    return true;
  }

  // ─── Reset for testing ─────────────────────────────────────
  static Future<void> resetQuoteDate() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_quote_date');
  }
}