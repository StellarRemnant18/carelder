class GeoapifyConfig {
  GeoapifyConfig._();

  static const String apiKey = String.fromEnvironment('GEOAPIFY_API_KEY');

  static const String placesEndpoint = 'https://api.geoapify.com/v2/places';

  static const String mapTileTemplate =
      'https://maps.geoapify.com/v1/tile/osm-carto/'
      '{z}/{x}/{y}.png?apiKey=$apiKey';

  static bool get isConfigured => apiKey.isNotEmpty;
}
