class Company {
  final String id;
  final String name;
  final List<String> services;
  final double rating;
  final int reviewCount;
  final String coverageArea;
  final String responseTime;

  Company({
    required this.id,
    required this.name,
    required this.services,
    required this.rating,
    required this.reviewCount,
    required this.coverageArea,
    required this.responseTime
  });

  factory Company.fromJson(Map<String, dynamic> json){
    return Company(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      services: List<String>.from(json['services'] ?? []),
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['review_count'] ?? 0,
      coverageArea: json['coverage_area'] ?? '',
      responseTime: json['response_time']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson(){
    return{
      'id': id,
      'name': name,
      'services': services,
      'rating': rating,
      'review_count': reviewCount,
      'coverage_area': coverageArea,
      'response_time': responseTime,
    };
  }
}