import 'flight.dart';

class SleepAnalysis {
  final Flight flight;
  final Flight? nextFlight;
  final DateTime dutyEndTime;
  final DateTime nextDutyStartTime;
  final Duration layoverDuration;
  final List<SleepRecommendation> sleepRecommendations;
  final List<MealRecommendation> mealRecommendations;
  final List<MovementRecommendation> movementRecommendations;
  final List<NapRecommendation> napRecommendations;
  final TimezoneStrategy timezoneStrategy;

  const SleepAnalysis({
    required this.flight,
    this.nextFlight,
    required this.dutyEndTime,
    required this.nextDutyStartTime,
    required this.layoverDuration,
    required this.sleepRecommendations,
    required this.mealRecommendations,
    required this.movementRecommendations,
    required this.napRecommendations,
    required this.timezoneStrategy,
  });
}

class SleepRecommendation {
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final SleepType type;
  final TimezoneStrategy strategy;
  final String recommendation;
  final DateTime localTime;
  final DateTime homeTime;

  const SleepRecommendation({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.type,
    required this.strategy,
    required this.recommendation,
    required this.localTime,
    required this.homeTime,
  });
}

class MealRecommendation {
  final DateTime time;
  final MealType type;
  final MealType homeTimeType;
  final TimezoneStrategy strategy;
  final String recommendation;
  final DateTime localTime;
  final DateTime homeTime;
  final String location;

  const MealRecommendation({
    required this.time,
    required this.type,
    required this.homeTimeType,
    required this.strategy,
    required this.recommendation,
    required this.localTime,
    required this.homeTime,
    required this.location,
  });
}

class MovementRecommendation {
  final DateTime time;
  final Duration duration;
  final MovementType type;
  final MovementIntensity intensity;
  final String recommendation;
  final DateTime localTime;
  final DateTime homeTime;
  final String location;

  const MovementRecommendation({
    required this.time,
    required this.duration,
    required this.type,
    required this.intensity,
    required this.recommendation,
    required this.localTime,
    required this.homeTime,
    required this.location,
  });
}

class NapRecommendation {
  final DateTime time;
  final Duration duration;
  final NapType type;
  final String recommendation;
  final DateTime localTime;
  final DateTime homeTime;

  const NapRecommendation({
    required this.time,
    required this.duration,
    required this.type,
    required this.recommendation,
    required this.localTime,
    required this.homeTime,
  });
}

enum SleepType { mainSleep, strategicNap, rest }

enum MealType { breakfast, lunch, dinner, snack }

enum MovementType { lightExposure, exercise, stretching }

enum MovementIntensity { light, moderate, vigorous }

enum NapType { powerNap, strategic }

enum TimezoneStrategy { adaptToLocal, maintainHome, hybrid }
