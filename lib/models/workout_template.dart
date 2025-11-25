import 'dart:convert';
import 'package:uuid/uuid.dart';
import 'burpee_type.dart';
import 'workout_config.dart';

class WorkoutTemplate {
  final String id;
  final String name;
  final BurpeeType burpeeType;
  final int repsPerSet;
  final int secondsPerSet;
  final int numberOfSets;
  final int restBetweenSets;
  final int initialCountdown;
  final DateTime createdAt;

  WorkoutTemplate({
    String? id,
    required this.name,
    required this.burpeeType,
    required this.repsPerSet,
    required this.secondsPerSet,
    required this.numberOfSets,
    required this.restBetweenSets,
    required this.initialCountdown,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  factory WorkoutTemplate.fromConfig({
    required String name,
    required WorkoutConfig config,
  }) {
    return WorkoutTemplate(
      name: name,
      burpeeType: config.burpeeType,
      repsPerSet: config.repsPerSet,
      secondsPerSet: config.secondsPerSet,
      numberOfSets: config.numberOfSets,
      restBetweenSets: config.restBetweenSets,
      initialCountdown: config.initialCountdown,
    );
  }

  WorkoutConfig toConfig() {
    return WorkoutConfig(
      burpeeType: burpeeType,
      repsPerSet: repsPerSet,
      secondsPerSet: secondsPerSet,
      numberOfSets: numberOfSets,
      restBetweenSets: restBetweenSets,
      initialCountdown: initialCountdown,
    );
  }

  WorkoutTemplate copyWith({
    String? id,
    String? name,
    BurpeeType? burpeeType,
    int? repsPerSet,
    int? secondsPerSet,
    int? numberOfSets,
    int? restBetweenSets,
    int? initialCountdown,
    DateTime? createdAt,
  }) {
    return WorkoutTemplate(
      id: id ?? this.id,
      name: name ?? this.name,
      burpeeType: burpeeType ?? this.burpeeType,
      repsPerSet: repsPerSet ?? this.repsPerSet,
      secondsPerSet: secondsPerSet ?? this.secondsPerSet,
      numberOfSets: numberOfSets ?? this.numberOfSets,
      restBetweenSets: restBetweenSets ?? this.restBetweenSets,
      initialCountdown: initialCountdown ?? this.initialCountdown,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get totalWorkoutSeconds =>
      (secondsPerSet * numberOfSets) + (restBetweenSets * (numberOfSets - 1));

  Duration get totalWorkoutDuration => Duration(seconds: totalWorkoutSeconds);

  String get formattedDuration {
    final duration = totalWorkoutDuration;
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'burpeeType': burpeeType.index,
      'repsPerSet': repsPerSet,
      'secondsPerSet': secondsPerSet,
      'numberOfSets': numberOfSets,
      'restBetweenSets': restBetweenSets,
      'initialCountdown': initialCountdown,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      burpeeType: BurpeeType.values[json['burpeeType'] as int],
      repsPerSet: json['repsPerSet'] as int,
      secondsPerSet: json['secondsPerSet'] as int,
      numberOfSets: json['numberOfSets'] as int,
      restBetweenSets: json['restBetweenSets'] as int,
      initialCountdown: json['initialCountdown'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory WorkoutTemplate.fromJsonString(String jsonString) {
    return WorkoutTemplate.fromJson(
        jsonDecode(jsonString) as Map<String, dynamic>);
  }
}
