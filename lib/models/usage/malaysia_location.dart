import 'dart:math' as math;

class MalaysiaLocation {
  const MalaysiaLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
}

class MalaysiaLocations {
  const MalaysiaLocations._();

  // Coordinates use each location's administrative capital as a stable,
  // deterministic reference point for nearby-state suggestions.
  static const all = <MalaysiaLocation>[
    MalaysiaLocation(
      id: 'johor',
      name: 'Johor',
      latitude: 1.4927,
      longitude: 103.7414,
    ),
    MalaysiaLocation(
      id: 'kedah',
      name: 'Kedah',
      latitude: 6.1248,
      longitude: 100.3678,
    ),
    MalaysiaLocation(
      id: 'kelantan',
      name: 'Kelantan',
      latitude: 6.1254,
      longitude: 102.2381,
    ),
    MalaysiaLocation(
      id: 'kuala-lumpur',
      name: 'Kuala Lumpur',
      latitude: 3.1390,
      longitude: 101.6869,
    ),
    MalaysiaLocation(
      id: 'labuan',
      name: 'Labuan',
      latitude: 5.2831,
      longitude: 115.2308,
    ),
    MalaysiaLocation(
      id: 'melaka',
      name: 'Melaka',
      latitude: 2.1896,
      longitude: 102.2501,
    ),
    MalaysiaLocation(
      id: 'negeri-sembilan',
      name: 'Negeri Sembilan',
      latitude: 2.7258,
      longitude: 101.9424,
    ),
    MalaysiaLocation(
      id: 'pahang',
      name: 'Pahang',
      latitude: 3.8077,
      longitude: 103.3260,
    ),
    MalaysiaLocation(
      id: 'penang',
      name: 'Penang',
      latitude: 5.4141,
      longitude: 100.3288,
    ),
    MalaysiaLocation(
      id: 'perak',
      name: 'Perak',
      latitude: 4.5975,
      longitude: 101.0901,
    ),
    MalaysiaLocation(
      id: 'perlis',
      name: 'Perlis',
      latitude: 6.4414,
      longitude: 100.1986,
    ),
    MalaysiaLocation(
      id: 'putrajaya',
      name: 'Putrajaya',
      latitude: 2.9264,
      longitude: 101.6964,
    ),
    MalaysiaLocation(
      id: 'sabah',
      name: 'Sabah',
      latitude: 5.9804,
      longitude: 116.0735,
    ),
    MalaysiaLocation(
      id: 'sarawak',
      name: 'Sarawak',
      latitude: 1.5533,
      longitude: 110.3592,
    ),
    MalaysiaLocation(
      id: 'selangor',
      name: 'Selangor',
      latitude: 3.0738,
      longitude: 101.5183,
    ),
    MalaysiaLocation(
      id: 'terengganu',
      name: 'Terengganu',
      latitude: 5.3296,
      longitude: 103.1370,
    ),
  ];

  static List<String> get names =>
      List.unmodifiable(all.map((location) => location.name));

  static String canonicalName(String name) {
    final trimmed = name.trim();
    if (trimmed == 'K.L.') return 'Kuala Lumpur';
    return trimmed;
  }

  static MalaysiaLocation? findByName(String name) {
    final canonical = canonicalName(name);
    for (final location in all) {
      if (location.name == canonical) return location;
    }
    return null;
  }

  static List<MalaysiaLocation> nearestTo(
    String name, {
    int count = 5,
    bool includeOrigin = true,
  }) {
    final origin = findByName(name);
    if (origin == null || count <= 0) return const [];

    final candidates = all
        .where((location) => includeOrigin || location.id != origin.id)
        .toList()
      ..sort((a, b) {
        if (a.id == origin.id) return -1;
        if (b.id == origin.id) return 1;
        return _distanceKm(origin, a).compareTo(_distanceKm(origin, b));
      });
    return List.unmodifiable(
        candidates.take(math.min(count, candidates.length)));
  }

  static double _distanceKm(
    MalaysiaLocation first,
    MalaysiaLocation second,
  ) {
    const earthRadiusKm = 6371.0;
    final latitudeDelta = _toRadians(second.latitude - first.latitude);
    final longitudeDelta = _toRadians(second.longitude - first.longitude);
    final firstLatitude = _toRadians(first.latitude);
    final secondLatitude = _toRadians(second.latitude);
    final haversine = math.pow(math.sin(latitudeDelta / 2), 2) +
        math.cos(firstLatitude) *
            math.cos(secondLatitude) *
            math.pow(math.sin(longitudeDelta / 2), 2);
    return 2 * earthRadiusKm * math.asin(math.sqrt(haversine));
  }

  static double _toRadians(double degrees) => degrees * math.pi / 180;
}
