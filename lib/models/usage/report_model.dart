class EnergyReport {
  final String id;
  final String category;
  final String description;
  final String state;
  final String? contact;
  final String? photoPath;
  final DateTime dateSubmitted;

  EnergyReport({
    required this.id,
    required this.category,
    required this.description,
    required this.state,
    this.contact,
    this.photoPath,
    required this.dateSubmitted,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category': category,
      'description': description,
      'state': state,
      'contact': contact,
      'photoPath': photoPath,
      'dateSubmitted': dateSubmitted.toIso8601String(),
    };
  }

  factory EnergyReport.fromMap(Map<String, dynamic> map) {
    return EnergyReport(
      id: map['id'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      state: map['state'] as String,
      contact: map['contact'] as String?,
      photoPath: map['photoPath'] as String?,
      dateSubmitted: DateTime.parse(map['dateSubmitted'] as String),
    );
  }
}
