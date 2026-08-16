import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/usage/energy_model.dart';
import '../../models/usage/usage_model.dart';
import '../../providers/usage/dashboard_provider.dart';
import '../../providers/usage/usage_provider.dart';
import '../../utils/theme.dart';

class EnergyOverview extends StatelessWidget {
  const EnergyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, UsageProvider>(
      builder: (context, dashboard, usage, child) {
        return Column(
          key: const Key('energy-overview'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(label: 'Dashboard'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<DashboardMode>(
                key: const Key('dashboard-mode-selector'),
                showSelectedIcon: false,
                style: ButtonStyle(
                  foregroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white
                        : Colors.black,
                  ),
                  iconColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.white
                        : Colors.black,
                  ),
                  backgroundColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
                segments: const [
                  ButtonSegment(
                    value: DashboardMode.personal,
                    icon: Icon(Icons.person_outline),
                    label: Text('Personal'),
                  ),
                  ButtonSegment(
                    value: DashboardMode.malaysia,
                    icon: Icon(Icons.public),
                    label: Text('Malaysia'),
                  ),
                ],
                selected: {dashboard.mode},
                onSelectionChanged: (selection) {
                  dashboard.setMode(selection.first);
                },
              ),
            ),
            const SizedBox(height: 20),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: dashboard.mode == DashboardMode.personal
                  ? _PersonalDashboard(
                      key: const ValueKey('personal-dashboard'),
                      dashboard: dashboard,
                      usage: usage,
                    )
                  : _MalaysiaDashboard(
                      key: const ValueKey('malaysia-dashboard'),
                      dashboard: dashboard,
                      usage: usage,
                    ),
            ),
          ],
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _PersonalDashboard extends StatelessWidget {
  const _PersonalDashboard({
    super.key,
    required this.dashboard,
    required this.usage,
  });

  final DashboardProvider dashboard;
  final UsageProvider usage;

  @override
  Widget build(BuildContext context) {
    final records = dashboard.personalHistory(usage.history);
    final allRecords = [...usage.history]
      ..sort((a, b) => a.dateCreated.compareTo(b.dateCreated));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal usage history',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Based on comparisons saved in your usage history.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 16),
        _PersonalDateFilter(
          dashboard: dashboard,
          allRecords: allRecords,
        ),
        const SizedBox(height: 20),
        if (usage.isLoading && usage.history.isEmpty)
          const _DashboardLoading(label: 'Loading your usage history')
        else if (records.isEmpty)
          _EmptyDashboard(
            icon: Icons.insights_outlined,
            title: usage.history.isEmpty
                ? 'No personal usage yet'
                : 'No usage in this date range',
            message: usage.history.isEmpty
                ? 'Select a state, enter your monthly usage, and tap Compare '
                    'to add your first record.'
                : 'Choose another date range or clear the current filter.',
          )
        else ...[
          _PersonalSummary(records: records),
          const SizedBox(height: 20),
          _PersonalUsageChart(records: records),
          const SizedBox(height: 16),
          _UsageValues(records: records),
        ],
      ],
    );
  }
}

class _PersonalDateFilter extends StatelessWidget {
  const _PersonalDateFilter({
    required this.dashboard,
    required this.allRecords,
  });

  final DashboardProvider dashboard;
  final List<UserUsage> allRecords;

  @override
  Widget build(BuildContext context) {
    final hasRange = dashboard.personalStartDate != null &&
        dashboard.personalEndDate != null;
    final label = hasRange
        ? '${DateFormat('dd MMM yyyy').format(dashboard.personalStartDate!)} – '
            '${DateFormat('dd MMM yyyy').format(dashboard.personalEndDate!)}'
        : 'All recorded dates';

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            key: const Key('personal-date-filter'),
            onPressed: allRecords.isEmpty
                ? null
                : () async {
                    final firstDate =
                        DateUtils.dateOnly(allRecords.first.dateCreated);
                    final lastRecord =
                        DateUtils.dateOnly(allRecords.last.dateCreated);
                    final today = DateUtils.dateOnly(DateTime.now());
                    final lastDate =
                        lastRecord.isAfter(today) ? lastRecord : today;
                    final selected = await showDateRangePicker(
                      context: context,
                      firstDate: firstDate,
                      lastDate: lastDate,
                      initialDateRange: hasRange
                          ? DateTimeRange(
                              start: dashboard.personalStartDate!,
                              end: dashboard.personalEndDate!,
                            )
                          : null,
                      helpText: 'Filter personal usage',
                      saveText: 'Apply',
                    );
                    if (selected != null) {
                      dashboard.setPersonalDateRange(
                        selected.start,
                        selected.end,
                      );
                    }
                  },
            icon: const Icon(Icons.date_range),
            label: Text(label, overflow: TextOverflow.ellipsis),
          ),
        ),
        if (hasRange) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Clear personal date filter',
            onPressed: () => dashboard.setPersonalDateRange(null, null),
            icon: const Icon(Icons.clear),
          ),
        ],
      ],
    );
  }
}

