import 'package:flutter_test/flutter_test.dart';
import 'package:project129/main.dart';

void main() {
  testWidgets('shows the pizza home menu', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.text('Planet Pizza'), findsOneWidget);
    expect(find.text('Hot Deals'), findsOneWidget);
    expect(find.text('Vesuvius Inferno'), findsWidgets);
    expect(find.text('Tìm pizza, topping hoặc đồ uống...'), findsOneWidget);
  });
}
