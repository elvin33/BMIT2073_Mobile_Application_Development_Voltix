import 'package:flutter/material.dart';

import '../screens/appointment/solar_services_page.dart';
import '../screens/report/report_history_page.dart';
import '../screens/report/report_issue_page.dart';
import '../screens/usage/my_usage_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  void _goToPage(BuildContext context, Widget page) {
    Navigator.pop(context);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => page,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFFFF1F3),
      child: Column(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Voltix',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.solar_power),
            title: const Text('Solar Services'),
            onTap: () {
              _goToPage(context, const SolarServicesPage());
            },
          ),

          ListTile(
            leading: const Icon(Icons.bolt),
            title: const Text('My Usage'),
            onTap: () {
              _goToPage(context, const MyUsageScreen());
            },
          ),

          ListTile(
            leading: const Icon(Icons.report_problem_outlined),
            title: const Text('Report Issue'),
            onTap: () {
              _goToPage(context, const ReportIssuePage());
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Report History'),
            onTap: () {
              _goToPage(context, const ReportHistoryPage());
            },
          ),
        ],
      ),
    );
  }
}