import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/bindings/initial_binding.dart';
import 'src/routes/app_pages.dart';
import 'src/routes/app_routes.dart';

// Supabase Credentials
const String supabaseUrl = 'https://uptqjoulpqldqcmrhxzt.supabase.co';
const String supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVwdHFqb3VscHFsZHFjbXJoeHp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjgxNDQwNDMsImV4cCI6MjA4MzcyMDA0M30.P4TznmkoJJh-rGRR5EzqN13P5hAQEQmB_htLQoikiNA';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  // supaya currentSession SELALU null saat start
  await Supabase.instance.client.auth.signOut();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Absensi QR Wali Murid',
      debugShowCheckedModeBanner: false,

      initialBinding: InitialBinding(),

      // Selalu mulai dari LOGIN
      initialRoute: AppRoutes.login,

      getPages: AppPages.pages,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      ),
    );
  }
}
