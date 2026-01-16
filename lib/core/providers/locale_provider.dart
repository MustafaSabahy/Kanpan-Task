import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleProvider() {
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final localeCode = prefs.getString(_localeKey);
      if (localeCode != null) {
        _locale = Locale(localeCode);
        notifyListeners();
      } else {
        // Use device locale as default
        final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
        if (deviceLocale.languageCode == 'de' || 
            deviceLocale.languageCode == 'ar' ||
            deviceLocale.languageCode == 'en') {
          _locale = Locale(deviceLocale.languageCode);
        } else {
          _locale = const Locale('en');
        }
        notifyListeners();
      }
    } catch (e) {
      _locale = const Locale('en');
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    
    _locale = locale;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);
    } catch (e) {
      // Handle error silently
    }
  }

  List<Locale> get supportedLocales => [
    const Locale('en'),
    const Locale('de'),
    const Locale('ar'),
  ];
}
