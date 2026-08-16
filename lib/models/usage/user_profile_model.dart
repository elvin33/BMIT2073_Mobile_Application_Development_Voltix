class UserProfile {
  final String name;
  final String email;
  final String address;
  final String sector;

  const UserProfile({
    required this.name,
    required this.email,
    required this.address,
    required this.sector,
  });

  static const empty = UserProfile(
    name: '',
    email: '',
    address: '',
    sector: '',
  );

  Map<String, dynamic> toMap() => {
        'id': 1,
        'name': name,
        'email': email,
        'address': address,
        'sector': sector,
      };

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      sector: map['sector'] as String? ?? '',
    );
  }
}
