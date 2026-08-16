import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/usage/dashboard_provider.dart';
import '../../providers/usage/usage_provider.dart';
import '../../services/usage/api_service.dart';
import '../../utils/validators.dart';
import '../../widgets/usage/energy_overview.dart';
import '../../widgets/drawer.dart';


class MyUsageScreen extends StatefulWidget {
  const MyUsageScreen({super.key});

  @override
  State<MyUsageScreen> createState() => _MyUsageScreenState();
}

class _MyUsageScreenState extends State<MyUsageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usageController = TextEditingController();
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    _usageController.addListener(_updatePreview);
  }

  void _updatePreview() {
    context.read<UsageProvider>().updateInputUsage(_usageController.text);
  }

  @override
  void dispose() {
    _usageController
      ..removeListener(_updatePreview)
      ..dispose();
    super.dispose();
  }

  Future<void> _onCompare() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final usage = double.parse(_usageController.text.trim());
    final success = await context
        .read<UsageProvider>()
        .compareUsage(_selectedState!, usage);
    if (!mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          context.read<UsageProvider>().errorMessage ??
              'The comparison could not be completed.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Voltix',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: const AppDrawer(),
      body: Consumer<UsageProvider>(
        builder: (context, provider, child) {
          return Form(
            key: _formKey,
            child: RefreshIndicator(
              onRefresh: context.read<DashboardProvider>().fetchData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                children: [
                  const SectionHeader(label: 'Usage benchmark'),
                  const SizedBox(height: 30),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedState,
                    decoration: const InputDecoration(labelText: 'State'),
                    hint: const Text('Select a state'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    items: ApiService.supportedStates
                        .map(
                          (state) => DropdownMenuItem(
                            value: state,
                            child: Text(state),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != _selectedState) {
                        context.read<UsageProvider>().clearResult();
                      }
                      setState(() => _selectedState = value);
                    },
                    validator: (value) =>
                        value == null ? 'Please select a state.' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    key: const Key('monthly-usage-field'),
                    controller: _usageController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    decoration: const InputDecoration(
                      labelText: 'Monthly usage',
                      hintText: 'e.g. 350.5',
                      helperText: 'Numbers only; decimals are accepted.',
                      suffixText: 'kWh',
                      errorMaxLines: 2,
                      suffixIcon: Tooltip(
                        message: 'Enter the usage shown on your electricity '
                            'bill. Use numbers only; decimals such as 350.5 '
                            'are accepted.',
                        triggerMode: TooltipTriggerMode.tap,
                        child: Icon(
                          Icons.info_outline,
                          semanticLabel: 'Monthly usage help',
                        ),
                      ),
                    ),
                    validator: UsageValidators.monthlyUsage,
                    onFieldSubmitted: (_) => _onCompare(),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _onCompare,
                        child: provider.isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Compare'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 36),
                  if (provider.lastResult == null)
                    _UsagePreview(usage: provider.currentInputUsage)
                  else
                    _ComparisonResult(result: provider.lastResult!),
                  const SizedBox(height: 20),
                  const Divider(height: 40),
                  const EnergyOverview(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UsagePreview extends StatelessWidget {
  const _UsagePreview({required this.usage});

  final double usage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Your monthly usage',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                usage.toStringAsFixed(usage % 1 == 0 ? 0 : 1),
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text('kWh', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComparisonResult extends StatelessWidget {
  const _ComparisonResult({required this.result});

  final UsageComparisonResult result;

  @override
  Widget build(BuildContext context) {
    final maximum = result.userUsage > result.stateAverage
        ? result.userUsage
        : result.stateAverage;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            '${result.percentage.toStringAsFixed(0)}% '
            '${result.isAbove ? 'above' : 'below'}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'State household average',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          _ResultBar(label: 'You', value: result.userUsage / maximum),
          const SizedBox(height: 18),
          _ResultBar(label: 'Avg', value: result.stateAverage / maximum),
        ],
      ),
    );
  }
}

class _ResultBar extends StatelessWidget {
  const _ResultBar({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              minHeight: 30,
              color: Colors.black,
              backgroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}
