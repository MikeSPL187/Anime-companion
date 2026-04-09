import 'package:ani_app/shared/widgets/action_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows consistent undo snackbar feedback', (tester) async {
    var undoCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showUndoSnackBar(
                    context,
                    message: 'Статус: Смотрю',
                    onUndo: () {
                      undoCalled = true;
                    },
                  );
                },
                child: const Text('Действие'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Действие'));
    await tester.pump();

    expect(find.text('Статус: Смотрю'), findsOneWidget);
    expect(find.text('Отменить'), findsOneWidget);

    final undoAction = tester.widget<SnackBarAction>(
      find.byType(SnackBarAction),
    );
    undoAction.onPressed();

    expect(undoCalled, isTrue);
  });

  testWidgets('shows consistent error snackbar feedback', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () {
                  showActionErrorSnackBar(
                    context,
                    'Не удалось обновить прогресс',
                  );
                },
                child: const Text('Ошибка'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Ошибка'));
    await tester.pump();

    expect(find.text('Не удалось обновить прогресс'), findsOneWidget);
  });
}
