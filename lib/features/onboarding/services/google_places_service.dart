
class GooglePlacesService {
  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const String _apiKey =
      'YOUR_GOOGLE_PLACES_API_KEY'; // Replace with your API key

  // Get place autocomplete suggestions
  static Future<List<PlaceSuggestion>> getPlaceSuggestions(String query) async {
    if (query.isEmpty) return [];

    // For demo purposes, return mock Google-style results
    // In production, replace with actual Google Places API call
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Simulate API delay

    // Mock professional city suggestions
    final mockResults = <PlaceSuggestion>[];

    if (query.toLowerCase().contains('cor')) {
      mockResults.addAll([
        PlaceSuggestion(
          placeId: 'mock_corpus_christi',
          description: 'Corpus Christi, TX, USA',
          mainText: 'Corpus Christi',
          secondaryText: 'Texas, USA',
        ),
        PlaceSuggestion(
          placeId: 'mock_corona',
          description: 'Corona, CA, USA',
          mainText: 'Corona',
          secondaryText: 'California, USA',
        ),
      ]);
    }

    if (query.toLowerCase().contains('new')) {
      mockResults.addAll([
        PlaceSuggestion(
          placeId: 'mock_newark',
          description: 'Newark, NJ, USA',
          mainText: 'Newark',
          secondaryText: 'New Jersey, USA',
        ),
        PlaceSuggestion(
          placeId: 'mock_newport',
          description: 'Newport Beach, CA, USA',
          mainText: 'Newport Beach',
          secondaryText: 'California, USA',
        ),
      ]);
    }

    if (query.toLowerCase().contains('san')) {
      mockResults.addAll([
        PlaceSuggestion(
          placeId: 'mock_santa_monica',
          description: 'Santa Monica, CA, USA',
          mainText: 'Santa Monica',
          secondaryText: 'California, USA',
        ),
        PlaceSuggestion(
          placeId: 'mock_santa_barbara',
          description: 'Santa Barbara, CA, USA',
          mainText: 'Santa Barbara',
          secondaryText: 'California, USA',
        ),
      ]);
    }

    return mockResults;

    /* 
    // PRODUCTION CODE - Uncomment and add your Google Places API key
    try {
      final url = Uri.parse(
        '$_baseUrl/autocomplete/json?input=$query&types=(cities)&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final predictions = data['predictions'] as List;

        return predictions
            .map((prediction) => PlaceSuggestion.fromJson(prediction))
            .toList();
      }
    } catch (e) {
      print('Error fetching places: $e');
    }

    return [];
    */
  }

  // Get place details including coordinates
  static Future<PlaceDetails?> getPlaceDetails(String placeId) async {
    // For demo purposes, return mock coordinates
    await Future.delayed(const Duration(milliseconds: 200));

    // Mock coordinates for demo cities
    switch (placeId) {
      case 'mock_corpus_christi':
        return PlaceDetails(
          latitude: 27.8006,
          longitude: -97.3964,
          name: 'Corpus Christi',
          formattedAddress: 'Corpus Christi, TX, USA',
        );
      case 'mock_corona':
        return PlaceDetails(
          latitude: 33.8753,
          longitude: -117.5664,
          name: 'Corona',
          formattedAddress: 'Corona, CA, USA',
        );
      case 'mock_newark':
        return PlaceDetails(
          latitude: 40.7357,
          longitude: -74.1724,
          name: 'Newark',
          formattedAddress: 'Newark, NJ, USA',
        );
      case 'mock_newport':
        return PlaceDetails(
          latitude: 33.6189,
          longitude: -117.9289,
          name: 'Newport Beach',
          formattedAddress: 'Newport Beach, CA, USA',
        );
      case 'mock_santa_monica':
        return PlaceDetails(
          latitude: 34.0195,
          longitude: -118.4912,
          name: 'Santa Monica',
          formattedAddress: 'Santa Monica, CA, USA',
        );
      case 'mock_santa_barbara':
        return PlaceDetails(
          latitude: 34.4208,
          longitude: -119.6982,
          name: 'Santa Barbara',
          formattedAddress: 'Santa Barbara, CA, USA',
        );
      default:
        return null;
    }

    /* 
    // PRODUCTION CODE - Uncomment and add your Google Places API key
    try {
      final url = Uri.parse(
        '$_baseUrl/details/json?place_id=$placeId&fields=geometry,name,formatted_address&key=$_apiKey',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['result'];

        if (result != null) {
          return PlaceDetails.fromJson(result);
        }
      }
    } catch (e) {
      print('Error fetching place details: $e');
    }

    return null;
    */
  }
}

class PlaceSuggestion {
  final String placeId;
  final String description;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.description,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final structuredFormatting = json['structured_formatting'] ?? {};

    return PlaceSuggestion(
      placeId: json['place_id'] ?? '',
      description: json['description'] ?? '',
      mainText: structuredFormatting['main_text'] ?? '',
      secondaryText: structuredFormatting['secondary_text'] ?? '',
    );
  }
}

class PlaceDetails {
  final double latitude;
  final double longitude;
  final String name;
  final String formattedAddress;

  PlaceDetails({
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.formattedAddress,
  });

  factory PlaceDetails.fromJson(Map<String, dynamic> json) {
    final geometry = json['geometry'] ?? {};
    final location = geometry['location'] ?? {};

    return PlaceDetails(
      latitude: (location['lat'] ?? 0.0).toDouble(),
      longitude: (location['lng'] ?? 0.0).toDouble(),
      name: json['name'] ?? '',
      formattedAddress: json['formatted_address'] ?? '',
    );
  }
}
