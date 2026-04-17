import 'package:citypulse/firebase_options.dart';
import 'package:citypulse/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ✅ ADD THESE TWO
import 'package:firebase_core/firebase_core.dart';

import 'services/auth_service.dart';
import 'services/issue_service.dart';
import 'services/notification_service.dart';

import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/report/report_issue_screen.dart';
import 'screens/map/map_screen.dart';
import 'screens/admin/admin_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ PASTE THIS EXACTLY HERE
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const CityPulseApp());
}

class CityPulseApp extends StatelessWidget {
  const CityPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()..bootstrap()),
        ChangeNotifierProvider(create: (_) => IssueService()..bootstrap()),
        Provider(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        title: 'CityPulse',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          primaryColor: const Color(0xFF2196F3),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue),
          fontFamily: 'Inter',
          scaffoldBackgroundColor: const Color(0xFFF7F9FC),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            elevation: 0.5,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/login': (_) => const LoginScreen(),
          '/signup': (_) => const SignupScreen(),
          '/home': (_) => const HomeScreen(),
          '/report': (_) => const ReportIssueScreen(),
          '/map': (_) => const MapScreen(),
          '/admin': (_) => const AdminDashboard(),
        },
      ),
    );
  }
}
