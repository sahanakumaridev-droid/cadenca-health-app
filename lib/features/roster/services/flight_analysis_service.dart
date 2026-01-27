import '../domain/entities/flight.dart';
import '../domain/entities/flight_analysis.dart';

class FlightAnalysisService {
  static FlightAnalysis analyzeFlights(
    Flight firstFlight,
    Flight secondFlight,
  ) {
    final layoverDuration = secondFlight.departureTime.difference(
      firstFlight.arrivalTime,
    );
    final layoverType = _determineLayoverType(layoverDuration);

    final sleepWindow = _calculateSleepWindow(
      firstFlight.arrivalTime,
      secondFlight.departureTime,
      layoverType,
    );

    final mealWindows = _calculateMealWindows(
      firstFlight.arrivalTime,
      secondFlight.departureTime,
      layoverType,
    );

    return FlightAnalysis(
      firstFlight: firstFlight,
      secondFlight: secondFlight,
      layoverDuration: layoverDuration,
      sleepWindow: sleepWindow,
      mealWindows: mealWindows,
      layoverType: layoverType,
    );
  }

  static LayoverType _determineLayoverType(Duration layoverDuration) {
    final hours = layoverDuration.inHours;

    if (hours < 2) return LayoverType.quickTurnaround;
    if (hours < 8) return LayoverType.shortLayover;
    if (hours < 24) return LayoverType.longLayover;
    return LayoverType.overnight;
  }

  static SleepWindow _calculateSleepWindow(
    DateTime arrivalTime,
    DateTime departureTime,
    LayoverType layoverType,
  ) {
    switch (layoverType) {
      case LayoverType.quickTurnaround:
        return SleepWindow(
          startTime: arrivalTime,
          endTime: arrivalTime,
          duration: Duration.zero,
          quality: SleepQuality.none,
          recommendation: 'No sleep possible - quick turnaround',
        );

      case LayoverType.shortLayover:
        final sleepStart = arrivalTime.add(const Duration(hours: 1));
        final sleepEnd = departureTime.subtract(const Duration(hours: 2));
        final sleepDuration = sleepEnd.difference(sleepStart);

        return SleepWindow(
          startTime: sleepStart,
          endTime: sleepEnd,
          duration: sleepDuration,
          quality: sleepDuration.inHours >= 4
              ? SleepQuality.fair
              : SleepQuality.poor,
          recommendation: sleepDuration.inHours >= 4
              ? 'Power nap recommended (${sleepDuration.inHours}h ${sleepDuration.inMinutes % 60}m)'
              : 'Rest only - too short for quality sleep',
        );

      case LayoverType.longLayover:
      case LayoverType.overnight:
        final sleepStart = arrivalTime.add(const Duration(hours: 2));
        final sleepEnd = departureTime.subtract(const Duration(hours: 3));
        final sleepDuration = sleepEnd.difference(sleepStart);

        return SleepWindow(
          startTime: sleepStart,
          endTime: sleepEnd,
          duration: sleepDuration,
          quality: sleepDuration.inHours >= 8
              ? SleepQuality.excellent
              : SleepQuality.good,
          recommendation:
              'Full sleep cycle possible (${sleepDuration.inHours}h ${sleepDuration.inMinutes % 60}m)',
        );
    }
  }

  static List<MealWindow> _calculateMealWindows(
    DateTime arrivalTime,
    DateTime departureTime,
    LayoverType layoverType,
  ) {
    final meals = <MealWindow>[];

    switch (layoverType) {
      case LayoverType.quickTurnaround:
        meals.add(
          MealWindow(
            time: arrivalTime.add(const Duration(minutes: 15)),
            type: MealType.snack,
            recommendation: 'Quick snack at gate',
            location: 'Airport gate area',
          ),
        );
        break;

      case LayoverType.shortLayover:
        // Arrival meal
        meals.add(
          MealWindow(
            time: arrivalTime.add(const Duration(minutes: 45)),
            type: _getMealTypeByHour(arrivalTime.hour),
            recommendation: 'Light meal after arrival',
            location: 'Airport restaurant',
          ),
        );

        // Pre-departure snack if enough time
        if (departureTime.difference(arrivalTime).inHours >= 4) {
          meals.add(
            MealWindow(
              time: departureTime.subtract(
                const Duration(hours: 1, minutes: 30),
              ),
              type: MealType.snack,
              recommendation: 'Pre-flight snack',
              location: 'Airport cafe',
            ),
          );
        }
        break;

      case LayoverType.longLayover:
      case LayoverType.overnight:
        // Post-arrival meal
        meals.add(
          MealWindow(
            time: arrivalTime.add(const Duration(hours: 1)),
            type: _getMealTypeByHour(arrivalTime.hour),
            recommendation: 'Full meal after arrival',
            location: 'Hotel restaurant or city',
          ),
        );

        // Mid-layover meal
        final midTime = arrivalTime.add(
          Duration(
            milliseconds:
                departureTime.difference(arrivalTime).inMilliseconds ~/ 2,
          ),
        );
        meals.add(
          MealWindow(
            time: midTime,
            type: _getMealTypeByHour(midTime.hour),
            recommendation: 'Main meal during layover',
            location: 'Hotel or local restaurant',
          ),
        );

        // Pre-departure meal
        meals.add(
          MealWindow(
            time: departureTime.subtract(const Duration(hours: 2)),
            type: _getMealTypeByHour(
              departureTime.subtract(const Duration(hours: 2)).hour,
            ),
            recommendation: 'Light meal before departure',
            location: 'Hotel or airport',
          ),
        );
        break;
    }

    return meals;
  }

  static MealType _getMealTypeByHour(int hour) {
    if (hour >= 6 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 16) return MealType.lunch;
    if (hour >= 16 && hour < 22) return MealType.dinner;
    return MealType.snack;
  }
}