class _PersonalSummary extends StatelessWidget {
  const _PersonalSummary({required this.records});

  final List<UserUsage> records;

  @override
  Widget build(BuildContext context) {
    final latest = records.last;
    final average = records.fold<double>(0, (sum, record) => sum + record.kwh) /
        records.length;
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            label: 'Latest month',
            value: '${latest.kwh.toStringAsFixed(1)} kWh',
            caption: DateFormat('MMM yyyy').format(
              DateTime(latest.year, latest.month),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MetricCard(
            label: 'Monthly average',
            value: '${average.toStringAsFixed(1)} kWh',
            caption: '${records.length} month${records.length == 1 ? '' : 's'}',
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.caption,
  });

  final String label;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(height: 2),
          Text(caption, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _PersonalUsageChart extends StatelessWidget {
  const _PersonalUsageChart({required this.records});

  final List<UserUsage> records;

  @override
  Widget build(BuildContext context) {
    final summary = records
        .map(
          (record) =>
              '${DateFormat('MMMM yyyy').format(DateTime(record.year, record.month))}: '
              '${record.kwh.toStringAsFixed(1)} kilowatt-hours',
        )
        .join(', ');
    return _ChartCard(
      title: 'Usage over time (kWh)',
      semanticsLabel: 'Personal monthly usage chart. $summary.',
      child: records.length == 1
          ? _SingleDataPoint(
              value: '${records.single.kwh.toStringAsFixed(1)} kWh',
              caption: DateFormat('MMMM yyyy').format(
                DateTime(records.single.year, records.single.month),
              ),
            )
          : _UsageLineChart(records: records),
    );
  }
}

class _UsageLineChart extends StatelessWidget {
  const _UsageLineChart({required this.records});

  final List<UserUsage> records;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      _baseChartData(
        count: records.length,
        spots: records
            .asMap()
            .entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value.kwh))
            .toList(),
        bottomTitle: (index) => DateFormat('MMM yy').format(
          DateTime(records[index].year, records[index].month),
        ),
        lineColor: Colors.black,
      ),
    );
  }
}

class _UsageValues extends StatelessWidget {
  const _UsageValues({required this.records});

  final List<UserUsage> records;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      title: const Text('View monthly values'),
      children: records.reversed
          .map(
            (record) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                DateFormat('MMMM yyyy').format(
                  DateTime(record.year, record.month),
                ),
              ),
              subtitle: Text(record.state),
              trailing: Text(
                '${record.kwh.toStringAsFixed(1)} kWh',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MalaysiaDashboard extends StatelessWidget {
  const _MalaysiaDashboard({
    super.key,
    required this.dashboard,
    required this.usage,
  });

  final DashboardProvider dashboard;
  final UsageProvider usage;

  @override
  Widget build(BuildContext context) {
    if (dashboard.isLoading) {
      return const _DashboardLoading(label: 'Loading Malaysia energy data');
    }
    if (dashboard.errorMessage != null) {
      return _OverviewError(
        message: dashboard.errorMessage!,
        onRetry: dashboard.fetchData,
      );
    }

    final chartData = dashboard.malaysiaChartData;
    final userState = dashboard.latestUserState(usage.history);
    final nearbyData = dashboard.nearbyStateData(userState);
    final latestDate =
        dashboard.availableDates.isEmpty ? null : dashboard.availableDates.last;
    final comparisonDate = dashboard.selectedMalaysiaDate ?? latestDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Malaysia energy usage',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          'Explore the national demonstration dataset by date and location.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(height: 16),
        _MalaysiaFilters(dashboard: dashboard),
        const SizedBox(height: 20),
        _NationalConsumptionChart(
          data: chartData,
          location: dashboard.selectedState,
        ),
        const SizedBox(height: 24),
        Text(
          userState == null ? 'Nearby state usage' : 'Usage near $userState',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          comparisonDate == null
              ? 'No comparison date available.'
              : DateFormat('dd MMMM yyyy').format(comparisonDate),
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 14),
        if (userState == null)
          const _EmptyDashboard(
            icon: Icons.location_searching,
            title: 'Your state is not known yet',
            message: 'Save a usage comparison first. This list will then '
                'follow the state from your latest usage record.',
          )
        else if (nearbyData.isEmpty)
          const _EmptyDashboard(
            icon: Icons.location_off_outlined,
            title: 'No nearby data available',
            message: 'Try selecting another date.',
          )
        else
          _NearbyStateBars(data: nearbyData, userState: userState),
        const SizedBox(height: 16),
        _DatasetNote(
          firstDate: dashboard.availableDates.isEmpty
              ? null
              : dashboard.availableDates.first,
          lastDate: latestDate,
        ),
      ],
    );
  }
}

