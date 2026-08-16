import 'package:flutter/material.dart';

import '../../models/usage/energy_model.dart';
import '../../models/usage/malaysia_location.dart';
import '../../models/usage/usage_model.dart';
import '../../services/usage/api_service.dart';

enum DashboardMode { personal, malaysia }

class DashboardProvider with ChangeNotifier {
  DashboardProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  List<EnergyData> _allData = [];
  bool _isLoading = false;
  DashboardMode _mode = DashboardMode.personal;
  DateTime? _selectedMalaysiaDate;
  DateTime? _personalStartDate;
  DateTime? _personalEndDate;
  String _selectedState = allMalaysia;
  String? _errorMessage;

  static const allMalaysia = 'All Malaysia';
  static const dataSource = 'Bundled demonstration dataset';

  List<EnergyData> get allData => List.unmodifiable(_allData);
  bool get isLoading => _isLoading;
  DashboardMode get mode => _mode;
  DateTime? get selectedMalaysiaDate => _selectedMalaysiaDate;
  DateTime? get personalStartDate => _personalStartDate;
  DateTime? get personalEndDate => _personalEndDate;
  String get selectedState => _selectedState;
  String? get errorMessage => _errorMessage;

  List<DateTime> get availableDates {
    final dates = _allData.map((data) => data.parsedDate).toSet().toList()
      ..sort();
    return List.unmodifiable(dates);
  }

  List<String> get availableStates =>
      List.unmodifiable([allMalaysia, ...MalaysiaLocations.names]);

  Future<void> fetchData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allData = await _apiService.getElectricityStatistics();
    } on Object {
      _allData = [];
      _errorMessage = 'Energy data could not be loaded.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setMode(DashboardMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
  }

  void setMalaysiaDate(DateTime? date) {
    _selectedMalaysiaDate = date == null ? null : DateUtils.dateOnly(date);
    notifyListeners();
  }

  void setMalaysiaState(String state) {
    if (!availableStates.contains(state)) return;
    _selectedState = state;
    notifyListeners();
  }

  void setPersonalDateRange(DateTime? start, DateTime? end) {
    _personalStartDate = start == null ? null : DateUtils.dateOnly(start);
    _personalEndDate = end == null ? null : DateUtils.dateOnly(end);
    notifyListeners();
  }

  List<EnergyData> get malaysiaChartData {
    final matchingRows = _allData.where((data) {
      final dateMatches = _selectedMalaysiaDate == null ||
          DateUtils.isSameDay(data.parsedDate, _selectedMalaysiaDate);
      final stateMatches =
          _selectedState == allMalaysia || data.state == _selectedState;
      return dateMatches && stateMatches;
    });

    if (_selectedState != allMalaysia) {
      return matchingRows.toList()
        ..sort((a, b) => a.parsedDate.compareTo(b.parsedDate));
    }

    final totalsByDate = <String, EnergyData>{};
    for (final row in matchingRows) {
      final current = totalsByDate[row.date];
      totalsByDate[row.date] = EnergyData(
        date: row.date,
        state: 'All',
        production: (current?.production ?? 0) + row.production,
        consumption: (current?.consumption ?? 0) + row.consumption,
      );
    }
    return totalsByDate.values.toList()
      ..sort((a, b) => a.parsedDate.compareTo(b.parsedDate));
  }

  List<UserUsage> personalHistory(List<UserUsage> history) {
    final latestByMonth = <String, UserUsage>{};
    final sorted = [...history]
      ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    for (final record in sorted) {
      final date = DateUtils.dateOnly(record.dateCreated);
      final afterStart =
          _personalStartDate == null || !date.isBefore(_personalStartDate!);
      final beforeEnd =
          _personalEndDate == null || !date.isAfter(_personalEndDate!);
      if (!afterStart || !beforeEnd) continue;
      latestByMonth.putIfAbsent('${record.year}-${record.month}', () => record);
    }
    return latestByMonth.values.toList()
      ..sort((a, b) {
        final yearComparison = a.year.compareTo(b.year);
        return yearComparison != 0
            ? yearComparison
            : a.month.compareTo(b.month);
      });
  }

  String? latestUserState(List<UserUsage> history) {
    final supported = history
        .where((record) => MalaysiaLocations.findByName(record.state) != null)
        .toList()
      ..sort((a, b) => b.dateCreated.compareTo(a.dateCreated));
    return supported.isEmpty
        ? null
        : MalaysiaLocations.canonicalName(supported.first.state);
  }

  List<EnergyData> nearbyStateData(String? userState) {
    if (userState == null || _allData.isEmpty) return const [];
    final comparisonDate = _selectedMalaysiaDate ?? availableDates.last;
    final rows = _allData.where(
      (data) => DateUtils.isSameDay(data.parsedDate, comparisonDate),
    );
    final latestByState = <String, EnergyData>{};
    for (final item in rows) {
      latestByState[item.state] = item;
    }
    final nearestNames =
        MalaysiaLocations.nearestTo(userState).map((location) => location.name);
    return List.unmodifiable(
      nearestNames.map((name) => latestByState[name]).whereType<EnergyData>(),
    );
  }
}
