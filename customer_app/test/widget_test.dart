import 'package:flutter_test/flutter_test.dart';
import 'package:sevagan_customer/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const SevaganCustomerApp());

    expect(find.byType(SevaganCustomerApp), findsOneWidget);
  });
}