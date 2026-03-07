import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'selected_theme';
  static const String _themeModeKey = 'theme_mode';
  
  // Obtener la preferencia de tema guardada
  static Future<String> getSavedTheme() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeKey) ?? 'synergy'; // tema por defecto
  }
  
  // Guardar la preferencia de tema
  static Future<void> saveTheme(String themeId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeId);
  }
  
  // Obtener el modo de tema guardado (light/dark/system)
  static Future<String> getSavedThemeMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_themeModeKey) ?? 'system'; // modo por defecto
  }
  
  // Guardar el modo de tema
  static Future<void> saveThemeMode(String mode) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, mode);
  }
  
  // Limpiar todas las preferencias de tema
  static Future<void> clearThemePreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
    await prefs.remove(_themeModeKey);
  }
}
