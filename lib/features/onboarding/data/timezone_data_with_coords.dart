// Comprehensive timezone data focused on US market with international coverage
// Now includes latitude and longitude coordinates for each city
class TimezoneData {
  static const List<Map<String, dynamic>> usTimezones = [
    // Eastern Time Zone
    {
      'city': 'New York',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
      'lat': 40.7128,
      'lng': -74.0060,
    },
    {
      'city': 'Miami',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
      'lat': 25.7617,
      'lng': -80.1918,
    },
    {
      'city': 'Atlanta',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
      'lat': 33.7490,
      'lng': -84.3880,
    },
    {
      'city': 'Boston',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
      'lat': 42.3601,
      'lng': -71.0589,
    },
    {
      'city': 'Washington DC',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
      'lat': 38.9072,
      'lng': -77.0369,
    },
    {
      'city': 'Philadelphia',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
      'lat': 39.9526,
      'lng': -75.1652,
    },
    {
      'city': 'Orlando',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
      'lat': 28.5383,
      'lng': -81.3792,
    },
    {
      'city': 'Charlotte',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'US East',
      'lat': 35.2271,
      'lng': -80.8431,
    },

    // Central Time Zone
    {
      'city': 'Chicago',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
      'lat': 41.8781,
      'lng': -87.6298,
    },
    {
      'city': 'Dallas',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
      'lat': 32.7767,
      'lng': -96.7970,
    },
    {
      'city': 'Houston',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
      'lat': 29.7604,
      'lng': -95.3698,
    },
    {
      'city': 'Austin',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
      'lat': 30.2672,
      'lng': -97.7431,
    },
    {
      'city': 'San Antonio',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
      'lat': 29.4241,
      'lng': -98.4936,
    },
    {
      'city': 'New Orleans',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
      'lat': 29.9511,
      'lng': -90.0715,
    },
    {
      'city': 'Minneapolis',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
      'lat': 44.9778,
      'lng': -93.2650,
    },
    {
      'city': 'Kansas City',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'US Central',
      'lat': 39.0997,
      'lng': -94.5786,
    },

    // Mountain Time Zone
    {
      'city': 'Denver',
      'code': 'MST/MDT',
      'offset': '-7:00',
      'region': 'US Mountain',
      'lat': 39.7392,
      'lng': -104.9903,
    },
    {
      'city': 'Phoenix',
      'code': 'MST',
      'offset': '-7:00',
      'region': 'US Mountain',
      'lat': 33.4484,
      'lng': -112.0740,
    },
    {
      'city': 'Salt Lake City',
      'code': 'MST/MDT',
      'offset': '-7:00',
      'region': 'US Mountain',
      'lat': 40.7608,
      'lng': -111.8910,
    },
    {
      'city': 'Albuquerque',
      'code': 'MST/MDT',
      'offset': '-7:00',
      'region': 'US Mountain',
      'lat': 35.0844,
      'lng': -106.6504,
    },
    {
      'city': 'Bozeman',
      'code': 'MST/MDT',
      'offset': '-7:00',
      'region': 'US Mountain',
      'lat': 45.6770,
      'lng': -111.0429,
    },

    // Pacific Time Zone
    {
      'city': 'Los Angeles',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
      'lat': 34.0522,
      'lng': -118.2437,
    },
    {
      'city': 'San Francisco',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
      'lat': 37.7749,
      'lng': -122.4194,
    },
    {
      'city': 'Seattle',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
      'lat': 47.6062,
      'lng': -122.3321,
    },
    {
      'city': 'San Diego',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
      'lat': 32.7157,
      'lng': -117.1611,
    },
    {
      'city': 'Las Vegas',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
      'lat': 36.1699,
      'lng': -115.1398,
    },
    {
      'city': 'Portland',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'US West',
      'lat': 45.5152,
      'lng': -122.6784,
    },

    // Alaska & Hawaii
    {
      'city': 'Anchorage',
      'code': 'AKST/AKDT',
      'offset': '-9:00',
      'region': 'US Alaska',
      'lat': 61.2181,
      'lng': -149.9003,
    },
    {
      'city': 'Honolulu',
      'code': 'HST',
      'offset': '-10:00',
      'region': 'US Hawaii',
      'lat': 21.3099,
      'lng': -157.8581,
    },
  ];

