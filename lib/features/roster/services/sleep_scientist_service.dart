import '../domain/entities/flight.dart';
import '../domain/entities/sleep_analysis.dart';

class SleepScientistService {
  static const String homeTimezone = 'America/Los_Angeles'; // Pacific Time

  static SleepAnalysis analyzeFlight(Flight flight, {Flight? nextFlight}) {
    final arrivalTime = flight.arrivalTime;
    final departureTime =
        nextFlight?.departureTime ?? arrivalTime.add(const Duration(hours: 24));

    // Add 90-minute buffers
    final dutyEndTime = arrivalTime.add(const Duration(minutes: 90));
    final nextDutyStartTime = departureTime.subtract(
      const Duration(minutes: 90),
    );

    final layoverDuration = nextDutyStartTime.difference(dutyEndTime);

    return SleepAnalysis(
      flight: flight,
      nextFlight: nextFlight,
      dutyEndTime: dutyEndTime,
      nextDutyStartTime: nextDutyStartTime,
      layoverDuration: layoverDuration,
      sleepRecommendations: _calculateSleepRecommendations(
        dutyEndTime,
        nextDutyStartTime,
        flight.arrivalAirport,
      ),
      mealRecommendations: _calculateMealRecommendations(
        dutyEndTime,
        nextDutyStartTime,
        flight.arrivalAirport,
      ),
      movementRecommendations: _calculateMovementRecommendations(
        dutyEndTime,
        nextDutyStartTime,
        flight.arrivalAirport,
      ),
      napRecommendations: _calculateNapRecommendations(
        dutyEndTime,
        nextDutyStartTime,
        flight.arrivalAirport,
      ),
      timezoneStrategy: _determineTimezoneStrategy(
        layoverDuration,
        flight.arrivalAirport,
      ),
    );
  }

  static List<SleepRecommendation> _calculateSleepRecommendations(
    DateTime dutyEnd,
    DateTime nextDutyStart,
    String timezone,
  ) {
    final recommendations = <SleepRecommendation>[];
    final layoverHours = nextDutyStart.difference(dutyEnd).inHours;

    if (layoverHours >= 8) {
      // Long layover - full sleep cycle
      final sleepStart = dutyEnd.add(
        const Duration(hours: 2),
      ); // Wind down time
      final sleepEnd = nextDutyStart.subtract(
        const Duration(hours: 3),
      ); // Prep time

      recommendations.add(
        SleepRecommendation(
          startTime: sleepStart,
          endTime: sleepEnd,
          duration: sleepEnd.difference(sleepStart),
          type: SleepType.mainSleep,
          strategy: TimezoneStrategy.adaptToLocal,
          recommendation:
              'Full sleep cycle - adapt to local timezone for better recovery',
          localTime: sleepStart,
          homeTime: _convertToHomeTime(sleepStart),
        ),
      );

      // Alternative home time strategy
      final homeBasedSleep = _calculateHomeTimeSleep(dutyEnd, nextDutyStart);
      if (homeBasedSleep != null) {
        recommendations.add(homeBasedSleep);
      }
    } else if (layoverHours >= 4) {
      // Medium layover - strategic nap
      final napStart = dutyEnd.add(const Duration(hours: 1));
      final napEnd = napStart.add(const Duration(hours: 2, minutes: 30));

      recommendations.add(
        SleepRecommendation(
          startTime: napStart,
          endTime: napEnd,
          duration: napEnd.difference(napStart),
          type: SleepType.strategicNap,
          strategy: TimezoneStrategy.maintainHome,
          recommendation: 'Strategic nap - maintain home timezone rhythm',
          localTime: napStart,
          homeTime: _convertToHomeTime(napStart),
        ),
      );
    } else {
      // Short layover - rest only
      recommendations.add(
        SleepRecommendation(
          startTime: dutyEnd,
          endTime: dutyEnd.add(const Duration(minutes: 90)),
          duration: const Duration(minutes: 90),
          type: SleepType.rest,
          strategy: TimezoneStrategy.maintainHome,
          recommendation: 'Rest and relaxation only - too short for sleep',
          localTime: dutyEnd,
          homeTime: _convertToHomeTime(dutyEnd),
        ),
      );
    }

    return recommendations;
  }

