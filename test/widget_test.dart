import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Basic Flutter widget test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Text('ConnectCall'),
        ),
      ),
    );

    expect(find.text('ConnectCall'), findsOneWidget);
  });
}