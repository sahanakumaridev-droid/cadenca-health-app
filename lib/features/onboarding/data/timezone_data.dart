// Comprehensive timezone data focused on US market with international coverage
class TimezoneData {
  static const List<Map<String, String>> usTimezones = [
    // Eastern Time Zone
    {
      'city': 'New York',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
    },
    {
      'city': 'Miami',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
    },
    {
      'city': 'Atlanta',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
    },
    {
      'city': 'Boston',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
    },
    {
      'city': 'Washington DC',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
    },
    {
      'city': 'Philadelphia',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
    },
    {
      'city': 'Orlando',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
    },
    {
      'city': 'Charlotte',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
    },

    // Central Time Zone
    {
      'city': 'Chicago',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
    },
    {
      'city': 'Dallas',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
    },
    {
      'city': 'Houston',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
    },
    {
      'city': 'Austin',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
    },
    {
      'city': 'San Antonio',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
    },
    {
      'city': 'New Orleans',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
    },
    {
      'city': 'Minneapolis',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
    },
    {
      'city': 'Kansas City',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
    },

    // Mountain Time Zone
    {
      'city': 'Denver',
      'code': 'MST/MDT',
      'offset': '-7:00',
      'region': 'US Mountain',
    },
    {
      'city': 'Phoenix',
      'code': 'MST',
      'offset': '-7:00',
      'region': 'US Mountain',
    },
    {
      'city': 'Salt Lake City',
      'code': 'MST/MDT',
      'offset': '-7:00',
      'region': 'US Mountain',
    },
    {
      'city': 'Albuquerque',
      'code': 'MST/MDT',
      'offset': '-7:00',
      'region': 'US Mountain',
    },
    {
      'city': 'Bozeman',
      'code': 'MST/MDT',
      'offset': '-7:00',
      'region': 'US Mountain',
    },

    // Pacific Time Zone
    {
      'city': 'Los Angeles',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
    },
    {
      'city': 'San Francisco',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
    },
    {
      'city': 'Seattle',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
    },
    {
      'city': 'San Diego',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
    },
    {
      'city': 'Las Vegas',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
    },
    {
      'city': 'Portland',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
    },

    // Alaska & Hawaii
    {
      'city': 'Anchorage',
      'code': 'AKST/AKDT',
      'offset': '-9:00',
      'region': 'US Alaska',
    },
    {
      'city': 'Honolulu',
      'code': 'HST',
      'offset': '-10:00',
      'region': 'US Hawaii',
    },
  ];

  static const List<Map<String, String>> internationalTimezones = [
    // Major International Destinations (for airline crew)
    {
      'city': 'London',
      'code': 'GMT/BST',
      'offset': '+0:00',
      'region': 'Europe',
    },
    {
      'city': 'Paris',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
    },
    {
      'city': 'Frankfurt',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
    },
    {
      'city': 'Amsterdam',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
    },
    {'city': 'Rome', 'code': 'CET/CEST', 'offset': '+1:00', 'region': 'Europe'},
    {
      'city': 'Madrid',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
    },
    {
      'city': 'Zurich',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
    },

    // Middle East & Africa
    {
      'city': 'Dubai',
      'code': 'GST',
      'offset': '+4:00',
      'region': 'Middle East',
    },
    {'city': 'Doha', 'code': 'AST', 'offset': '+3:00', 'region': 'Middle East'},
    {
      'city': 'Istanbul',
      'code': 'TRT',
      'offset': '+3:00',
      'region': 'Middle East',
    },
    {'city': 'Cairo', 'code': 'EET', 'offset': '+2:00', 'region': 'Africa'},
    {
      'city': 'Johannesburg',
      'code': 'SAST',
      'offset': '+2:00',
      'region': 'Africa',
    },

    // Asia Pacific
    {'city': 'Tokyo', 'code': 'JST', 'offset': '+9:00', 'region': 'Asia'},
    {'city': 'Seoul', 'code': 'KST', 'offset': '+9:00', 'region': 'Asia'},
    {'city': 'Beijing', 'code': 'CST', 'offset': '+8:00', 'region': 'Asia'},
    {'city': 'Shanghai', 'code': 'CST', 'offset': '+8:00', 'region': 'Asia'},
    {'city': 'Hong Kong', 'code': 'HKT', 'offset': '+8:00', 'region': 'Asia'},
    {'city': 'Singapore', 'code': 'SGT', 'offset': '+8:00', 'region': 'Asia'},
    {'city': 'Bangkok', 'code': 'ICT', 'offset': '+7:00', 'region': 'Asia'},
    {'city': 'Mumbai', 'code': 'IST', 'offset': '+5:30', 'region': 'Asia'},
    {'city': 'Delhi', 'code': 'IST', 'offset': '+5:30', 'region': 'Asia'},

    // Australia & New Zealand
    {
      'city': 'Sydney',
      'code': 'AEDT/AEST',
      'offset': '+11:00',
      'region': 'Oceania',
    },
    {
      'city': 'Melbourne',
      'code': 'AEDT/AEST',
      'offset': '+11:00',
      'region': 'Oceania',
    },
    {
      'city': 'Auckland',
      'code': 'NZDT/NZST',
      'offset': '+13:00',
      'region': 'Oceania',
    },

    // Americas (International)
    {
      'city': 'Toronto',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'Canada',
    },
    {
      'city': 'Vancouver',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'Canada',
    },
    {
      'city': 'Mexico City',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'Mexico',
    },
    {
      'city': 'São Paulo',
      'code': 'BRT',
      'offset': '-3:00',
      'region': 'South America',
    },
    {
      'city': 'Buenos Aires',
      'code': 'ART',
      'offset': '-3:00',
      'region': 'South America',
    },
  ];

