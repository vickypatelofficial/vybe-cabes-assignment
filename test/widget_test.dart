import 'package:flutter_test/flutter_test.dart';
import 'package:vybe_cabs/main.dart';

void main() {
  testWidgets('Vybe Cabs App initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const VybeCabsApp());
    expect(find.byType(VybeCabsApp), findsOneWidget);
  });
}
