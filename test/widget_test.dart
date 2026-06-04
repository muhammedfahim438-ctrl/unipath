import 'package:flutter_test/flutter_test.dart';
import 'package:unipath/main.dart';

void main() {
  testWidgets('UniPath smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const UniPathApp());
  });
}