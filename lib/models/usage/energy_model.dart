class EnergyData {
  final String date;
  final String state;
  final double production;
  final double consumption;

  EnergyData({
    required this.date,
    required this.state,
    required this.production,
    required this.consumption,
  });

  DateTime get parsedDate => DateTime.parse(date);
}
