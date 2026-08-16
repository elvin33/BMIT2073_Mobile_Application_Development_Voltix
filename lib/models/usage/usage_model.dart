enum ConsumptionLevel { low, normal, high }

class UserUsage {
  final int? id;
  final int month;
  final int year;
  final double kwh;
  final String state;
  final double percentage;
  final bool isAbove;
  final ConsumptionLevel level;
  final DateTime dateCreated;

  UserUsage({
    this.id,
    required this.month,
    required this.year,
    required this.kwh,
    required this.state,
    required this.percentage,
    required this.isAbove,
    required this.level,
    required this.dateCreated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'month': month,
      'year': year,
      'kwh': kwh,
      'state': state,
      'percentage': percentage,
      'isAbove': isAbove ? 1 : 0,
      'level': level.index,
      'dateCreated': dateCreated.toIso8601String(),
    };
  }

  factory UserUsage.fromMap(Map<String, dynamic> map) {
    final savedState = map['state'] as String?;
    return UserUsage(
      id: map['id'] as int?,
      month: map['month'] as int,
      year: map['year'] as int,
      kwh: (map['kwh'] as num).toDouble(),
      state: savedState == null || savedState.isEmpty ? 'Unknown' : savedState,
      percentage: (map['percentage'] as num? ?? 0).toDouble(),
      isAbove: (map['isAbove'] as int? ?? 0) == 1,
      level: ConsumptionLevel.values[map['level'] as int],
      dateCreated: DateTime.parse(map['dateCreated'] as String),
    );
  }
}
