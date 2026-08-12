class Appointment {
    final String id;
    final String companyId;
    final String companyName;
    final String serviceType;
    final String date;
    final String time;
    final String address;
    final String notes;
    final String status;

    // Constructor
    Appointment({
      required this.id,
      required this.companyId,
      required this.companyName,
      required this.serviceType,
      required this.date,
      required this.time,
      required this.address,
      required this.notes,
      required this.status
});

    // fromJson (creates an appointment from database-style data)
    factory Appointment.fromJson(Map<String, dynamic> json){
      return Appointment(
        id: json['id'].toString(),
        companyId: json['company_id']?.toString() ?? '',
        companyName: json['company_name'] ?? '',
        serviceType: json['service_type'] ?? '',
        date: json['date'] ?? '',
        time: json['time'] ?? '',
        address: json['address'] ?? '',
        notes: json['notes'] ?? '',
        status: json['status'] ?? 'Pending',
      );
    }

    // toJson (converts appointment object back into database-style data)
    Map<String, dynamic> toJson() {
      return {
        'id': id,
        'company_id': companyId,
        'company_name': companyName,
        'service_type': serviceType,
        'date': date,
        'time': time,
        'address': address,
        'notes': notes,
        'status': status,
      };
    }

    // copyWith (can copy and only change a certain variables)
    Appointment copyWith({
      String? id,
      String? companyId,
      String? companyName,
      String? serviceType,
      String? date,
      String? time,
      String? address,
      String? notes,
      String? status,
}) {
      return Appointment(
        id: id ?? this.id,
        companyId: companyId ?? this.companyId,
        companyName: companyName ?? this.companyName,
        serviceType: serviceType ?? this.serviceType,
        date: date ?? this.date,
        time: time ?? this.time,
        address: address ?? this.address,
        notes: notes ?? this.notes,
        status: status ?? this.status,
      );
    }
}