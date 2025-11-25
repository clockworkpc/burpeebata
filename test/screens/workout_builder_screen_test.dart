import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:burpeebata/screens/workout_builder_screen.dart';
import 'package:burpeebata/models/workout_template.dart';
import 'package:burpeebata/models/burpee_type.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget({WorkoutTemplate? existingTemplate}) {
    return MaterialApp(
      home: WorkoutBuilderScreen(existingTemplate: existingTemplate),
    );
  }

  group('WorkoutBuilderScreen', () {
    testWidgets('displays initial page with name input', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Name Your Workout'), findsOneWidget);
      expect(find.text('Give this workout configuration a memorable name'),
          findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('NEXT'), findsOneWidget);
    });

    testWidgets('shows progress indicator on first page', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Step 1 of 8'), findsOneWidget);
    });

    testWidgets('NEXT button disabled when name is empty', (tester) async {
      await tester.pumpWidget(createTestWidget());

      final nextButton =
          tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'NEXT'));
      expect(nextButton.onPressed, isNull);
    });

    testWidgets('NEXT button enabled when name is entered', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Morning Burn');
      await tester.pump();

      final nextButton =
          tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'NEXT'));
      expect(nextButton.onPressed, isNotNull);
    });

    testWidgets('navigates to burpee type page after entering name',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Morning Burn');
      await tester.pump();

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Burpee Type'), findsOneWidget);
      expect(find.text('Step 2 of 8'), findsOneWidget);
    });

    testWidgets('shows BACK button on second page', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Morning Burn');
      await tester.pump();

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('BACK'), findsOneWidget);
    });

    testWidgets('BACK button navigates to previous page', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Morning Burn');
      await tester.pump();

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Choose Burpee Type'), findsOneWidget);

      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();

      expect(find.text('Name Your Workout'), findsOneWidget);
    });

    testWidgets('navigates through all pages in order', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Page 1: Name
      expect(find.text('Name Your Workout'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Test Workout');
      await tester.pump();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Page 2: Burpee Type
      expect(find.text('Choose Burpee Type'), findsOneWidget);
      expect(find.text('Step 2 of 8'), findsOneWidget);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Page 3: Initial Countdown
      expect(find.text('Initial Countdown'), findsOneWidget);
      expect(find.text('Step 3 of 8'), findsOneWidget);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Page 4: Number of Sets
      expect(find.text('Number of Sets'), findsOneWidget);
      expect(find.text('Step 4 of 8'), findsOneWidget);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Page 5: Seconds per Set
      expect(find.text('Seconds per Set'), findsOneWidget);
      expect(find.text('Step 5 of 8'), findsOneWidget);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Page 6: Reps per Set
      expect(find.text('Reps per Set'), findsOneWidget);
      expect(find.text('Step 6 of 8'), findsOneWidget);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Page 7: Rest Between Sets
      expect(find.text('Rest Between Sets'), findsOneWidget);
      expect(find.text('Step 7 of 8'), findsOneWidget);
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Page 8: Review
      expect(find.text('Review Your Workout'), findsOneWidget);
      expect(find.text('Step 8 of 8'), findsOneWidget);
      expect(find.text('SAVE WORKOUT'), findsOneWidget);
    });

    testWidgets('displays burpee type options on page 2', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Test Workout');
      await tester.pump();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('6-Count Military Burpee'), findsOneWidget);
      expect(find.text('Navy Seal Burpee'), findsOneWidget);
      expect(find.byType(Radio<BurpeeType>), findsNWidgets(2));
    });

    testWidgets('can select burpee type', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Test Workout');
      await tester.pump();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Tap on the card containing Navy Seal Burpee
      await tester.tap(find.ancestor(
        of: find.text('Navy Seal Burpee'),
        matching: find.byType(Card),
      ));
      await tester.pumpAndSettle();

      // Verify the radio button for Navy Seal is now selected
      final radioButtons =
          tester.widgetList<Radio<BurpeeType>>(find.byType(Radio<BurpeeType>));
      final navySealRadio = radioButtons
          .where((radio) => radio.value == BurpeeType.navySeal)
          .first;
      expect(navySealRadio.groupValue, equals(BurpeeType.navySeal));
    });

    testWidgets('number input pages have increment/decrement buttons',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Test Workout');
      await tester.pump();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('can increment value on number input page', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Test Workout');
      await tester.pump();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Go to Initial Countdown page
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Default value should be 10
      expect(find.text('10'), findsWidgets);

      // Tap increment button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // Value should now be 11
      expect(find.text('11'), findsWidgets);
    });

    testWidgets('can decrement value on number input page', (tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextField), 'Test Workout');
      await tester.pump();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Go to Initial Countdown page
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Default value should be 10
      expect(find.text('10'), findsWidgets);

      // Tap decrement button
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // Value should now be 9
      expect(find.text('9'), findsWidgets);
    });

    testWidgets('review page shows all entered values', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Navigate through all pages
      await tester.enterText(find.byType(TextField), 'Test Workout');
      await tester.pump();

      for (int i = 0; i < 7; i++) {
        await tester.tap(find.text('NEXT'));
        await tester.pumpAndSettle();
      }

      // Review page should show all values
      expect(find.text('Review Your Workout'), findsOneWidget);
      expect(find.text('Test Workout'), findsOneWidget);
      expect(find.text('6-Count Military Burpee'), findsOneWidget);
      expect(find.text('Total Workout Time'), findsOneWidget);
    });

    testWidgets('initializes with existing template values', (tester) async {
      final existingTemplate = WorkoutTemplate(
        id: 'test-id',
        name: 'Existing Workout',
        burpeeType: BurpeeType.navySeal,
        repsPerSet: 8,
        secondsPerSet: 25,
        numberOfSets: 12,
        restBetweenSets: 8,
        initialCountdown: 5,
      );

      await tester.pumpWidget(createTestWidget(existingTemplate: existingTemplate));

      // Check name is pre-filled
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('Existing Workout'));

      // Navigate to burpee type page
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      // Check burpee type is pre-selected by checking the groupValue
      final radioButtons =
          tester.widgetList<Radio<BurpeeType>>(find.byType(Radio<BurpeeType>));
      final navySealRadio = radioButtons
          .where((radio) => radio.value == BurpeeType.navySeal)
          .first;
      expect(navySealRadio.groupValue, equals(BurpeeType.navySeal));
    });

    testWidgets('app bar title shows "Create Workout" for new template',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Create Workout'), findsOneWidget);
    });

    testWidgets('app bar title shows "Edit Workout" for existing template',
        (tester) async {
      final existingTemplate = WorkoutTemplate(
        id: 'test-id',
        name: 'Existing Workout',
        burpeeType: BurpeeType.militarySixCount,
        repsPerSet: 5,
        secondsPerSet: 20,
        numberOfSets: 10,
        restBetweenSets: 4,
        initialCountdown: 10,
      );

      await tester.pumpWidget(createTestWidget(existingTemplate: existingTemplate));

      expect(find.text('Edit Workout'), findsOneWidget);
    });

    testWidgets('progress indicator updates correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Step 1 of 8'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Test');
      await tester.pump();
      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Step 2 of 8'), findsOneWidget);

      await tester.tap(find.text('NEXT'));
      await tester.pumpAndSettle();

      expect(find.text('Step 3 of 8'), findsOneWidget);
    });
  });
}
