import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

import 'providers/appointment/appointment_provider.dart';
import 'providers/appointment/company_provider.dart';
import 'screens/appointment/solar_services_page.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  await Supabase.initialize(
    url: 'https://gcntahatgvlzuulaulfy.supabase.co',
    publishableKey: 'sb_publishable_qBrbKup_HP0bygcSJgMZNQ_DcvMhzGN',
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CompanyProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider())
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voltix',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
        ),
      ),
      home: const SolarServicesPage(),
    );
  }
}