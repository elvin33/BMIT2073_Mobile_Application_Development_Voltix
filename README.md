# Voltix

Voltix is a Flutter mobile application prototype for solar service support, electricity issue reporting, and personal electricity usage tracking.

The app helps users browse solar service providers, book and manage appointments, report abnormal electricity or solar-related issues, and compare monthly electricity usage with average usage data.

## Features

- Home page with quick access to all main modules
- Solar service company listing
- Solar service appointment booking
- Appointment rescheduling and cancellation
- Issue reporting with location, urgency, optional contact details, and file attachment
- Report history viewing and deletion
- Personal monthly electricity usage comparison
- Electricity usage dashboard and history chart

## Technology Stack

- Flutter
- Dart
- Provider
- SQLite
- Supabase
- CSV asset data
- fl_chart

## Main Modules

### Home

The Home page is the main entry point of the app. It provides navigation to Solar Services, My Appointments, Report Issue, Report History, and My Usage.

### Appointment Module

The appointment module allows users to view solar companies, book appointments, reschedule bookings, and cancel appointments.

Appointment data is stored locally using SQLite and also saved to Supabase. Company data is loaded from Supabase.

### Report Module

The report module allows users to submit abnormal electricity or solar-related issues with description, location, urgency, optional contact details, and optional file attachment.

Reports are stored locally and saved to Supabase.

### My Usage Module

The My Usage module allows users to enter monthly electricity usage in kWh and compare it with average state usage.

Usage records are stored locally using SQLite. Dashboard statistics are loaded from a bundled CSV dataset.

## Project Structure

```text
lib/
  main.dart
  models/
  providers/
  screens/
  services/
  utils/
  widgets/
assets/
  energy_data.csv