import 'package:ani_app/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts on the home route', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: AniApp()));
    await tester.pump();

    expect(find.byIcon(Icons.home), findsOneWidget);
    expect(find.text('Главная'), findsWidgets);
  });
}