  static List<MealRecommendation> _calculateMealRecommendations(
    DateTime dutyEnd,
    DateTime nextDutyStart,
    String timezone,
  ) {
    final recommendations = <MealRecommendation>[];
    final layoverHours = nextDutyStart.difference(dutyEnd).inHours;

    // Post-arrival meal
    final postArrivalMeal = dutyEnd.add(const Duration(minutes: 45));
    recommendations.add(
      MealRecommendation(
        time: postArrivalMeal,
        type: _getMealTypeByLocalTime(postArrivalMeal),
        homeTimeType: _getMealTypeByHomeTime(
          _convertToHomeTime(postArrivalMeal),
        ),
        strategy: TimezoneStrategy.adaptToLocal,
        recommendation:
            'Post-arrival meal - eat according to local time to help adaptation',
        localTime: postArrivalMeal,
        homeTime: _convertToHomeTime(postArrivalMeal),
        location: 'Airport restaurant or hotel',
      ),
    );

    if (layoverHours >= 8) {
      // Long layover - multiple meals
      final midLayoverMeal = dutyEnd.add(Duration(hours: layoverHours ~/ 2));
      recommendations.add(
        MealRecommendation(
          time: midLayoverMeal,
          type: _getMealTypeByLocalTime(midLayoverMeal),
          homeTimeType: _getMealTypeByHomeTime(
            _convertToHomeTime(midLayoverMeal),
          ),
          strategy: TimezoneStrategy.adaptToLocal,
          recommendation: 'Main meal during layover - local timezone eating',
          localTime: midLayoverMeal,
          homeTime: _convertToHomeTime(midLayoverMeal),
          location: 'Hotel restaurant or local cuisine',
        ),
      );
    }

    // Pre-departure meal
    if (layoverHours >= 3) {
      final preDepartureMeal = nextDutyStart.subtract(const Duration(hours: 2));
      recommendations.add(
        MealRecommendation(
          time: preDepartureMeal,
          type: _getMealTypeByLocalTime(preDepartureMeal),
          homeTimeType: _getMealTypeByHomeTime(
            _convertToHomeTime(preDepartureMeal),
          ),
          strategy: TimezoneStrategy.maintainHome,
          recommendation:
              'Pre-departure meal - start transitioning back to home timezone',
          localTime: preDepartureMeal,
          homeTime: _convertToHomeTime(preDepartureMeal),
          location: 'Hotel or airport',
        ),
      );
    }

    return recommendations;
  }

  static List<MovementRecommendation> _calculateMovementRecommendations(
    DateTime dutyEnd,
    DateTime nextDutyStart,
    String timezone,
  ) {
    final recommendations = <MovementRecommendation>[];
    final layoverHours = nextDutyStart.difference(dutyEnd).inHours;

    if (layoverHours >= 4) {
      // Morning light exposure (local time)
      final morningWalk = _findNextDaylightHour(dutyEnd, 7, 10);
      if (morningWalk != null &&
          morningWalk.isBefore(
            nextDutyStart.subtract(const Duration(hours: 2)),
          )) {
        recommendations.add(
          MovementRecommendation(
            time: morningWalk,
            duration: const Duration(minutes: 30),
            type: MovementType.lightExposure,
            intensity: MovementIntensity.light,
            recommendation:
                'Morning light exposure walk - helps circadian rhythm adjustment',
            localTime: morningWalk,
            homeTime: _convertToHomeTime(morningWalk),
            location:
                'Outdoor area, hotel vicinity, or airport with natural light',
          ),
        );
      }

      // Afternoon activity
      final afternoonActivity = _findNextDaylightHour(dutyEnd, 14, 17);
      if (afternoonActivity != null &&
          afternoonActivity.isBefore(
            nextDutyStart.subtract(const Duration(hours: 1)),
          )) {
        recommendations.add(
          MovementRecommendation(
            time: afternoonActivity,
            duration: const Duration(minutes: 45),
            type: MovementType.exercise,
            intensity: MovementIntensity.moderate,
            recommendation:
                'Moderate exercise - boost energy and aid sleep later',
            localTime: afternoonActivity,
            homeTime: _convertToHomeTime(afternoonActivity),
            location: 'Hotel gym, local park, or walking area',
          ),
        );
      }
    }

    // Always recommend some movement after arrival
    final postArrivalMovement = dutyEnd.add(const Duration(hours: 1));
    recommendations.add(
      MovementRecommendation(
        time: postArrivalMovement,
        duration: const Duration(minutes: 15),
        type: MovementType.stretching,
        intensity: MovementIntensity.light,
        recommendation: 'Post-flight stretching and light movement',
        localTime: postArrivalMovement,
        homeTime: _convertToHomeTime(postArrivalMovement),
        location: 'Hotel room or quiet airport area',
      ),
    );

    return recommendations;
  }

