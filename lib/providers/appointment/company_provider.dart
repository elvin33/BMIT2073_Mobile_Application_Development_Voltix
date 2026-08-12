import 'package:flutter/material.dart';

import '../../models/appointment/company.dart';
import '../../services/supabase_service.dart';

class CompanyProvider extends ChangeNotifier{
  final SupabaseService _supabaseService = SupabaseService();

  List<Company> _companies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Company> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCompanies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _companies = await _supabaseService.getCompanies();
    } catch (error){
      _errorMessage = error.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshCompanies() async{
    await fetchCompanies();
  }
}