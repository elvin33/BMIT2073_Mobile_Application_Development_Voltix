import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/appointment/appointment.dart';
import '../models/appointment/company.dart';
import '../models/report/reportissue.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Company for appointment solar services
  Future<List<Company>> getCompanies() async {
    final response = await _client
        .from('companies')
        .select()
        .order('name', ascending: true);

    return response
        .map<Company>((company)=> Company.fromJson(company))
        .toList();
  }

  // Appointment solar services
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

  // =========================
  // REPORT ISSUE
  // =========================

  Future<List<ReportIssue>> getReports() async {
    final response = await _client
        .from('reports')
        .select()
        .order(
      'created_at',
      ascending: false,
    );

    return response
        .map<ReportIssue>(
          (report) => ReportIssue.fromJson(
        Map<String, dynamic>.from(report),
      ),
    )
        .toList();
  }

  Future<void> insertReport(
      ReportIssue report,
      ) async {
    await _client
        .from('reports')
        .insert(
      report.toJson(),
    );
  }

  Future<void> updateReport(
      ReportIssue report,
      ) async {
    await _client
        .from('reports')
        .update(
      report.toJson(),
    )
        .eq(
      'id',
      report.id,
    );
  }

  Future<void> deleteReport(String id,) async {
    await _client
        .from('reports')
        .delete()
        .eq(
      'id',
      id,
    );
  }
}