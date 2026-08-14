import 'package:flutter/material.dart';

import '../../models/report/reportissue.dart';
import '../../services/report/report_database_helper.dart';
import '../../services/supabase_service.dart';

class ReportProvider extends ChangeNotifier {
  final ReportDatabaseHelper _databaseHelper =
      ReportDatabaseHelper.instance;

  final SupabaseService _supabaseService = SupabaseService();

  List<ReportIssue> _reports = [];

  bool _isLoading = false;

  String? _errorMessage;

  List<ReportIssue> get reports => _reports;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // LOAD REPORTS
  // ============================================================

  Future<void> loadReports() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // 1. Load local SQLite first
      final localReports =
      await _databaseHelper.getReports();

      _reports = localReports
          .map(
            (json) => ReportIssue.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
          .toList();

      notifyListeners();

      // 2. Sync with Supabase
      await syncReports();
    } catch (error) {
      _errorMessage = error.toString();
    }

    _isLoading = false;

    notifyListeners();
  }

  // ============================================================
  // ADD REPORT
  // ============================================================

  Future<void> addReport(
      ReportIssue report,
      ) async {
    try {
      _errorMessage = null;

      // 1. Save to local SQLite
      await _databaseHelper.insertReport(
        report.toJson(),
      );

      // 2. Save to Supabase
      await _supabaseService.insertReport(
        report,
      );

      // 3. Update Provider list
      _reports.insert(0, report);

      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();

      notifyListeners();

      rethrow;
    }
  }

  // ============================================================
  // UPDATE REPORT
  // ============================================================

  Future<void> updateReport(
      ReportIssue report,
      ) async {
    try {
      _errorMessage = null;

      // 1. Update local SQLite
      await _databaseHelper.updateReport(
        report.toJson(),
      );

      // 2. Update Supabase
      await _supabaseService.updateReport(
        report,
      );

      // 3. Update Provider list
      final index = _reports.indexWhere(
            (item) => item.id == report.id,
      );

      if (index != -1) {
        _reports[index] = report;
      }

      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();

      notifyListeners();

      rethrow;
    }
  }

  // ============================================================
  // DELETE REPORT
  // ============================================================

  Future<void> deleteReport(
      String id,
      ) async {
    try {
      _errorMessage = null;

      // 1. Delete from local SQLite
      await _databaseHelper.deleteReport(id);

      // 2. Delete from Supabase
      await _supabaseService.deleteReport(id);

      // 3. Remove from Provider list
      _reports.removeWhere(
            (report) => report.id == id,
      );

      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();

      notifyListeners();

      rethrow;
    }
  }

  // ============================================================
  // SYNC REPORTS
  // ============================================================

  Future<void> syncReports() async {
    try {
      _errorMessage = null;

      // 1. Get reports from Supabase
      final supabaseReports =
      await _supabaseService.getReports();

      // 2. Insert/update Supabase data into local SQLite
      for (final report in supabaseReports) {
        await _databaseHelper.upsertReport(
          report.toJson(),
        );
      }

      // 3. Reload local SQLite data
      final localReports =
      await _databaseHelper.getReports();

      _reports = localReports
          .map(
            (json) => ReportIssue.fromJson(
          Map<String, dynamic>.from(json),
        ),
      )
          .toList();

      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();

      notifyListeners();
    }
  }
}