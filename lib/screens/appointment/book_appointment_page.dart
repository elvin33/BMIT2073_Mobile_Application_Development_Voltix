import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/appointment/appointment.dart';
import '../../models/appointment/company.dart';
import '../../providers/appointment/appointment_provider.dart';

class BookAppointmentPage extends StatefulWidget {
  final Company company;

  const BookAppointmentPage({
    super.key,
    required this.company,
  });

  @override
  State<BookAppointmentPage> createState() => _BookAppointmentPageState();
}

class _BookAppointmentPageState extends State<BookAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedServiceType;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();

    if (widget.company.services.isNotEmpty) {
      _selectedServiceType = widget.company.services.first;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return time.format(context);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 10, minute: 0),
    );

    if (pickedTime == null) {
      return;
    }

    final pickedMin = pickedTime.hour * 60 + pickedTime.minute;
    const openingMin = 9 * 60;
    const closingMin = 17 * 60;

    if (pickedMin < openingMin || pickedMin > closingMin){
      if (!mounted){
        return;
      }

      showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              title: const Text('Invalid Time'),
              content: const Text(
                'Please choose a time between 9:00 AM to 5:00 PM'
              ),
              actions: [
                TextButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    child: const Text('Okay')
                ),
              ],
            );
          },
      );

      return;
    }

    setState(() {
      _selectedTime = pickedTime;
    });
  }

  Future<void> _submitAppointment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please choose date and time'),
        ),
      );
      return;
    }

    final appointment = Appointment(
      id: const Uuid().v4(),
      companyId: widget.company.id,
      companyName: widget.company.name,
      serviceType: _selectedServiceType!,
      date: _formatDate(_selectedDate!),
      time: _formatTime(_selectedTime!),
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      status: 'Current'
    );

    await context.read<AppointmentProvider>().addAppointment(appointment);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Success'),
          content: const Text('Appointment booked successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFE4E4E4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Booking an Appointment',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 15),

                const Text('Service Type'),
                const SizedBox(height: 8),

                DropdownButtonFormField<String>(
                  value: _selectedServiceType,
                  decoration: _inputDecoration('Service Type'),
                  items: widget.company.services.map((service) {
                    return DropdownMenuItem(
                      value: service,
                      child: Text(service),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedServiceType = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please choose a service type';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                const Text('Preferred Date'),
                const SizedBox(height: 8),

                InkWell(
                  onTap: _pickDate,
                  child: InputDecorator(
                    decoration: _inputDecoration('Preferred Date'),
                    child: Text(
                      _selectedDate == null
                          ? 'Choose date'
                          : _formatDate(_selectedDate!),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text('Preferred Time'),
                const SizedBox(height: 8),

                InkWell(
                  onTap: _pickTime,
                  child: InputDecorator(
                    decoration: _inputDecoration('Preferred Time'),
                    child: Text(
                      _selectedTime == null
                          ? 'Choose time'
                          : _formatTime(_selectedTime!),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text('Location'),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _addressController,
                  decoration: _inputDecoration('Location'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your location';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                const Text('Notes (Optional)'),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _notesController,
                  maxLines: 5,
                  decoration: _inputDecoration('Description'),
                ),

                const SizedBox(height: 28),

                Center(
                  child: SizedBox(
                    width: 126,
                    height: 38,
                    child: ElevatedButton(
                      onPressed: _submitAppointment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2B2B2B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Submit'),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}