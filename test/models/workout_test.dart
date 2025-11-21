import 'package:flutter_test/flutter_test.dart';
import 'package:burpeebata/models/workout.dart';
import 'package:burpeebata/models/burpee_type.dart';

void main() {
  group('Workout', () {
    late Workout workout;

    setUp(() {
      workout = Workout(
        id: 'test-id-123',
        date: DateTime(2024, 1, 15, 10, 30),
        burpeeType: BurpeeType.militarySixCount,
        repsPerSet: 10,
        secondsPerSet: 20,
        numberOfSets: 8,
        restBetweenSets: 10,
        completed: true,
        completedSets: 8,
      );
    });

    group('totalReps', () {
      test('calculates total reps correctly', () {
        expect(workout.totalReps, equals(80));
      });

      test('returns zero when no sets completed', () {
        final incompleteWorkout = workout.copyWith(completedSets: 0);
        expect(incompleteWorkout.totalReps, equals(0));
      });

      test('calculates partial completion correctly', () {
        final partialWorkout = workout.copyWith(completedSets: 3);
        expect(partialWorkout.totalReps, equals(30));
      });
    });

    group('totalWorkoutSeconds', () {
      test('calculates total workout time correctly', () {
        // 8 sets * 20 seconds + 7 rest periods * 10 seconds = 160 + 70 = 230
        expect(workout.totalWorkoutSeconds, equals(230));
      });

      test('handles single set workout', () {
        final singleSetWorkout = workout.copyWith(numberOfSets: 1);
        // 1 set * 20 seconds + 0 rest periods = 20
        expect(singleSetWorkout.totalWorkoutSeconds, equals(20));
      });
    });

    group('totalWorkoutDuration', () {
      test('returns correct Duration', () {
        expect(workout.totalWorkoutDuration, equals(const Duration(seconds: 230)));
      });
    });

    group('copyWith', () {
      test('creates copy with updated values', () {
        final copy = workout.copyWith(
          completedSets: 5,
          completed: false,
        );

        expect(copy.id, equals(workout.id));
        expect(copy.completedSets, equals(5));
        expect(copy.completed, equals(false));
        expect(copy.repsPerSet, equals(workout.repsPerSet));
      });

      test('creates exact copy when no parameters provided', () {
        final copy = workout.copyWith();

        expect(copy.id, equals(workout.id));
        expect(copy.date, equals(workout.date));
        expect(copy.burpeeType, equals(workout.burpeeType));
        expect(copy.completedSets, equals(workout.completedSets));
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct map', () {
        final json = workout.toJson();

        expect(json['id'], equals('test-id-123'));
        expect(json['date'], equals('2024-01-15T10:30:00.000'));
        expect(json['burpeeType'], equals(0));
        expect(json['repsPerSet'], equals(10));
        expect(json['secondsPerSet'], equals(20));
        expect(json['numberOfSets'], equals(8));
        expect(json['restBetweenSets'], equals(10));
        expect(json['completed'], equals(true));
        expect(json['completedSets'], equals(8));
      });

      test('fromJson creates correct Workout', () {
        final json = {
          'id': 'json-id',
          'date': '2024-02-20T14:00:00.000',
          'burpeeType': 1,
          'repsPerSet': 15,
          'secondsPerSet': 30,
          'numberOfSets': 5,
          'restBetweenSets': 15,
          'completed': false,
          'completedSets': 3,
        };

        final fromJson = Workout.fromJson(json);

        expect(fromJson.id, equals('json-id'));
        expect(fromJson.date, equals(DateTime(2024, 2, 20, 14, 0)));
        expect(fromJson.burpeeType, equals(BurpeeType.navySeal));
        expect(fromJson.repsPerSet, equals(15));
        expect(fromJson.secondsPerSet, equals(30));
        expect(fromJson.numberOfSets, equals(5));
        expect(fromJson.restBetweenSets, equals(15));
        expect(fromJson.completed, equals(false));
        expect(fromJson.completedSets, equals(3));
      });

      test('round-trip serialization preserves data', () {
        final json = workout.toJson();
        final restored = Workout.fromJson(json);

        expect(restored.id, equals(workout.id));
        expect(restored.date, equals(workout.date));
        expect(restored.burpeeType, equals(workout.burpeeType));
        expect(restored.repsPerSet, equals(workout.repsPerSet));
        expect(restored.completedSets, equals(workout.completedSets));
      });

      test('toJsonString and fromJsonString work correctly', () {
        final jsonString = workout.toJsonString();
        final restored = Workout.fromJsonString(jsonString);

        expect(restored.id, equals(workout.id));
        expect(restored.completedSets, equals(workout.completedSets));
      });
    });

    group('shareText', () {
      test('generates correct text for completed workout', () {
        final text = workout.shareText;

        expect(text, contains('BurpeeBata Workout'));
        expect(text, contains('1/15/2024'));
        expect(text, contains('Completed'));
        expect(text, contains('6-Count Military Burpee'));
        expect(text, contains('Sets: 8/8'));
        expect(text, contains('Total Reps: 80'));
      });

      test('generates correct text for incomplete workout', () {
        final incomplete = workout.copyWith(completed: false, completedSets: 5);
        final text = incomplete.shareText;

        expect(text, contains('Attempted'));
        expect(text, contains('Sets: 5/8'));
        expect(text, contains('Total Reps: 50'));
      });
    });

    group('default values', () {
      test('completed defaults to false', () {
        final defaultWorkout = Workout(
          id: 'id',
          date: DateTime.now(),
          burpeeType: BurpeeType.militarySixCount,
          repsPerSet: 10,
          secondsPerSet: 20,
          numberOfSets: 8,
          restBetweenSets: 10,
        );

        expect(defaultWorkout.completed, equals(false));
        expect(defaultWorkout.completedSets, equals(0));
      });
    });
  });
}
