import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:life_hub/providers/maintenance_provider.dart';
import 'package:life_hub/providers/event_provider.dart';
import 'package:life_hub/providers/todo_provider.dart';
import 'package:life_hub/providers/expense_provider.dart';
import 'package:life_hub/providers/theme_provider.dart';
import 'package:life_hub/providers/settings_provider.dart';
import 'package:life_hub/providers/profile_provider.dart';
import 'package:life_hub/features/dashboard/screens/dashboard_screen.dart';
import 'package:life_hub/data/local/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Open boxes
  await Hive.openBox('maintenanceBox');
  await Hive.openBox('eventBox');
  await Hive.openBox('todoBox');
  await Hive.openBox('expenseBox');
  await Hive.openBox('settingsBox');
  
  // Initialize notifications
  await NotificationService.initialize();
  
  // Request permissions
  await Permission.notification.request();
  await Permission.scheduleExactAlarm.request();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => MaintenanceProvider()),
        ChangeNotifierProvider(create: (_) => EventProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'LifeHub',
            debugShowCheckedModeBanner: false,
            theme: themeProvider.lightTheme,
            darkTheme: themeProvider.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const DashboardScreen(),
          );
        },
      ),
    );
  }
}