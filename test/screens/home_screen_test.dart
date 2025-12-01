import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:burpeebata/screens/home_screen.dart';
import '../helpers/firebase_test_helper.dart';

void main() {
  Widget createTestWidget() {
    return wrapWithProviders(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen Number Inputs', () {
    group('Initial Display', () {
      testWidgets('displays all number input fields with default values', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Verify all labels are present
        expect(find.text('Reps per Set'), findsOneWidget);
        expect(find.text('Seconds per Set'), findsOneWidget);
        expect(find.text('Number of Sets'), findsOneWidget);
        expect(find.text('Rest Between Sets (sec)'), findsOneWidget);
        expect(find.text('Initial Countdown (sec)'), findsOneWidget);

        // Verify default values are displayed in text fields
        final textFields = find.byType(TextFormField);
        expect(textFields, findsNWidgets(5));

        // Check default values (5, 20, 10, 4, 10)
        expect(find.text('5'), findsOneWidget); // Reps
        expect(find.text('20'), findsOneWidget); // Seconds
        expect(find.text('10'), findsNWidgets(2)); // Sets and Initial Countdown both default to 10
        expect(find.text('4'), findsOneWidget); // Rest
      });

      testWidgets('displays plus and minus buttons for each input', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // 5 inputs * 2 buttons each = 10 icon buttons
        expect(find.byIcon(Icons.add), findsNWidgets(5));
        expect(find.byIcon(Icons.remove), findsNWidgets(5));
      });
    });

    group('Increment Button', () {
      testWidgets('increments Reps per Set by 1', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the Reps per Set add button (index 3)
        // Order: Initial Countdown (0), Number of Sets (1), Seconds per Set (2), Reps per Set (3), Rest Between Sets (4)
        final addButtons = find.byIcon(Icons.add);
        await tester.tap(addButtons.at(3));
        await tester.pump();

        // Value should increase from 5 to 6
        expect(find.text('6'), findsOneWidget);
      });

      testWidgets('does not exceed maximum value', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap the Reps per Set add button 25 times (5 + 25 = 30, which is max)
        final addButtons = find.byIcon(Icons.add);
        final repsAddButton = addButtons.at(3);
        for (int i = 0; i < 25; i++) {
          await tester.tap(repsAddButton);
          await tester.pump();
        }

        // Value should be capped at 30 (max for Reps per Set)
        expect(find.text('30'), findsOneWidget);
      });

      testWidgets('disables button at maximum value', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap to reach maximum (from 5 to 30)
        final addButtons = find.byIcon(Icons.add);
        final repsAddButton = addButtons.at(3);
        for (int i = 0; i < 25; i++) {
          await tester.tap(repsAddButton);
          await tester.pump();
        }

        // The button should still be there but disabled
        final addButton = tester.widget<IconButton>(
          find.ancestor(
            of: repsAddButton,
            matching: find.byType(IconButton),
          ),
        );
        expect(addButton.onPressed, isNull);
      });
    });

    group('Decrement Button', () {
      testWidgets('decrements Reps per Set by 1', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the Reps per Set remove button (index 3)
        // Order: Initial Countdown (0), Number of Sets (1), Seconds per Set (2), Reps per Set (3), Rest Between Sets (4)
        final removeButtons = find.byIcon(Icons.remove);
        await tester.tap(removeButtons.at(3));
        await tester.pump();

        // Value should decrease from 5 to 4
        // Note: '4' appears twice (Reps and Rest both at 4)
        expect(find.text('4'), findsNWidgets(2));
      });

      testWidgets('does not go below minimum value', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap the Reps per Set remove button many times
        final removeButtons = find.byIcon(Icons.remove);
        final repsRemoveButton = removeButtons.at(3);
        for (int i = 0; i < 15; i++) {
          await tester.tap(repsRemoveButton);
          await tester.pump();
        }

        // Value should be at minimum 1 (min for Reps per Set)
        expect(find.text('1'), findsOneWidget);
      });

      testWidgets('disables button at minimum value', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Tap to reach minimum (from 5 to 1)
        final removeButtons = find.byIcon(Icons.remove);
        final repsRemoveButton = removeButtons.at(3);
        for (int i = 0; i < 5; i++) {
          await tester.tap(repsRemoveButton);
          await tester.pump();
        }

        // The button should be disabled
        final removeButton = tester.widget<IconButton>(
          find.ancestor(
            of: repsRemoveButton,
            matching: find.byType(IconButton),
          ),
        );
        expect(removeButton.onPressed, isNull);
      });

      testWidgets('Rest Between Sets can go to 0', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the Rest Between Sets remove button (index 4)
        final removeButtons = find.byIcon(Icons.remove);
        final restRemoveButton = removeButtons.at(4);

        // Tap 4 times (default is 4, min is 0)
        for (int i = 0; i < 4; i++) {
          await tester.tap(restRemoveButton);
          await tester.pump();
        }

        // Value should be at 0
        expect(find.text('0'), findsOneWidget);
      });
    });

    group('Direct Input', () {
      testWidgets('accepts valid integer input', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find the Reps per Set text field (index 3)
        // Order: Initial Countdown (0), Number of Sets (1), Seconds per Set (2), Reps per Set (3), Rest Between Sets (4)
        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(3), '15');
        await tester.pump();

        // Value should be updated
        expect(find.text('15'), findsOneWidget);
      });

      testWidgets('clamps value to maximum when input exceeds max', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(3), '50');
        await tester.pump();

        // Value should be clamped to 30 (max for Reps per Set)
        expect(find.text('30'), findsOneWidget);
      });

      testWidgets('clamps value to minimum when input below min', (tester) async {
        await tester.pumpWidget(createTestWidget());

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(3), '0');
        await tester.pump();

        // Value should be clamped to 1 (min for Reps per Set)
        expect(find.text('1'), findsOneWidget);
      });
    });

    group('Boundary Conditions', () {
      testWidgets('Seconds per Set respects 1-60 range', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find Seconds per Set add button (index 2)
        // Order: Initial Countdown (0), Number of Sets (1), Seconds per Set (2), Reps per Set (3), Rest Between Sets (4)
        final addButtons = find.byIcon(Icons.add);
        final secondsAddButton = addButtons.at(2);

        // Tap to reach maximum (from 20 to 60)
        for (int i = 0; i < 45; i++) {
          await tester.tap(secondsAddButton);
          await tester.pump();
        }

        // Should be capped at 60
        expect(find.text('60'), findsOneWidget);
      });

      testWidgets('Number of Sets respects 1-20 range', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Find Number of Sets add button (index 1)
        // Order: Initial Countdown (0), Number of Sets (1), Seconds per Set (2), Reps per Set (3), Rest Between Sets (4)
        final addButtons = find.byIcon(Icons.add);
        final setsAddButton = addButtons.at(1);

        // Tap to reach maximum (from 10 to 20)
        for (int i = 0; i < 15; i++) {
          await tester.tap(setsAddButton);
          await tester.pump();
        }

        // Should be capped at 20 (note: '20' appears twice - once for Number of Sets
        // at max and once for Seconds per Set default value)
        expect(find.text('20'), findsNWidgets(2));
      });
    });

    group('Total Workout Time Updates', () {
      testWidgets('updates total time when values change', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Initial total: 10 sets * 20 sec + 9 rest * 4 sec = 236 sec = 3:56
        expect(find.text('3:56'), findsOneWidget);
        expect(find.text('10 sets \u00d7 5 reps = 50 total reps'), findsOneWidget);

        // Increase number of sets from 10 to 11
        // Number of Sets is at index 1
        // Order: Initial Countdown (0), Number of Sets (1), Seconds per Set (2), Reps per Set (3), Rest Between Sets (4)
        final addButtons = find.byIcon(Icons.add);
        final setsAddButton = addButtons.at(1);
        await tester.tap(setsAddButton);
        await tester.pump();

        // New total: 11 sets * 20 sec + 10 rest * 4 sec = 260 sec = 4:20
        expect(find.text('4:20'), findsOneWidget);
        expect(find.text('11 sets \u00d7 5 reps = 55 total reps'), findsOneWidget);
      });

      testWidgets('updates total reps when reps per set changes', (tester) async {
        await tester.pumpWidget(createTestWidget());

        // Increase reps per set from 5 to 6
        // Reps per Set is the 4th input (index 3) after Initial Countdown, Number of Sets, Seconds per Set
        final addButtons = find.byIcon(Icons.add);
        await tester.tap(addButtons.at(3));
        await tester.pump();

        expect(find.text('10 sets \u00d7 6 reps = 60 total reps'), findsOneWidget);
      });
    });
  });
}