  // Combined list with US timezones prioritized
  static List<Map<String, String>> getAllTimezones() {
    return [...usTimezones, ...internationalTimezones];
  }

  // Get popular US cities for quick selection
  static List<Map<String, String>> getPopularUSCities() {
    return [
      {
        'city': 'New York',
        'code': 'EST/EDT',
        'offset': '-5:00',
        'region': 'US East',
      },
      {
        'city': 'Los Angeles',
        'code': 'PST/PDT',
        'offset': '-8:00',
        'region': 'US West',
      },
      {
        'city': 'Chicago',
        'code': 'CST/CDT',
        'offset': '-6:00',
        'region': 'US Central',
      },
      {
        'city': 'Houston',
        'code': 'CST/CDT',
        'offset': '-6:00',
        'region': 'US Central',
      },
      {
        'city': 'Phoenix',
        'code': 'MST',
        'offset': '-7:00',
        'region': 'US Mountain',
      },
      {
        'city': 'Philadelphia',
        'code': 'EST/EDT',
        'offset': '-5:00',
        'region': 'US East',
      },
      {
        'city': 'San Antonio',
        'code': 'CST/CDT',
        'offset': '-6:00',
        'region': 'US Central',
      },
      {
        'city': 'San Diego',
        'code': 'PST/PDT',
        'offset': '-8:00',
        'region': 'US West',
      },
      {
        'city': 'Dallas',
        'code': 'CST/CDT',
        'offset': '-6:00',
        'region': 'US Central',
      },
      {
        'city': 'San Francisco',
        'code': 'PST/PDT',
        'offset': '-8:00',
        'region': 'US West',
      },
      {
        'city': 'Austin',
        'code': 'CST/CDT',
        'offset': '-6:00',
        'region': 'US Central',
      },
      {
        'city': 'Seattle',
        'code': 'PST/PDT',
        'offset': '-8:00',
        'region': 'US West',
      },
    ];
  }

  // Search function for any city
  static List<Map<String, String>> searchTimezones(String query) {
    if (query.isEmpty) return getPopularUSCities();

    final allTimezones = getAllTimezones();
    final queryLower = query.toLowerCase();

    return allTimezones.where((tz) {
      final cityLower = tz['city']!.toLowerCase();
      final codeLower = tz['code']!.toLowerCase();
      final regionLower = tz['region']!.toLowerCase();

      return cityLower.contains(queryLower) ||
          codeLower.contains(queryLower) ||
          regionLower.contains(queryLower);
    }).toList();
  }
}
