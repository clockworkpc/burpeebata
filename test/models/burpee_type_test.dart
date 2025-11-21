import 'package:flutter_test/flutter_test.dart';
import 'package:burpeebata/models/burpee_type.dart';

void main() {
  group('BurpeeType', () {
    group('enum values', () {
      test('has correct number of values', () {
        expect(BurpeeType.values.length, equals(2));
      });

      test('has militarySixCount at index 0', () {
        expect(BurpeeType.values[0], equals(BurpeeType.militarySixCount));
      });

      test('has navySeal at index 1', () {
        expect(BurpeeType.values[1], equals(BurpeeType.navySeal));
      });
    });

    group('displayName', () {
      test('militarySixCount has correct display name', () {
        expect(
          BurpeeType.militarySixCount.displayName,
          equals('6-Count Military Burpee'),
        );
      });

      test('navySeal has correct display name', () {
        expect(
          BurpeeType.navySeal.displayName,
          equals('Navy Seal Burpee'),
        );
      });
    });

    group('description', () {
      test('militarySixCount has correct description', () {
        final description = BurpeeType.militarySixCount.description;

        expect(description, contains('six-part compound movement'));
        expect(description, contains('leg and posterior chain'));
        expect(description, contains('cardiovascular fitness'));
      });

      test('navySeal has correct description', () {
        final description = BurpeeType.navySeal.description;

        expect(description, contains('10 component parts'));
        expect(description, contains('Upper body dominates'));
        expect(description, contains('muscle mass'));
      });
    });

    group('componentCount', () {
      test('militarySixCount has 6 components', () {
        expect(BurpeeType.militarySixCount.componentCount, equals(6));
      });

      test('navySeal has 10 components', () {
        expect(BurpeeType.navySeal.componentCount, equals(10));
      });
    });
  });
}
