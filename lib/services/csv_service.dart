import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CsvService {
  static String _toCsv(List<List<dynamic>> rows) {
    return rows.map((row) {
      return row.map((cell) {
        final value = cell.toString();
        if (value.contains(',') ||
            value.contains('\n') ||
            value.contains('"')) {
          return '"${value.replaceAll('"', '""')}"';
        }
        return value;
      }).join(',');
    }).join('\n');
  }

  static Future<void> generateAndShareCSV() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('learning_style_results')
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No quiz results found!');
      }

      List<List<dynamic>> rows = [];
      rows.add([
        'Student Name', 'Department', 'Year',
        'Visual Score', 'Auditory Score',
        'Kinesthetic Score', 'Dominant Style',
        'Score %', 'Date',
      ]);

      for (final doc in snapshot.docs) {
        final data = doc.data();
        rows.add([
          data['name'] ?? 'Unknown',
          data['department'] ?? '',
          data['year'] ?? '',
          data['visual_score'] ?? 0,
          data['auditory_score'] ?? 0,
          data['kinesthetic_score'] ?? 0,
          data['dominant_style'] ?? '',
          data['score_percent'] ?? 0,
          data['date'] ?? '',
        ]);
      }

      final csvString = _toCsv(rows);

      if (kIsWeb) {
        // Web — download directly
        throw Exception(
            'Please test on Android device or emulator for CSV download!');
      } else {
        // Mobile — save and share
        final directory =
            await getTemporaryDirectory();
        final path =
            '${directory.path}/learning_style_report.csv';
        final file = File(path);
        await file.writeAsString(csvString);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(path)],
            subject: 'UniPath Learning Style Report',
            text:
                'Learning Style Quiz Results — NASC UniPath',
          ),
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>>
      getReportStats() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('learning_style_results')
          .get();

      int visual = 0;
      int auditory = 0;
      int kinesthetic = 0;

      for (final doc in snapshot.docs) {
      final data = doc.data();
      final style = data['dominant_style']?.toString() ?? '';
      if (style == 'Visual') {
        visual++;
      } else if (style == 'Auditory') {
        auditory++;
      } else if (style == 'Kinesthetic') {
        kinesthetic++;
      }
    }
    
      return {
        'total': snapshot.docs.length,
        'visual': visual,
        'auditory': auditory,
        'kinesthetic': kinesthetic,
      };
    } catch (e) {
      return {
        'total': 0,
        'visual': 0,
        'auditory': 0,
        'kinesthetic': 0,
      };
    }
  }
}