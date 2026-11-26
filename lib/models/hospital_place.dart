class HospitalPlace {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double distanceMeters;

  const HospitalPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
  });

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.round()} m away';
    }

    return '${(distanceMeters / 1000).toStringAsFixed(1)} km away';
  }
}
