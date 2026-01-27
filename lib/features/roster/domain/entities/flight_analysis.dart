import 'flight.dart';

class FlightAnalysis {
  final Flight firstFlight;
  final Flight secondFlight;
  final Duration layoverDuration;
  final SleepWindow sleepWindow;
  final List<MealWindow> mealWindows;
  final LayoverType layoverType;

  const FlightAnalysis({
    required this.firstFlight,
    required this.secondFlight,
    required this.layoverDuration,
    required this.sleepWindow,
    required this.mealWindows,
    required this.layoverType,
  });
}

class SleepWindow {
  final DateTime startTime;
  final DateTime endTime;
  final Duration duration;
  final SleepQuality quality;
  final String recommendation;

  const SleepWindow({
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.quality,
    required this.recommendation,
  });
}

class MealWindow {
  final DateTime time;
  final MealType type;
  final String recommendation;
  final String location;

  const MealWindow({
    required this.time,
    required this.type,
    required this.recommendation,
    required this.location,
  });
}

enum LayoverType {
  quickTurnaround, // < 2 hours
  shortLayover, // 2-8 hours
  longLayover, // 8-24 hours
  overnight, // > 24 hours
}

enum SleepQuality { none, poor, fair, good, excellent }

enum MealType { breakfast, lunch, dinner, snack }
