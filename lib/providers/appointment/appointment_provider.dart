import 'package:flutter/material.dart';

import '../../models/appointment/appointment.dart';
import '../../services/sqlite_service.dart';
import '../../services/supabase_service.dart';

class AppointmentProvider extends ChangeNotifier{
  final SQLiteService _sqLiteService = SQLiteService.instance;
  final SupabaseService _supabaseService = SupabaseService();

  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadAppointment() async{
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _appointments = await _sqLiteService.getAll();
      await syncAppointments();
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addAppointment(Appointment appointment) async{
    try {
      await _sqLiteService.insert(appointment);
      await _supabaseService.insertAppointment(appointment);

      _appointments.insert(0, appointment);
      notifyListeners();
    } catch (error){
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> updateAppointment(Appointment appointment) async{
    try {
      await _sqLiteService.update(appointment);
      await _supabaseService.updateAppointment(appointment);

      final index = _appointments.indexWhere((item) => item.id == appointment.id);

      if (index != -1) {
        _appointments[index] = appointment;
      }

      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> deleteAppointment(String id) async{
    try {
      await _sqLiteService.delete(id);
      await _supabaseService.deleteAppointment(id);

      _appointments.removeWhere((appointment) => appointment.id == id);
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> syncAppointments() async{
    try {
      final supabaseAppointments = await _supabaseService.getAppointments();

      for (final appointment in supabaseAppointments){
        await _sqLiteService.insert(appointment);
      }

      _appointments = await _sqLiteService.getAll();
      notifyListeners();
    } catch (error){
      _errorMessage = error.toString();
      notifyListeners();
    }
  }
}