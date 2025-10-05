// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:substraction_game/main.dart';

void main() {
  testWidgets('App title is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const SubtractionGame());
    expect(find.text('Subtraction Game'), findsOneWidget);
  });

  testWidgets('Difficulty selector is shown on start', (WidgetTester tester) async {
    await tester.pumpWidget(const SubtractionGame());
    expect(find.text('Select Difficulty Level'), findsOneWidget);
    expect(find.text('Grade 1 (1-10)'), findsOneWidget);
    expect(find.text('Grade 5 (1-9999)'), findsOneWidget);
  });

  testWidgets('Question text is displayed after selecting difficulty', (WidgetTester tester) async {
    await tester.pumpWidget(const SubtractionGame());
    await tester.tap(find.text('Grade 1 (1-10)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('What is'), findsOneWidget);
  });

  testWidgets('Four answer buttons are shown', (WidgetTester tester) async {
    await tester.pumpWidget(const SubtractionGame());
    await tester.tap(find.text('Grade 1 (1-10)'));
    await tester.pumpAndSettle();
    // There should be 4 ElevatedButtons for the options
    expect(find.byType(ElevatedButton), findsNWidgets(7)); // 4 options + 3 bottom buttons
  });

  testWidgets('Correct answer shows success message', (WidgetTester tester) async {
    await tester.pumpWidget(const SubtractionGame());
    await tester.tap(find.text('Grade 1 (1-10)'));
    await tester.pumpAndSettle();

    final questionFinder = find.textContaining('What is');
    expect(questionFinder, findsOneWidget);

    final questionText = tester.widget<Text>(questionFinder).data!;
    final regex = RegExp(r'What is (\d+) - (\d+) \?');
    final match = regex.firstMatch(questionText);
    expect(match, isNotNull);

    final num1 = int.parse(match!.group(1)!);
    final num2 = int.parse(match.group(2)!);
    final correctAnswer = num1 - num2;

    // Find the option button with the correct answer
    await tester.tap(find.widgetWithText(ElevatedButton, '$correctAnswer').first);
    await tester.pump();

    expect(find.text('✅ Correct!'), findsOneWidget);
  });

  testWidgets('Wrong answer shows error message', (WidgetTester tester) async {
    await tester.pumpWidget(const SubtractionGame());
    await tester.tap(find.text('Grade 1 (1-10)'));
    await tester.pumpAndSettle();

    final questionFinder = find.textContaining('What is');
    expect(questionFinder, findsOneWidget);

    final questionText = tester.widget<Text>(questionFinder).data!;
    final regex = RegExp(r'What is (\d+) - (\d+) \?');
    final match = regex.firstMatch(questionText);
    expect(match, isNotNull);

    final num1 = int.parse(match!.group(1)!);
    final num2 = int.parse(match.group(2)!);
    final correctAnswer = num1 - num2;

    // Find all option buttons
    final optionButtons = tester.widgetList<ElevatedButton>(find.byType(ElevatedButton)).toList();
    for (final button in optionButtons) {
      final buttonText = (button.child as Text).data!;
      if (buttonText != '$correctAnswer' && int.tryParse(buttonText) != null) {
        await tester.tap(find.widgetWithText(ElevatedButton, buttonText).first);
        await tester.pump();
        expect(find.text('❌ Incorrect!'), findsOneWidget);
        break;
      }
    }
  });
}
