import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment/appointment.dart';
import '../models/appointment/company.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Company>> getCompanies() async {
    final response = await _client
        .from('companies')
        .select()
        .order('name', ascending: true);

    return response
        .map<Company>((company)=> Company.fromJson(company))
        .toList();
  }

  Future<List<Appointment>> getAppointments() async{
    final response = await _client
        .from('appointments')
        .select()
        .order('created_at', ascending: false);

    return response
        .map<Appointment>((appointment) => Appointment.fromJson(appointment))
        .toList();
  }

  Future<void> insertAppointment(Appointment appointment) async {
    await _client.from('appointments').insert(appointment.toJson());
  }

  Future<void> updateAppointment(Appointment appointment) async {
    await _client
        .from('appointments')
        .update(appointment.toJson())
        .eq('id', appointment.id);
  }

  Future<void> deleteAppointment(String id) async {
    await _client.from('appointments').delete().eq('id', id);
  }

}