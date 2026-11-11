import 'package:flutter_test/flutter_test.dart';
import 'package:earth_dna_mobile/main.dart';

void main() {
  testWidgets('EarthDnaApp launches smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const EarthDnaApp());
    expect(find.byType(EarthDnaApp), findsOneWidget);
  });
}
