import 'dart:io';

class ApiConfig {
  // ─── Configuración de entorno ────────────────────────────

  /// IP de tu computadora en la red local (para desarrollo móvil).
  static const String _localIP = '192.168.0.48';

  /// Puerto del backend (desarrollo local).
  static const String _port = '3000';

  /// Modo desarrollo: `true` = apunta a IP local, `false` = producción.
  static const bool _devMode = true;

  /// URL base de producción.
  static const String _prodUrl = 'https://api.naturalmarkets.net/api';

  // ─── URL Base ────────────────────────────────────────────

  static String get baseUrl {
    return _devMode ? 'http://$_localIP:$_port/api' : _prodUrl;
  }

  // Metodo para cambiar manualmente la configuracion
  static String getUrlForMode({required bool useProduction}) {
    if (useProduction) {
      return _prodUrl;
    } else {
      return 'http://$_localIP:$_port/api';
    }
  }

  // Informacion de debug
  static Map<String, dynamic> getDebugInfo() {
    return <String, dynamic>{
      'baseUrl': baseUrl,
      'devMode': _devMode,
      'isProduction': !_devMode,
      'productionUrl': _prodUrl,
      'localUrl': 'http://$_localIP:$_port/api',
      'platform': Platform.operatingSystem,
    };
  }
}
