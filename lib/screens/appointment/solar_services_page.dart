import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/appointment/company_provider.dart';
import '../../widgets/appointment/company_card.dart';
import 'book_appointment_page.dart';
import 'my_appointments_page.dart';

class SolarServicesPage extends StatefulWidget {
  const SolarServicesPage({super.key});

  @override
  State<SolarServicesPage> createState() => _SolarServicesPageState();
}

class _SolarServicesPageState extends State<SolarServicesPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<CompanyProvider>().fetchCompanies();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const Drawer(),
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8B8B8),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'Solar Services',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                              const MyAppointmentsPage(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 180),
                            ),
                          );
                        },
                        child: const Center(
                          child: Text(
                            'My Appointments',
                            style: TextStyle(
                              color: Color(0xFF6D6D6D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Consumer<CompanyProvider>(
                  builder: (context, companyProvider, child) {
                    if (companyProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (companyProvider.errorMessage != null) {
                      return Center(
                        child: Text(companyProvider.errorMessage!),
                      );
                    }

                    if (companyProvider.companies.isEmpty) {
                      return const Center(
                        child: Text('No companies found'),
                      );
                    }

                    return ListView.builder(
                      itemCount: companyProvider.companies.length,
                      itemBuilder: (context, index) {
                        final company = companyProvider.companies[index];

                        return CompanyCard(
                          company: company,
                          onBookNow: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => BookAppointmentPage(
                                  company: company,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
