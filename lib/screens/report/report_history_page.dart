import 'package:assignment/widgets/drawer.dart';
import 'package:flutter/material.dart';
import '../../services/report/report_database_helper.dart';

class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  List<Map<String, dynamic>> reports = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadReports();
  }

  // ============================================================
  // LOAD REPORTS FROM DATABASE
  // ============================================================

  Future<void> loadReports() async {
    try {
      final data = await ReportDatabaseHelper.instance.getReports();

      print('REPORTS FROM DATABASE: $data');

      if (!mounted) return;

      setState(() {
        reports = data;
        isLoading = false;
      });
    } catch (e) {
      print('LOAD REPORT ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load reports: $e'),
        ),
      );
    }
  }

  // ============================================================
  // DELETE REPORT
  // ============================================================

  Future<void> deleteReport(int id) async {
    try {
      await ReportDatabaseHelper.instance.deleteReport(id);

      await loadReports();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report deleted'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete report: $e'),
        ),
      );
    }
  }

  // ============================================================
  // CONFIRM DELETE
  // ============================================================

  void showDeleteDialog(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Report'),
          content: const Text(
            'Are you sure you want to delete this report?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteReport(id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return '';
    }

    try {
      final parsedDate = DateTime.parse(date);

      return '${parsedDate.day.toString().padLeft(2, '0')}/'
          '${parsedDate.month.toString().padLeft(2, '0')}/'
          '${parsedDate.year} '
          '${parsedDate.hour.toString().padLeft(2, '0')}:'
          '${parsedDate.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }

  // ============================================================
  // REPORT CARD
  // ============================================================

  Widget buildReportCard(Map<String, dynamic> report) {
    final int id = report['id'] as int;

    final String description =
        report['description']?.toString() ?? '';

    final String location =
        report['location']?.toString() ?? '';

    final String urgency =
        report['urgency']?.toString() ?? '';

    final String nameEmail =
        report['nameEmail']?.toString() ?? '';

    final String fileName =
        report['fileName']?.toString() ?? '';

    final String createdAt =
        report['createdAt']?.toString() ?? '';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ====================================================
          // TOP ROW
          // ====================================================

          Row(
            children: [
              const Icon(
                Icons.report_problem_outlined,
                size: 22,
              ),

              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  'Report #$id',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              IconButton(
                onPressed: () {
                  showDeleteDialog(id);
                },
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ====================================================
          // DESCRIPTION
          // ====================================================

          const Text(
            'Issue',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            description,
            style: const TextStyle(
              fontSize: 15,
            ),
          ),

          const SizedBox(height: 12),

          // ====================================================
          // LOCATION
          // ====================================================

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 20,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  location,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // ====================================================
          // URGENCY
          // ====================================================

          Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                size: 20,
              ),

              const SizedBox(width: 6),

              Text(
                'Urgency: $urgency',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),

          // ====================================================
          // NAME / EMAIL
          // ====================================================

          if (nameEmail.isNotEmpty) ...[
            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 20,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    nameEmail,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // ====================================================
          // FILE
          // ====================================================

          if (fileName.isNotEmpty) ...[
            const SizedBox(height: 8),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.attach_file,
                  size: 20,
                ),

                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    fileName,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 10),

          // ====================================================
          // DATE
          // ====================================================

          Text(
            formatDate(createdAt),
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: const Text(
          'Report History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),

        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : reports.isEmpty
          ? RefreshIndicator(
        onRefresh: loadReports,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 200),
            Center(
              child: Text(
                'No reports yet',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: loadReports,
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB( 20, 20, 20, 30 ),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            return buildReportCard(
              reports[index],
            );
          },
        ),
      ),
    );
  }
}