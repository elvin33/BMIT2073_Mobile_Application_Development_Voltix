import 'package:flutter/material.dart';

import '../../models/appointment/appointment.dart';

class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onReschedule;
  final VoidCallback onDelete;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onReschedule,
    required this.onDelete,
  });

  bool get isCurrent => appointment.status.toLowerCase() == 'current';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFFB8B8B8),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.companyName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isCurrent
                      ? const Color(0xFF75E37E)
                      : const Color(0xFFFF3D64),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  appointment.status,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          Text(
            appointment.serviceType,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${appointment.date} (${appointment.time})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5E5E5E),
                  ),
                ),
              ),
            ],
          ),

          if (isCurrent) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: onReschedule,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text(
                      'Reschedule',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onDelete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.red,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}