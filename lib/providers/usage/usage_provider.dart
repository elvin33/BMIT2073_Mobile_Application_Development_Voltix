import 'package:flutter/foundation.dart';

import '../../models/usage/usage_model.dart';
import '../../services/usage/api_service.dart';
import '../../services/usage/database_service.dart';

class UsageComparisonResult {
  final double percentage;
  final bool isAbove;
  final double userUsage;
  final double stateAverage;

  const UsageComparisonResult({
    required this.percentage,
    required this.isAbove,
    required this.userUsage,
    required this.stateAverage,
  });
}

class UsageProvider with ChangeNotifier {
  UsageProvider({ApiService? apiService, DatabaseService? databaseService})
      : _apiService = apiService ?? ApiService(),
        _databaseService = databaseService ?? DatabaseService();

  final ApiService _apiService;
  final DatabaseService _databaseService;

  double _currentInputUsage = 0;
  UsageComparisonResult? _lastResult;
  List<UserUsage> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  double get currentInputUsage => _currentInputUsage;
  UsageComparisonResult? get lastResult => _lastResult;
  List<UserUsage> get history => List.unmodifiable(_history);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateInputUsage(String value) {
    final parsedUsage = double.tryParse(value) ?? 0;
    final resultIsStale =
        _lastResult != null && parsedUsage != _lastResult!.userUsage;
    if (parsedUsage == _currentInputUsage && !resultIsStale) return;
    _currentInputUsage = parsedUsage;
    if (resultIsStale) _lastResult = null;
    notifyListeners();
  }

  static UsageComparisonResult calculateComparison({
    required double userUsage,
    required double stateAverage,
  }) {
    if (userUsage <= 0 || stateAverage <= 0) {
      throw ArgumentError('Usage values must be greater than zero.');
    }
    final difference = userUsage - stateAverage;
    return UsageComparisonResult(
      percentage: (difference / stateAverage * 100).abs(),
      isAbove: difference >= 0,
      userUsage: userUsage,
      stateAverage: stateAverage,
    );
  }

  Future<bool> compareUsage(String state, double userUsage) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final average = await _apiService.getAverageUsageForState(state);
      final result = calculateComparison(
        userUsage: userUsage,
        stateAverage: average,
      );
      final now = DateTime.now();
      final signedDifference =
          result.isAbove ? result.percentage : -result.percentage;
      final level = signedDifference > 10
          ? ConsumptionLevel.high
          : signedDifference < -10
              ? ConsumptionLevel.low
              : ConsumptionLevel.normal;
      await _databaseService.insertUsage(
        UserUsage(
          month: now.month,
          year: now.year,
          kwh: userUsage,
          state: state,
          percentage: result.percentage,
          isAbove: result.isAbove,
          level: level,
          dateCreated: now,
        ),
      );
      _lastResult = result;
      _history = await _databaseService.getAllUsage();
      return true;
    } on Object {
      _errorMessage = 'The comparison could not be saved.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _history = await _databaseService.getAllUsage();
    } on Object {
      _errorMessage = 'Usage history could not be loaded.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResult() {
    _lastResult = null;
    notifyListeners();
  }
}