  static const List<Map<String, dynamic>> internationalTimezones = [
    // Major International Destinations (for airline crew)
    {
      'city': 'London',
      'code': 'GMT/BST',
      'offset': '+0:00',
      'region': 'Europe',
      'lat': 51.5074,
      'lng': -0.1278,
    },
    {
      'city': 'Paris',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
      'lat': 48.8566,
      'lng': 2.3522,
    },
    {
      'city': 'Frankfurt',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
      'lat': 50.1109,
      'lng': 8.6821,
    },
    {
      'city': 'Amsterdam',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
      'lat': 52.3676,
      'lng': 4.9041,
    },
    {
      'city': 'Rome',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
      'lat': 41.9028,
      'lng': 12.4964,
    },
    {
      'city': 'Madrid',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
      'lat': 40.4168,
      'lng': -3.7038,
    },
    {
      'city': 'Zurich',
      'code': 'CET/CEST',
      'offset': '+1:00',
      'region': 'Europe',
      'lat': 47.3769,
      'lng': 8.5417,
    },

    // Middle East & Africa
    {
      'city': 'Dubai',
      'code': 'GST',
      'offset': '+4:00',
      'region': 'Middle East',
      'lat': 25.2048,
      'lng': 55.2708,
    },
    {
      'city': 'Doha',
      'code': 'AST',
      'offset': '+3:00',
      'region': 'Middle East',
      'lat': 25.2854,
      'lng': 51.5310,
    },
    {
      'city': 'Istanbul',
      'code': 'TRT',
      'offset': '+3:00',
      'region': 'Middle East',
      'lat': 41.0082,
      'lng': 28.9784,
    },
    {
      'city': 'Cairo',
      'code': 'EET',
      'offset': '+2:00',
      'region': 'Africa',
      'lat': 30.0444,
      'lng': 31.2357,
    },
    {
      'city': 'Johannesburg',
      'code': 'SAST',
      'offset': '+2:00',
      'region': 'Africa',
      'lat': -26.2041,
      'lng': 28.0473,
    },

    // Asia Pacific
    {
      'city': 'Tokyo',
      'code': 'JST',
      'offset': '+9:00',
      'region': 'Asia',
      'lat': 35.6762,
      'lng': 139.6503,
    },
    {
      'city': 'Seoul',
      'code': 'KST',
      'offset': '+9:00',
      'region': 'Asia',
      'lat': 37.5665,
      'lng': 126.9780,
    },
    {
      'city': 'Beijing',
      'code': 'CST',
      'offset': '+8:00',
      'region': 'Asia',
      'lat': 39.9042,
      'lng': 116.4074,
    },
    {
      'city': 'Shanghai',
      'code': 'CST',
      'offset': '+8:00',
      'region': 'Asia',
      'lat': 31.2304,
      'lng': 121.4737,
    },
    {
      'city': 'Hong Kong',
      'code': 'HKT',
      'offset': '+8:00',
      'region': 'Asia',
      'lat': 22.3193,
      'lng': 114.1694,
    },
    {
      'city': 'Singapore',
      'code': 'SGT',
      'offset': '+8:00',
      'region': 'Asia',
      'lat': 1.3521,
      'lng': 103.8198,
    },
    {
      'city': 'Bangkok',
      'code': 'ICT',
      'offset': '+7:00',
      'region': 'Asia',
      'lat': 13.7563,
      'lng': 100.5018,
    },
    {
      'city': 'Mumbai',
      'code': 'IST',
      'offset': '+5:30',
      'region': 'Asia',
      'lat': 19.0760,
      'lng': 72.8777,
    },
    {
      'city': 'Delhi',
      'code': 'IST',
      'offset': '+5:30',
      'region': 'Asia',
      'lat': 28.7041,
      'lng': 77.1025,
    },

    // Australia & New Zealand
    {
      'city': 'Sydney',
      'code': 'AEDT/AEST',
      'offset': '+11:00',
      'region': 'Oceania',
      'lat': -33.8688,
      'lng': 151.2093,
    },
    {
      'city': 'Melbourne',
      'code': 'AEDT/AEST',
      'offset': '+11:00',
      'region': 'Oceania',
      'lat': -37.8136,
      'lng': 144.9631,
    },
    {
      'city': 'Auckland',
      'code': 'NZDT/NZST',
      'offset': '+13:00',
      'region': 'Oceania',
      'lat': -36.8485,
      'lng': 174.7633,
    },

    // Americas (International)
    {
      'city': 'Toronto',
      'code': 'EST/EDT',
      'offset': '-5:00',
      'region': 'Canada',
      'lat': 43.6532,
      'lng': -79.3832,
    },
    {
      'city': 'Vancouver',
      'code': 'PST/PDT',
      'offset': '-8:00',
      'region': 'Canada',
      'lat': 49.2827,
      'lng': -123.1207,
    },
    {
      'city': 'Mexico City',
      'code': 'CST/CDT',
      'offset': '-6:00',
      'region': 'Mexico',
      'lat': 19.4326,
      'lng': -99.1332,
    },
    {
      'city': 'São Paulo',
      'code': 'BRT',
      'offset': '-3:00',
      'region': 'South America',
      'lat': -23.5505,
      'lng': -46.6333,
    },
    {
      'city': 'Buenos Aires',
      'code': 'ART',
      'offset': '-3:00',
      'region': 'South America',
      'lat': -34.6118,
      'lng': -58.3960,
    },
  ];