class _MalaysiaFilters extends StatelessWidget {
  const _MalaysiaFilters({required this.dashboard});

  final DashboardProvider dashboard;

  @override
  Widget build(BuildContext context) {
    final dateLabel = dashboard.selectedMalaysiaDate == null
        ? 'All dates'
        : DateFormat('dd MMM yyyy').format(dashboard.selectedMalaysiaDate!);
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 380;
        final dateFilter = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('malaysia-date-filter'),
                onPressed: dashboard.availableDates.isEmpty
                    ? null
                    : () async {
                        final availableDays = dashboard.availableDates
                            .map(DateUtils.dateOnly)
                            .toSet();
                        final selected = await showDatePicker(
                          context: context,
                          firstDate: availableDays.first,
                          lastDate: availableDays.last,
                          initialDate: dashboard.selectedMalaysiaDate ??
                              availableDays.last,
                          selectableDayPredicate: (date) =>
                              availableDays.contains(DateUtils.dateOnly(date)),
                          helpText: 'Select dashboard date',
                        );
                        if (selected != null) {
                          dashboard.setMalaysiaDate(selected);
                        }
                      },
                icon: const Icon(Icons.calendar_today_outlined),
                label: Text(dateLabel, overflow: TextOverflow.ellipsis),
              ),
            ),
            if (dashboard.selectedMalaysiaDate != null) ...[
              const SizedBox(width: 4),
              IconButton(
                tooltip: 'Show all dashboard dates',
                onPressed: () => dashboard.setMalaysiaDate(null),
                icon: const Icon(Icons.clear),
              ),
            ],
          ],
        );
        final stateFilter = DropdownButtonFormField<String>(
          key: ValueKey('malaysia-state-${dashboard.selectedState}'),
          initialValue: dashboard.selectedState,
          decoration: const InputDecoration(
            labelText: 'Location',
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          isExpanded: true,
          items: dashboard.availableStates
              .map(
                (state) => DropdownMenuItem(
                  value: state,
                  child: Text(state, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: (state) {
            if (state != null) dashboard.setMalaysiaState(state);
          },
        );

        if (narrow) {
          return Column(
            children: [
              dateFilter,
              const SizedBox(height: 12),
              stateFilter,
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: dateFilter),
            const SizedBox(width: 12),
            Expanded(child: stateFilter),
          ],
        );
      },
    );
  }
}

class _NationalConsumptionChart extends StatelessWidget {
  const _NationalConsumptionChart({
    required this.data,
    required this.location,
  });

  final List<EnergyData> data;
  final String location;

