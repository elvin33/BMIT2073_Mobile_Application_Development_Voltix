import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/appointment/appointment.dart';
import '../../providers/appointment/appointment_provider.dart';
import '../../widgets/appointment/appointment_card.dart';
import '../report/report_issue_page.dart';
import '../../widgets/drawer.dart';
import 'solar_services_page.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AppointmentProvider>().loadAppointment();
    });
  }

  Future<void> _deleteAppointment(Appointment appointment) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: const Text('Are you sure you want to cancel this appointment?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    if (!mounted) return;

    await context.read<AppointmentProvider>().deleteAppointment(appointment.id);
  }

  Future<void> _rescheduleAppointment(Appointment appointment) async {
    final now = DateTime.now();

    final newDate = await showDatePicker(
        context: context,
        initialDate: now,
        firstDate: now,
        lastDate: DateTime(now.year + 2)
    );

    if (newDate == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    final newTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0)
    );

    if (newTime == null) {
      return;
    }

    final pickedMin = newTime.hour * 60 + newTime.minute;
    const openingMin = 9 * 60;
    const closingMin = 17 * 60;

    if (pickedMin < openingMin || pickedMin > closingMin){
      if (!mounted) {
        return;
      }

      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Invalid Item'),
              content: const Text('Please choose a time between 9:00 AM to 5:00 PM'),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text('Okay')
                )
              ],
            );
          },
      );

      return;
    }

    if (!mounted) {
      return;
    }

    final updatedAppointment = appointment.copyWith(
      date: '${newDate.day}/${newDate.month}/${newDate.year}',
      time: newTime.format(context)
    );

    await context
        .read<AppointmentProvider>()
        .updateAppointment(updatedAppointment);
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
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                              const SolarServicesPage(),
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
                            'Solar Services',
                            style: TextStyle(
                              color: Color(0xFF6D6D6D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'My Appointments',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child: Consumer<AppointmentProvider>(
                  builder: (context, appointmentProvider, child) {
                    if (appointmentProvider.isLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (appointmentProvider.errorMessage != null) {
                      return Center(
                        child: Text(appointmentProvider.errorMessage!),
                      );
                    }

                    if (appointmentProvider.appointments.isEmpty) {
                      return const Center(
                        child: Text('No appointments yet'),
                      );
                    }

                    return ListView.builder(
                      itemCount: appointmentProvider.appointments.length,
                      itemBuilder: (context, index) {
                        final appointment =
                        appointmentProvider.appointments[index];

                        return AppointmentCard(
                          appointment: appointment,
                          onReschedule: () {
                            _rescheduleAppointment(appointment);
                          },
                          onDelete: () {
                            _deleteAppointment(appointment);
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
