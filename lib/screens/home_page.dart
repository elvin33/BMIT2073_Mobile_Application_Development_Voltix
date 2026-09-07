import 'package:flutter/material.dart';

import '../widgets/drawer.dart';
import 'appointment/solar_services_page.dart';
import 'appointment/my_appointments_page.dart';
import 'report/report_issue_page.dart';
import 'report/report_history_page.dart';
import 'usage/my_usage_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void _goToPage(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  Widget _homeCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required Widget page,
  }) {
    return Card(
      color: const Color(0xFFE8E8E8),
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 12,
        ),
        leading: Icon(
          icon,
          color: Colors.black,
          size: 30,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF555555),
            ),
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _goToPage(context, page);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 18,
          ),
          children: [
            const Text(
              'Welcome to Voltix',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Manage solar services, report energy issues, and track electricity usage.',
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 26),

            _homeCard(
              context: context,
              icon: Icons.solar_power,
              title: 'Solar Services',
              description: 'Browse solar companies and book appointments.',
              page: const SolarServicesPage(),
            ),

            _homeCard(
              context: context,
              icon: Icons.calendar_month,
              title: 'My Appointments',
              description: 'View, reschedule, or cancel your bookings.',
              page: const MyAppointmentsPage(),
            ),

            _homeCard(
              context: context,
              icon: Icons.report_problem_outlined,
              title: 'Report Issue',
              description: 'Submit abnormal electricity or solar-related issues.',
              page: const ReportIssuePage(),
            ),

            _homeCard(
              context: context,
              icon: Icons.history,
              title: 'Report History',
              description: 'View your submitted reports.',
              page: const ReportHistoryPage(),
            ),

            _homeCard(
              context: context,
              icon: Icons.bolt,
              title: 'My Usage',
              description: 'Track monthly kWh usage and compare with state average.',
              page: const MyUsageScreen(),
            ),
          ],
        ),
      ),
    );
  }
}