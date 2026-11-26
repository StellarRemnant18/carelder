import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../config/geoapify_config.dart';
import '../models/hospital_place.dart';
import '../services/geoapify_places_service.dart';

class HospitalSearchPage extends StatefulWidget {
  const HospitalSearchPage({super.key});

  @override
  State<HospitalSearchPage> createState() => _HospitalSearchPageState();
}

class _HospitalSearchPageState extends State<HospitalSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  final MapController _mapController = MapController();

  late final GeoapifyPlacesService _placesService;

  static const LatLng _defaultCenter = LatLng(22.9734, 78.6569);

  LatLng _mapCenter = _defaultCenter;

  Position? _currentPosition;

  List<HospitalPlace> _hospitals = [];

  HospitalPlace? _selectedHospital;

  int _radiusMeters = 5000;

  bool _isLoading = false;
  bool _mapReady = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _placesService = GeoapifyPlacesService();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _placesService.dispose();
    _mapController.dispose();

    super.dispose();
  }

  Future<void> _findNearbyHospitals() async {
    if (!GeoapifyConfig.isConfigured) {
      setState(() {
        _errorMessage =
            'Geoapify API key is missing. Restart CaringMate '
            'using your Geoapify configuration.';
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _selectedHospital = null;
      _hospitals = [];
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Location services are disabled. Enable location '
          'on your phone and try again.',
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission was denied. Allow location '
          'access to search nearby hospitals.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is permanently denied. '
          'Enable it in Android app settings.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      final center = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = position;
        _mapCenter = center;
      });

      if (_mapReady) {
        _mapController.move(center, 14);
      }

      final results = await _placesService.searchHospitals(
        latitude: position.latitude,
        longitude: position.longitude,
        radiusMeters: _radiusMeters,
        name: _searchController.text,
        limit: 30,
      );

      if (!mounted) return;

      setState(() {
        _hospitals = results;
        _errorMessage = results.isEmpty
            ? 'No hospitals were found in this search area. '
                  'Try increasing the search radius.'
            : null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _selectHospital(HospitalPlace hospital) {
    setState(() => _selectedHospital = hospital);

    final point = LatLng(hospital.latitude, hospital.longitude);

    if (_mapReady) {
      _mapController.move(point, 16);
    }
  }

  Widget _buildMap() {
    if (!GeoapifyConfig.isConfigured) {
      return _mapPlaceholder(
        'Map API key not configured',
        'Run CaringMate with the Geoapify configuration.',
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 4.5,
              minZoom: 3,
              maxZoom: 19,
              onMapReady: () {
                _mapReady = true;
              },
            ),
            children: [
              TileLayer(
                urlTemplate: GeoapifyConfig.mapTileTemplate,
                maxZoom: 20,
              ),
              MarkerLayer(
                markers: [
                  if (_currentPosition != null)
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 42,
                      height: 42,
                      child: const Icon(
                        Icons.my_location,
                        size: 29,
                        color: Colors.blue,
                      ),
                    ),

                  ..._hospitals.map((hospital) {
                    final selected = _selectedHospital?.id == hospital.id;

                    return Marker(
                      point: LatLng(hospital.latitude, hospital.longitude),
                      width: 44,
                      height: 48,
                      child: GestureDetector(
                        onTap: () => _selectHospital(hospital),
                        child: Icon(
                          Icons.location_on,
                          color: selected ? Colors.orange : Colors.red,
                          size: selected ? 43 : 37,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          Positioned(
            top: 12,
            right: 12,
            child: FloatingActionButton.small(
              heroTag: 'hospital_map_location',
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              onPressed: () {
                final position = _currentPosition;

                if (position == null) {
                  _findNearbyHospitals();
                  return;
                }

                _mapController.move(
                  LatLng(position.latitude, position.longitude),
                  15,
                );
              },
              child: const Icon(Icons.my_location),
            ),
          ),

          Positioned(
            bottom: 7,
            left: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '© OpenStreetMap contributors · Geoapify',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapPlaceholder(String title, String subtitle) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.map_outlined, size: 52, color: Colors.blueGrey),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRadiusSelector() {
    const options = <int>[2000, 5000, 10000, 20000];

    return Wrap(
      spacing: 8,
      children: options.map((radius) {
        final selected = _radiusMeters == radius;

        final label = radius < 1000 ? '${radius}m' : '${radius ~/ 1000} km';

        return ChoiceChip(
          label: Text(label),
          selected: selected,
          onSelected: (_) {
            setState(() => _radiusMeters = radius);
          },
        );
      }).toList(),
    );
  }

  Widget _buildHospitalCard(HospitalPlace hospital) {
    final selected = _selectedHospital?.id == hospital.id;

    return Card(
      elevation: 0,
      color: selected ? const Color(0xFFE8F2FF) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? Colors.blue : const Color(0xFFE1E8F0),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _selectHospital(hospital),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE9E9),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(Icons.local_hospital, color: Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hospital.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      hospital.address,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      hospital.distanceLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.blue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.location_on_outlined, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hospital Search',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Find nearby hospitals',
            onPressed: _isLoading ? null : _findNearbyHospitals,
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          const Text(
            'Find healthcare near you',
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 5),
          const Text(
            'Search for hospitals around your current location.',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _searchController,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) {
              if (!_isLoading) {
                _findNearbyHospitals();
              }
            },
            decoration: InputDecoration(
              hintText: 'Optional hospital name',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                tooltip: 'Clear search',
                onPressed: () => _searchController.clear(),
                icon: const Icon(Icons.close),
              ),
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            'Search radius',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
          ),

          const SizedBox(height: 8),

          _buildRadiusSelector(),

          const SizedBox(height: 14),

          SizedBox(height: 300, child: _buildMap()),

          const SizedBox(height: 14),

          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _findNearbyHospitals,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.search),
              label: Text(
                _isLoading
                    ? 'Searching nearby hospitals...'
                    : 'Find nearby hospitals',
              ),
            ),
          ),

          if (_errorMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.deepOrange,
                    size: 19,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.brown, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          Row(
            children: [
              const Expanded(
                child: Text(
                  'Hospital results',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${_hospitals.length} found',
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(25),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_hospitals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 18),
              child: Column(
                children: [
                  Icon(
                    Icons.local_hospital_outlined,
                    size: 42,
                    color: Colors.blueGrey,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No hospital results yet',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Use Find nearby hospitals to search.',
                    style: TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            )
          else
            ..._hospitals.map(_buildHospitalCard),

          const SizedBox(height: 18),

          const Text(
            'Location information is sourced from OpenStreetMap '
            'through Geoapify. Some hospitals may be missing or have '
            'incomplete details. Confirm a facility and its services '
            'before travelling. This feature is not an emergency '
            'dispatch service.',
            style: TextStyle(color: Colors.black54, fontSize: 10, height: 1.45),
          ),
        ],
      ),
    );
  }
}
