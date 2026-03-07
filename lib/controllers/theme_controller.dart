import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../config/theme_config.dart';
import '../services/theme_service.dart';

class ThemeController extends GetxController {
  // Variables reactivas
  final RxString _currentThemeId = 'synergy'.obs;
  final Rx<ThemeMode> _themeMode = ThemeMode.system.obs;
  final RxBool _isInitialized = false.obs;

  // Getters
  String get currentThemeId => _currentThemeId.value;
  ThemeMode get themeMode => _themeMode.value;
  bool get isInitialized => _isInitialized.value;
  
  // Obtener el tema actual
  AppTheme get currentTheme => ThemeConfig.getThemeById(_currentThemeId.value);
  
  // Obtener todos los temas disponibles
  List<AppTheme> get availableThemes => ThemeConfig.availableThemes;

  @override
  void onInit() {
    super.onInit();
    _initializeTheme();
  }

  // Inicializar el tema desde las preferencias guardadas
  Future<void> _initializeTheme() async {
    try {
      final String savedThemeId = await ThemeService.getSavedTheme();
      final String savedThemeMode = await ThemeService.getSavedThemeMode();
      
      _currentThemeId.value = savedThemeId;
      _themeMode.value = _parseThemeMode(savedThemeMode);
      _isInitialized.value = true;
      
      // Aplicar el tema inmediatamente
      _applyTheme();
    } catch (e) {

      _isInitialized.value = true;
    }
  }

  // Cambiar el tema actual
  Future<void> changeTheme(String themeId) async {
    if (themeId == _currentThemeId.value) return;
    
    try {
      _currentThemeId.value = themeId;
      await ThemeService.saveTheme(themeId);
      
      // Aplicar el tema inmediatamente
      _applyTheme();
      
      // Pequeño delay para asegurar que el tema se aplique
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Mostrar snackbar de confirmación
      Get.snackbar(
        'Tema cambiado',
        'Se aplicó el tema ${currentTheme.name}',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: currentTheme.primaryColor.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {

      Get.snackbar(
        'Error',
        'No se pudo cambiar el tema',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  // Cambiar el modo del tema (light/dark/system)
  Future<void> changeThemeMode(ThemeMode mode) async {
    if (mode == _themeMode.value) return;
    
    try {
      _themeMode.value = mode;
      await ThemeService.saveThemeMode(_themeModeToString(mode));
      _applyTheme();
      
      String modeName = '';
      switch (mode) {
        case ThemeMode.light:
          modeName = 'Claro';
          break;
        case ThemeMode.dark:
          modeName = 'Oscuro';
          break;
        case ThemeMode.system:
          modeName = 'Sistema';
          break;
      }
      
      Get.snackbar(
        'Modo cambiado',
        'Se aplicó el modo $modeName',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        backgroundColor: currentTheme.primaryColor.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo cambiar el modo del tema',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  // Aplicar el tema actual a la aplicación
  void _applyTheme() {
    // Cambiar el modo del tema primero
    Get.changeThemeMode(_themeMode.value);
    
    // Aplicar el tema claro
    Get.changeTheme(currentTheme.lightTheme);
    
    // Forzar la actualización completa de la app
    Get.forceAppUpdate();
    
    // Notificar a todos los observers que el tema cambió
    update();
  }

  // Obtener colores actuales basados en el contexto
  ColorScheme getCurrentColors(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return currentTheme.darkTheme.colorScheme;
    }
    return currentTheme.lightTheme.colorScheme;
  }

  // Obtener colores específicos para funcionalidades
  Color get successColor => ThemeConfig.successColor;
  Color get errorColor => ThemeConfig.errorColor;
  Color get warningColor => ThemeConfig.warningColor;
  Color get infoColor => ThemeConfig.infoColor;
  Color get deleteColor => ThemeConfig.deleteColor;
  Color get editColor => ThemeConfig.editColor;
  Color get addColor => ThemeConfig.addColor;

  // Resetear tema a valores por defecto
  Future<void> resetTheme() async {
    try {
      await ThemeService.clearThemePreferences();
      _currentThemeId.value = 'synergy';
      _themeMode.value = ThemeMode.system;
      _applyTheme();
      
      Get.snackbar(
        'Tema restablecido',
        'Se aplicó el tema por defecto',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: currentTheme.primaryColor.withValues(alpha: 0.8),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo restablecer el tema',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  // Verificar si es el tema actual
  bool isCurrentTheme(String themeId) => _currentThemeId.value == themeId;

  // Verificar si es el modo actual
  bool isCurrentThemeMode(ThemeMode mode) => _themeMode.value == mode;

  // Utilidades privadas
  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
