class ReportIssue {
  final String id;
  final String description;
  final String location;
  final String urgency;
  final String nameEmail;
  final String fileName;
  final String createdAt;

  ReportIssue({
    required this.id,
    required this.description,
    required this.location,
    required this.urgency,
    required this.nameEmail,
    required this.fileName,
    required this.createdAt,
  });

  factory ReportIssue.fromJson(Map<String, dynamic> json) {
    return ReportIssue(
      id: json['id']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      urgency: json['urgency']?.toString() ?? '',
      nameEmail: json['name_email']?.toString() ?? '',
      fileName: json['file_name']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'location': location,
      'urgency': urgency,
      'name_email': nameEmail,
      'file_name': fileName,
      'created_at': createdAt,
    };
  }

  ReportIssue copyWith({
    String? id,
    String? description,
    String? location,
    String? urgency,
    String? nameEmail,
    String? fileName,
    String? createdAt,
  }) {
    return ReportIssue(
      id: id ?? this.id,
      description: description ?? this.description,
      location: location ?? this.location,
      urgency: urgency ?? this.urgency,
      nameEmail: nameEmail ?? this.nameEmail,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}