  static List<NapRecommendation> _calculateNapRecommendations(
    DateTime dutyEnd,
    DateTime nextDutyStart,
    String timezone,
  ) {
    final recommendations = <NapRecommendation>[];
    final layoverHours = nextDutyStart.difference(dutyEnd).inHours;

    if (layoverHours >= 6 && layoverHours < 12) {
      // Power nap option
      final napTime = dutyEnd.add(const Duration(hours: 3));
      if (napTime.isBefore(nextDutyStart.subtract(const Duration(hours: 4)))) {
        recommendations.add(
          NapRecommendation(
            time: napTime,
            duration: const Duration(minutes: 20),
            type: NapType.powerNap,
            recommendation:
                'Optional 20-minute power nap - avoid longer to prevent grogginess',
            localTime: napTime,
            homeTime: _convertToHomeTime(napTime),
          ),
        );
      }
    }

    if (layoverHours >= 12) {
      // Strategic nap before main sleep
      final strategicNap = dutyEnd.add(const Duration(hours: 2));
      recommendations.add(
        NapRecommendation(
          time: strategicNap,
          duration: const Duration(minutes: 30),
          type: NapType.strategic,
          recommendation: 'Strategic nap to bridge until main sleep time',
          localTime: strategicNap,
          homeTime: _convertToHomeTime(strategicNap),
        ),
      );
    }

    return recommendations;
  }

  static TimezoneStrategy _determineTimezoneStrategy(
    Duration layoverDuration,
    String timezone,
  ) {
    if (layoverDuration.inHours >= 12) {
      return TimezoneStrategy.adaptToLocal;
    } else if (layoverDuration.inHours >= 6) {
      return TimezoneStrategy.hybrid;
    } else {
      return TimezoneStrategy.maintainHome;
    }
  }

  // Helper methods
  static DateTime _convertToHomeTime(DateTime localTime) {
    // Simplified conversion - in real app, use proper timezone conversion
    return localTime.subtract(
      const Duration(hours: 8),
    ); // Assuming 8-hour difference
  }

  static SleepRecommendation? _calculateHomeTimeSleep(
    DateTime dutyEnd,
    DateTime nextDutyStart,
  ) {
    final homeTimeEnd = _convertToHomeTime(dutyEnd);
    final homeTimeStart = _convertToHomeTime(nextDutyStart);

    // Find optimal sleep window based on home timezone
    final optimalSleepStart = DateTime(
      homeTimeEnd.year,
      homeTimeEnd.month,
      homeTimeEnd.day,
      22,
    );
    final optimalSleepEnd = DateTime(
      homeTimeStart.year,
      homeTimeStart.month,
      homeTimeStart.day,
      6,
    );

    if (optimalSleepEnd.isAfter(optimalSleepStart) &&
        optimalSleepEnd.difference(optimalSleepStart).inHours >= 6) {
      return SleepRecommendation(
        startTime: _convertToLocalTime(optimalSleepStart),
        endTime: _convertToLocalTime(optimalSleepEnd),
        duration: optimalSleepEnd.difference(optimalSleepStart),
        type: SleepType.mainSleep,
        strategy: TimezoneStrategy.maintainHome,
        recommendation:
            'Sleep according to home timezone - easier transition back',
        localTime: _convertToLocalTime(optimalSleepStart),
        homeTime: optimalSleepStart,
      );
    }

    return null;
  }

  static DateTime _convertToLocalTime(DateTime homeTime) {
    // Simplified conversion - in real app, use proper timezone conversion
    return homeTime.add(const Duration(hours: 8)); // Assuming 8-hour difference
  }

  static MealType _getMealTypeByLocalTime(DateTime time) {
    final hour = time.hour;
    if (hour >= 6 && hour < 11) return MealType.breakfast;
    if (hour >= 11 && hour < 16) return MealType.lunch;
    if (hour >= 16 && hour < 22) return MealType.dinner;
    return MealType.snack;
  }

  static MealType _getMealTypeByHomeTime(DateTime homeTime) {
    return _getMealTypeByLocalTime(homeTime);
  }

  static DateTime? _findNextDaylightHour(
    DateTime start,
    int earliestHour,
    int latestHour,
  ) {
    var candidate = DateTime(start.year, start.month, start.day, earliestHour);

    // If we've passed the earliest hour today, try tomorrow
    if (candidate.isBefore(start)) {
      candidate = candidate.add(const Duration(days: 1));
    }

    // Make sure it's within the daylight window
    if (candidate.hour >= earliestHour && candidate.hour <= latestHour) {
      return candidate;
    }

    return null;
  }
}
