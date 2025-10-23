import 'package:get_storage/get_storage.dart';

/// Servicio de almacenamiento de autenticación cross-platform
/// Utiliza GetStorage que ya funciona en web y móvil
class AuthStorage {
  static final AuthStorage _instance = AuthStorage._internal();
  factory AuthStorage() => _instance;
  AuthStorage._internal();

  final GetStorage _storage = GetStorage();

  // Keys para el almacenamiento
  static const String _keyEmail = 'email';
  static const String _keyPassword = 'contrasena';
  static const String _keyHasSession = 'hasSession';

  /// Inicializa el storage (ya se hace en main pero por si acaso)
  Future<void> init() async {
    await GetStorage.init();
  }

  /// Guarda las credenciales de autenticación
  /// NOTA: En producción se recomienda usar tokens en lugar de contraseñas
  Future<void> saveAuthData(String email, String password) async {
    await _storage.write(_keyEmail, email);
    await _storage.write(_keyPassword, password);
    await _storage.write(_keyHasSession, true);
  }

  /// Lee las credenciales guardadas
  /// Retorna un Map con 'email' y 'password', o null si no hay datos
  Map<String, String>? readAuthData() {
    final email = _storage.read<String>(_keyEmail);
    final password = _storage.read<String>(_keyPassword);
    final hasSession = _storage.read<bool>(_keyHasSession) ?? false;

    if (hasSession &&
        email != null &&
        password != null &&
        email.isNotEmpty &&
        password.isNotEmpty) {
      return {'email': email, 'password': password};
    }
    return null;
  }

  /// Verifica si hay una sesión guardada
  bool hasSession() {
    return _storage.read<bool>(_keyHasSession) ?? false;
  }

  /// Limpia todos los datos de autenticación (logout)
  Future<void> clearAuthData() async {
    await _storage.remove(_keyEmail);
    await _storage.remove(_keyPassword);
    await _storage.remove(_keyHasSession);
  }

  /// Obtiene solo el email guardado
  String? getEmail() {
    return _storage.read<String>(_keyEmail);
  }

  /// Obtiene solo la contraseña guardada
  String? getPassword() {
    return _storage.read<String>(_keyPassword);
  }
}