  @override
  Widget build(BuildContext context) {
    final summary = data
        .map(
          (record) =>
              '${DateFormat('dd MMMM yyyy').format(record.parsedDate)}: '
              '${record.consumption.toStringAsFixed(1)} gigawatt-hours',
        )
        .join(', ');
    return _ChartCard(
      title: '$location consumption (GWh)',
      semanticsLabel: data.isEmpty
          ? 'No Malaysia energy data for the selected filters.'
          : '$location electricity consumption chart. $summary.',
      child: data.isEmpty
          ? const Center(child: Text('No data for the selected filters.'))
          : data.length == 1
              ? _SingleDataPoint(
                  value: '${data.single.consumption.toStringAsFixed(1)} GWh',
                  caption: DateFormat('dd MMMM yyyy').format(
                    data.single.parsedDate,
                  ),
                )
              : LineChart(
                  _baseChartData(
                    count: data.length,
                    spots: data
                        .asMap()
                        .entries
                        .map(
                          (entry) => FlSpot(
                            entry.key.toDouble(),
                            entry.value.consumption,
                          ),
                        )
                        .toList(),
                    bottomTitle: (index) =>
                        DateFormat('dd/MM').format(data[index].parsedDate),
                    lineColor: AppTheme.accentBlue,
                  ),
                ),
    );
  }
}

class _SingleDataPoint extends StatelessWidget {
  const _SingleDataPoint({required this.value, required this.caption});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.show_chart, size: 40, color: AppTheme.accentBlue),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(caption),
          const SizedBox(height: 8),
          Text(
            'Add or select more dates to see a trend.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.semanticsLabel,
    required this.child,
  });

  final String title;
  final String semanticsLabel;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.accentBlue, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Semantics(
            label: semanticsLabel,
            image: true,
            child: ExcludeSemantics(
              child: SizedBox(height: 220, child: child),
            ),
          ),
        ],
      ),
    );
  }
}

LineChartData _baseChartData({
  required int count,
  required List<FlSpot> spots,
  required String Function(int index) bottomTitle,
  required Color lineColor,
}) {
  return LineChartData(
    minX: 0,
    maxX: count <= 1 ? 1 : (count - 1).toDouble(),
    minY: 0,
    gridData: FlGridData(
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) => FlLine(
        color: Colors.grey.withValues(alpha: 0.2),
      ),
    ),
    titlesData: FlTitlesData(
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 46,
          getTitlesWidget: (value, meta) => Text(
            value.toStringAsFixed(0),
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: count > 5 ? 2 : 1,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= count || value != index.toDouble()) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                bottomTitle(index),
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
            );
          },
        ),
      ),
    ),
    borderData: FlBorderData(show: false),
    lineTouchData: const LineTouchData(enabled: true),
    lineBarsData: [
      LineChartBarData(
        spots: spots,
        isCurved: spots.length > 2,
        color: lineColor,
        barWidth: 3,
        dotData: FlDotData(show: spots.length <= 2),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              lineColor.withValues(alpha: 0.25),
              lineColor.withValues(alpha: 0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),
    ],
  );
}

class _NearbyStateBars extends StatelessWidget {
  const _NearbyStateBars({required this.data, required this.userState});

  final List<EnergyData> data;
  final String userState;

  @override
  Widget build(BuildContext context) {
    final maximum = data
        .map((record) => record.consumption)
        .reduce((a, b) => a > b ? a : b);
    return Column(
      children: data
          .map(
            (record) => Semantics(
              label:
                  '${record.state}${record.state == userState ? ', your state' : ''}, '
                  '${record.consumption.toStringAsFixed(1)} gigawatt-hours',
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            record.state == userState
                                ? '${record.state} (you)'
                                : record.state,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('${record.consumption.toStringAsFixed(0)} GWh'),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: (record.consumption / maximum).clamp(0.0, 1.0),
                        minHeight: 14,
                        color: record.state == userState
                            ? AppTheme.accentBlue
                            : Colors.black,
                        backgroundColor: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DatasetNote extends StatelessWidget {
  const _DatasetNote({required this.firstDate, required this.lastDate});

  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final coverage = firstDate == null || lastDate == null
        ? 'No date coverage available'
        : '${DateFormat('dd MMM yyyy').format(firstDate!)} – '
            '${DateFormat('dd MMM yyyy').format(lastDate!)}';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${DashboardProvider.dataSource}. $coverage. '
              'Includes all 13 states and 3 federal territories; values are '
              'for interface demonstration and are not live grid data.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardLoading extends StatelessWidget {
  const _DashboardLoading({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _EmptyDashboard extends StatelessWidget {
  const _EmptyDashboard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.lightGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _OverviewError extends StatelessWidget {
  const _OverviewError({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
