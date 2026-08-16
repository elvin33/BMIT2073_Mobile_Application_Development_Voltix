class UsageValidators {
  const UsageValidators._();

  static const emptyMessage = 'Please enter your monthly usage.';
  static const numbersOnlyMessage =
      'Use numbers only, for example 350 or 350.5.';
  static const positiveMessage = 'Monthly usage must be greater than 0 kWh.';

  static String? monthlyUsage(String? value) {
    final input = value?.trim() ?? '';
    if (input.isEmpty) return emptyMessage;

    final usage = double.tryParse(input);
    if (usage == null || !usage.isFinite) return numbersOnlyMessage;
    if (usage <= 0) return positiveMessage;

    final standardNumber = RegExp(r'^\d*\.?\d+$');
    if (!standardNumber.hasMatch(input)) return numbersOnlyMessage;

    return null;
  }
}
