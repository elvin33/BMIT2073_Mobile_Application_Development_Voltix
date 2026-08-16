import 'package:csv/csv.dart';
import 'package:flutter/services.dart';

import '../../models/usage/energy_model.dart';
import '../../models/usage/malaysia_location.dart';

typedef AssetLoader = Future<String> Function(String path);

class ApiService {
  ApiService({AssetLoader? assetLoader})
      : _assetLoader = assetLoader ?? rootBundle.loadString;

  static List<String> get supportedStates => MalaysiaLocations.names;

  static const _stateAverages = <String, double>{
    'Selangor': 420,
    'Kuala Lumpur': 450,
    'Johor': 400,
    'Terengganu': 350,
    'Penang': 410,
  };

  static const _defaultStateAverage = 400.0;

  final AssetLoader _assetLoader;

  Future<List<EnergyData>> getElectricityStatistics() async {
    final rawData = await _assetLoader('assets/energy_data.csv');
    final records = parseElectricityCsv(rawData);
    validateCompleteMalaysiaCoverage(records);
    return records;
  }

  static List<EnergyData> parseElectricityCsv(String rawData) {
    final csvRows = const CsvToListConverter(eol: '\n').convert(rawData);
    if (csvRows.isEmpty) {
      throw const FormatException('The energy dataset is empty.');
    }

    const expectedHeader = <String>[
      'Date',
      'State',
      'Sector',
      'Consumption_GWh',
      'Production_GWh',
    ];
    final header = csvRows.first.map((cell) => cell.toString().trim()).toList();
    if (header.length < expectedHeader.length ||
        !Iterable<int>.generate(expectedHeader.length)
            .every((index) => header[index] == expectedHeader[index])) {
      throw const FormatException('The energy dataset has an invalid header.');
    }

    final records = <EnergyData>[];
    for (var index = 1; index < csvRows.length; index++) {
      final row = csvRows[index];
      if (row.isEmpty || row.every((cell) => cell.toString().trim().isEmpty)) {
        continue;
      }
      if (row.length < expectedHeader.length) {
        throw FormatException('CSV row ${index + 1} is incomplete.');
      }

      final date = row[0].toString().trim();
      final state = MalaysiaLocations.canonicalName(row[1].toString());
      final consumption = _asDouble(row[3]);
      final production = _asDouble(row[4]);
      if (DateTime.tryParse(date) == null || state.isEmpty) {
        throw FormatException('CSV row ${index + 1} has invalid values.');
      }

      records.add(
        EnergyData(
          date: date,
          state: state,
          production: production,
          consumption: consumption,
        ),
      );
    }

    if (records.isEmpty) {
      throw const FormatException('The energy dataset contains no records.');
    }
    records.sort((a, b) => a.parsedDate.compareTo(b.parsedDate));
    return records;
  }

  static void validateCompleteMalaysiaCoverage(List<EnergyData> records) {
    final expectedStates = MalaysiaLocations.names.toSet();
    final statesByDate = <String, Set<String>>{};
    for (final record in records) {
      if (!expectedStates.contains(record.state)) {
        throw FormatException('Unsupported dashboard state: ${record.state}');
      }
      final states = statesByDate.putIfAbsent(record.date, () => <String>{});
      if (!states.add(record.state)) {
        throw FormatException(
          'Duplicate dashboard row for ${record.state} on ${record.date}.',
        );
      }
    }

    for (final entry in statesByDate.entries) {
      if (entry.value.length != expectedStates.length ||
          !entry.value.containsAll(expectedStates)) {
        final missing = expectedStates.difference(entry.value).join(', ');
        throw FormatException(
          'Dashboard date ${entry.key} is missing: $missing',
        );
      }
    }
  }

  static double _asDouble(dynamic value) {
    if (value is num) return value.toDouble();
    final parsed = double.tryParse(value.toString().trim());
    if (parsed == null) {
      throw FormatException('Invalid numeric value: $value');
    }
    return parsed;
  }

  Future<double> getAverageUsageForState(String state) async {
    if (!supportedStates.contains(state)) {
      throw ArgumentError.value(state, 'state', 'Unsupported state');
    }
    return _stateAverages[state] ?? _defaultStateAverage;
  }
}