  // Combined list with US timezones prioritized
  static List<Map<String, dynamic>> getAllTimezones() {
    return [...usTimezones, ...internationalTimezones];
  }

  // Get popular US cities for quick selection
  static List<Map<String, dynamic>> getPopularUSCities() {
    return [
      {
        'city': 'New York',
        'code': 'EST/EDT',
        'offset': '-5:00',
        'region': 'US East',
        'lat': 40.7128,
        'lng': -74.0060,
      },
      {
        'city': 'Los Angeles',
        'code': 'PST/PDT',
        'offset': '-8:00',
        'region': 'US West',
        'lat': 34.0522,
        'lng': -118.2437,
      },
      {
        'city': 'Chicago',
        'code': 'CST/CDT',
        'offset': '-6:00',
        'region': 'US Central',
        'lat': 41.8781,
        'lng': -87.6298,
      },
      {
        'city': 'Houston',
        'code': 'CST/CDT',
        'offset': '-6:00',
        'region': 'US Central',
        'lat': 29.7604,
        'lng': -95.3698,
      },
      {
        'city': 'Phoenix',
        'code': 'MST',
        'offset': '-7:00',
        'region': 'US Mountain',
        'lat': 33.4484,
        'lng': -112.0740,
      },
      {
        'city': 'Philadelphia',
        'code': 'EST/EDT',
        'offset': '-5:00',
        'region': 'US East',
        'lat': 39.9526,
        'lng': -75.1652,
      },
      {
        'city': 'San Antonio',
        'code': 'CST/CDT',
        'offset': '-6:00',
        'region': 'US Central',
        'lat': 29.4241,
        'lng': -98.4936,
      },
      {
        'city': 'San Diego',
        'code': 'PST/PDT',
        'offset': '-8:00',
        'region': 'US West',
        'lat': 32.7157,
        'lng': -117.1611,
      },
      {
        'city': 'Dallas',
        'code': 'CST/CDT',
        'offset': '-6:00',
        'region': 'US Central',
        'lat': 32.7767,
        'lng': -96.7970,
      },
      {
        'city': 'San Francisco',
        'code': 'PST/PDT',
        'offset': '-8:00',
        'region': 'US West',
        'lat': 37.7749,
        'lng': -122.4194,
      },
      {
        'city': 'Austin',
        'code': 'CST/CDT',
        'offset': '-6:00',
        'region': 'US Central',
        'lat': 30.2672,
        'lng': -97.7431,
      },
      {
        'city': 'Seattle',
        'code': 'PST/PDT',
        'offset': '-8:00',
        'region': 'US West',
        'lat': 47.6062,
        'lng': -122.3321,
      },
    ];
  }

  // Search function for any city
  static List<Map<String, dynamic>> searchTimezones(String query) {
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
