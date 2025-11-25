import 'package:flutter_test/flutter_test.dart';
import 'package:burpeebata/models/workout_template.dart';
import 'package:burpeebata/models/workout_config.dart';
import 'package:burpeebata/models/burpee_type.dart';

void main() {
  group('WorkoutTemplate', () {
    late WorkoutTemplate template;
    final testDate = DateTime(2024, 1, 15, 10, 30);

    setUp(() {
      template = WorkoutTemplate(
        id: 'test-id-123',
        name: 'Morning Burn',
        burpeeType: BurpeeType.militarySixCount,
        repsPerSet: 10,
        secondsPerSet: 20,
        numberOfSets: 8,
        restBetweenSets: 10,
        initialCountdown: 10,
        createdAt: testDate,
      );
    });

    group('constructor', () {
      test('creates template with all properties', () {
        expect(template.id, equals('test-id-123'));
        expect(template.name, equals('Morning Burn'));
        expect(template.burpeeType, equals(BurpeeType.militarySixCount));
        expect(template.repsPerSet, equals(10));
        expect(template.secondsPerSet, equals(20));
        expect(template.numberOfSets, equals(8));
        expect(template.restBetweenSets, equals(10));
        expect(template.initialCountdown, equals(10));
        expect(template.createdAt, equals(testDate));
      });

      test('generates UUID when id not provided', () {
        final template1 = WorkoutTemplate(
          name: 'Test 1',
          burpeeType: BurpeeType.militarySixCount,
          repsPerSet: 5,
          secondsPerSet: 20,
          numberOfSets: 10,
          restBetweenSets: 4,
          initialCountdown: 10,
        );

        final template2 = WorkoutTemplate(
          name: 'Test 2',
          burpeeType: BurpeeType.militarySixCount,
          repsPerSet: 5,
          secondsPerSet: 20,
          numberOfSets: 10,
          restBetweenSets: 4,
          initialCountdown: 10,
        );

        expect(template1.id, isNotEmpty);
        expect(template2.id, isNotEmpty);
        expect(template1.id, isNot(equals(template2.id)));
      });

      test('uses current time when createdAt not provided', () {
        final before = DateTime.now();
        final template = WorkoutTemplate(
          name: 'Test',
          burpeeType: BurpeeType.militarySixCount,
          repsPerSet: 5,
          secondsPerSet: 20,
          numberOfSets: 10,
          restBetweenSets: 4,
          initialCountdown: 10,
        );
        final after = DateTime.now();

        expect(template.createdAt.isAfter(before.subtract(const Duration(seconds: 1))),
            isTrue);
        expect(template.createdAt.isBefore(after.add(const Duration(seconds: 1))),
            isTrue);
      });
    });

    group('fromConfig', () {
      test('creates template from WorkoutConfig', () {
        final config = WorkoutConfig(
          burpeeType: BurpeeType.navySeal,
          repsPerSet: 2,
          secondsPerSet: 15,
          numberOfSets: 10,
          restBetweenSets: 13,
          initialCountdown: 5,
        );

        final template = WorkoutTemplate.fromConfig(
          name: 'Navy Seal Workout',
          config: config,
        );

        expect(template.name, equals('Navy Seal Workout'));
        expect(template.burpeeType, equals(BurpeeType.navySeal));
        expect(template.repsPerSet, equals(2));
        expect(template.secondsPerSet, equals(15));
        expect(template.numberOfSets, equals(10));
        expect(template.restBetweenSets, equals(13));
        expect(template.initialCountdown, equals(5));
      });
    });

    group('toConfig', () {
      test('converts template to WorkoutConfig', () {
        final config = template.toConfig();

        expect(config.burpeeType, equals(template.burpeeType));
        expect(config.repsPerSet, equals(template.repsPerSet));
        expect(config.secondsPerSet, equals(template.secondsPerSet));
        expect(config.numberOfSets, equals(template.numberOfSets));
        expect(config.restBetweenSets, equals(template.restBetweenSets));
        expect(config.initialCountdown, equals(template.initialCountdown));
      });
    });

    group('copyWith', () {
      test('creates copy with updated values', () {
        final copy = template.copyWith(
          name: 'Evening Burn',
          numberOfSets: 12,
        );

        expect(copy.id, equals(template.id));
        expect(copy.name, equals('Evening Burn'));
        expect(copy.numberOfSets, equals(12));
        expect(copy.repsPerSet, equals(template.repsPerSet));
        expect(copy.burpeeType, equals(template.burpeeType));
      });

      test('creates exact copy when no parameters provided', () {
        final copy = template.copyWith();

        expect(copy.id, equals(template.id));
        expect(copy.name, equals(template.name));
        expect(copy.burpeeType, equals(template.burpeeType));
        expect(copy.repsPerSet, equals(template.repsPerSet));
        expect(copy.createdAt, equals(template.createdAt));
      });
    });

    group('totalWorkoutSeconds', () {
      test('calculates total workout time correctly', () {
        // 8 sets * 20 seconds + 7 rest periods * 10 seconds = 160 + 70 = 230
        expect(template.totalWorkoutSeconds, equals(230));
      });

      test('handles single set workout', () {
        final singleSetTemplate = template.copyWith(numberOfSets: 1);
        // 1 set * 20 seconds + 0 rest periods = 20
        expect(singleSetTemplate.totalWorkoutSeconds, equals(20));
      });
    });

    group('totalWorkoutDuration', () {
      test('returns correct Duration', () {
        expect(
            template.totalWorkoutDuration, equals(const Duration(seconds: 230)));
      });
    });

    group('formattedDuration', () {
      test('formats duration correctly', () {
        expect(template.formattedDuration, equals('3:50'));
      });

      test('handles single digit seconds', () {
        final shortTemplate = template.copyWith(
          numberOfSets: 1,
          secondsPerSet: 5,
        );
        expect(shortTemplate.formattedDuration, equals('0:05'));
      });

      test('handles zero duration', () {
        final zeroTemplate = template.copyWith(
          numberOfSets: 1,
          secondsPerSet: 0,
        );
        expect(zeroTemplate.formattedDuration, equals('0:00'));
      });
    });

    group('JSON serialization', () {
      test('toJson produces correct map', () {
        final json = template.toJson();

        expect(json['id'], equals('test-id-123'));
        expect(json['name'], equals('Morning Burn'));
        expect(json['burpeeType'], equals(0));
        expect(json['repsPerSet'], equals(10));
        expect(json['secondsPerSet'], equals(20));
        expect(json['numberOfSets'], equals(8));
        expect(json['restBetweenSets'], equals(10));
        expect(json['initialCountdown'], equals(10));
        expect(json['createdAt'], equals('2024-01-15T10:30:00.000'));
      });

      test('fromJson creates correct WorkoutTemplate', () {
        final json = {
          'id': 'json-id',
          'name': 'Evening Session',
          'burpeeType': 1,
          'repsPerSet': 15,
          'secondsPerSet': 30,
          'numberOfSets': 5,
          'restBetweenSets': 15,
          'initialCountdown': 5,
          'createdAt': '2024-02-20T14:00:00.000',
        };

        final fromJson = WorkoutTemplate.fromJson(json);

        expect(fromJson.id, equals('json-id'));
        expect(fromJson.name, equals('Evening Session'));
        expect(fromJson.burpeeType, equals(BurpeeType.navySeal));
        expect(fromJson.repsPerSet, equals(15));
        expect(fromJson.secondsPerSet, equals(30));
        expect(fromJson.numberOfSets, equals(5));
        expect(fromJson.restBetweenSets, equals(15));
        expect(fromJson.initialCountdown, equals(5));
        expect(fromJson.createdAt, equals(DateTime(2024, 2, 20, 14, 0)));
      });

      test('round-trip serialization preserves data', () {
        final json = template.toJson();
        final restored = WorkoutTemplate.fromJson(json);

        expect(restored.id, equals(template.id));
        expect(restored.name, equals(template.name));
        expect(restored.burpeeType, equals(template.burpeeType));
        expect(restored.repsPerSet, equals(template.repsPerSet));
        expect(restored.createdAt, equals(template.createdAt));
      });

      test('toJsonString and fromJsonString work correctly', () {
        final jsonString = template.toJsonString();
        final restored = WorkoutTemplate.fromJsonString(jsonString);

        expect(restored.id, equals(template.id));
        expect(restored.name, equals(template.name));
        expect(restored.repsPerSet, equals(template.repsPerSet));
      });
    });
  });
}
