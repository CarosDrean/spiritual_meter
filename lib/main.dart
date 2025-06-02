import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:spiritual_meter/services/notification_service.dart';
import 'package:spiritual_meter/screens/settings/settings_viewmodel.dart';
import 'package:spiritual_meter/screens/home/home_viewmodel.dart';
import 'package:spiritual_meter/core/constant.dart';
import 'package:spiritual_meter/core/theme.dart';
import 'package:spiritual_meter/screens/main_screen.dart';
import 'package:spiritual_meter/screens/statistics/statistics_viewmodel.dart';
import 'package:spiritual_meter/screens/records/records_viewmodel.dart';

Future<void> _configureLocalTimezone() async {
  tz.initializeTimeZones();

  String? timeZoneName;
  try {
    timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  } on PlatformException {
    timeZoneName = 'America/Lima';
  }

  try {
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  } catch (e) {
    tz.setLocalLocation(tz.UTC);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureLocalTimezone();
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        ChangeNotifierProvider(create: (_) => StatisticsViewModel()),
        ChangeNotifierProvider(create: (_) => RecordViewModel()),
        ChangeNotifierProvider(create: (_) => SettingsViewModel()),
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
      title: kAppName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en', ''), Locale('es', '')],
    );
  }
}
