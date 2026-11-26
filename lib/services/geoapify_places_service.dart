import 'dart:async';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../config/geoapify_config.dart';
import '../models/hospital_place.dart';

class GeoapifyException implements Exception {
  final String message;

  const GeoapifyException(this.message);

  @override
  String toString() => message;
}

class GeoapifyPlacesService {
  final http.Client _client;

  GeoapifyPlacesService({http.Client? client})
    : _client = client ?? http.Client();

  Future<List<HospitalPlace>> searchHospitals({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    String? name,
    int limit = 30,
  }) async {
    if (!GeoapifyConfig.isConfigured) {
      throw const GeoapifyException(
        'Geoapify API key is missing. '
        'Run the app with your Geoapify configuration.',
      );
    }

    if (radiusMeters <= 0) {
      throw const GeoapifyException('Invalid search radius.');
    }

    final parameters = <String, String>{
      'categories': 'healthcare.hospital',
      'filter': 'circle:$longitude,$latitude,$radiusMeters',
      'bias': 'proximity:$longitude,$latitude',
      'limit': limit.toString(),
      'lang': 'en',
      'apiKey': GeoapifyConfig.apiKey,
    };

    final searchName = name?.trim();
    if (searchName != null && searchName.isNotEmpty) {
      parameters['name'] = searchName;
    }

    final uri = Uri.https('api.geoapify.com', '/v2/places', parameters);

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 25));

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const GeoapifyException(
          'Geoapify rejected the API key. Check your key and '
          'the enabled API permissions.',
        );
      }

      if (response.statusCode == 429) {
        throw const GeoapifyException(
          'Geoapify usage limit reached. Try again later.',
        );
      }

      if (response.statusCode != 200) {
        throw GeoapifyException(
          'Hospital search failed (HTTP ${response.statusCode}).',
        );
      }

      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw const GeoapifyException(
          'Unexpected response received from Geoapify.',
        );
      }

      final features = decoded['features'];

      if (features is! List) {
        throw const GeoapifyException(
          'Hospital results were not available in the response.',
        );
      }

      final hospitals = <HospitalPlace>[];

      for (final feature in features) {
        if (feature is! Map) continue;

        final properties = _asMap(feature['properties']);
        final geometry = _asMap(feature['geometry']);

        final coordinates = geometry['coordinates'];

        double? resultLatitude = _asDouble(properties['lat']);
        double? resultLongitude = _asDouble(properties['lon']);

        if (coordinates is List && coordinates.length >= 2) {
          resultLongitude ??= _asDouble(coordinates[0]);
          resultLatitude ??= _asDouble(coordinates[1]);
        }

        if (resultLatitude == null || resultLongitude == null) {
          continue;
        }

        if (resultLatitude < -90 ||
            resultLatitude > 90 ||
            resultLongitude < -180 ||
            resultLongitude > 180) {
          continue;
        }

        final nameValue = properties['name']?.toString().trim() ?? '';

        final addressValue =
            properties['formatted']?.toString().trim() ??
            properties['address_line1']?.toString().trim() ??
            'Address not available';

        final placeId =
            properties['place_id']?.toString() ??
            '${resultLatitude}_$resultLongitude';

        final distance = Geolocator.distanceBetween(
          latitude,
          longitude,
          resultLatitude,
          resultLongitude,
        );

        hospitals.add(
          HospitalPlace(
            id: placeId,
            name: nameValue.isEmpty
                ? 'Hospital / healthcare facility'
                : nameValue,
            address: addressValue.isEmpty
                ? 'Address not available'
                : addressValue,
            latitude: resultLatitude,
            longitude: resultLongitude,
            distanceMeters: distance,
          ),
        );
      }

      hospitals.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      return hospitals;
    } on TimeoutException {
      throw const GeoapifyException(
        'Hospital search timed out. Check your internet connection.',
      );
    } on FormatException {
      throw const GeoapifyException(
        'Could not read the hospital search response.',
      );
    } on GeoapifyException {
      rethrow;
    } catch (error) {
      throw GeoapifyException('Unable to load hospitals: $error');
    }
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return <String, dynamic>{};
  }

  static double? _asDouble(dynamic value) {
    if (value is num) return value.toDouble();

    return double.tryParse(value?.toString() ?? '');
  }

  void dispose() {
    _client.close();
  }
}
