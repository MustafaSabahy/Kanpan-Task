import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'gen/l10n/app_localizations.dart';
// import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
// import 'core/providers/locale_provider.dart';
import 'core/services/notification_service.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/splash_screen.dart';
import 'presentation/bloc/bloc_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  runApp(
    MultiBlocProvider(
      providers: BlocProviders.providers,
      // child: ChangeNotifierProvider(
      //   create: (_) => LocaleProvider(),
      //   child: const TaskTrackerApp(),
      // ),
      child: const TaskTrackerApp(),
    ),
  );
}

class TaskTrackerApp extends StatefulWidget {
  const TaskTrackerApp({super.key});

  @override
  State<TaskTrackerApp> createState() => _TaskTrackerAppState();
}

class _TaskTrackerAppState extends State<TaskTrackerApp> {
  bool _isDarkMode = false;

  void toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      // locale: localeProvider.locale,
      // localizationsDelegates: const [
      //   AppLocalizations.delegate,
      //   GlobalMaterialLocalizations.delegate,
      //   GlobalWidgetsLocalizations.delegate,
      //   GlobalCupertinoLocalizations.delegate,
      // ],
      // supportedLocales: const [
      //   Locale('en'),
      //   Locale('de'),
      //   Locale('ar'),
      // ],
      // builder: (context, child) {
      //   return Directionality(
      //     textDirection: localeProvider.locale.languageCode == 'ar'
      //         ? TextDirection.rtl
      //         : TextDirection.ltr,
      //     child: child!,
      //   );
      // },
      home: SplashScreen(
        child: HomeScreen(
          onDarkModeChanged: toggleDarkMode,
          isDarkMode: _isDarkMode,
        ),
      ),
    );
  }
}
