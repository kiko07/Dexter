import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/utils/secure_storage_service.dart';

enum AuthStatus {
  loading,
  unauthenticated, // Needs password
  authenticated,   // Logged in
  noPasswordSet    // First time setup
}

class AuthState {
  final AuthStatus status;
  final String? error;

  AuthState({this.status = AuthStatus.loading, this.error});
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    _checkInitialState();
    return AuthState();
  }

  Future<void> _checkInitialState() async {
    try {
      final hasPassword = await SecureStorageService.hasPassword();
      if (hasPassword) {
        state = AuthState(status: AuthStatus.unauthenticated);
        _tryBiometricLogin();
      } else {
        state = AuthState(status: AuthStatus.noPasswordSet);
      }
    } catch (e) {
      // If secure storage fails, allow access but treat as no password set
      state = AuthState(status: AuthStatus.noPasswordSet, error: e.toString());
    }
  }

  Future<void> _tryBiometricLogin() async {
    final enabled = await SecureStorageService.isBiometricsEnabled();
    if (!enabled) return;

    final LocalAuthentication auth = LocalAuthentication();
    try {
      final canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final canAuthenticate = canAuthenticateWithBiometrics || await auth.isDeviceSupported();
      
      if (canAuthenticate) {
        final didAuthenticate = await auth.authenticate(
          localizedReason: 'Please authenticate to unlock the app',
          persistAcrossBackgrounding: true,
          biometricOnly: true,
        );
        if (didAuthenticate) {
          state = AuthState(status: AuthStatus.authenticated);
        }
      }
    } catch (e) {
      // Ignore biometric errors gracefully
    }
  }

  Future<void> authenticate(String password) async {
    final isValid = await SecureStorageService.verifyPassword(password);
    if (isValid) {
      state = AuthState(status: AuthStatus.authenticated);
    } else {
      state = AuthState(status: AuthStatus.unauthenticated, error: 'incorrectPassword'); // Incorrect password
    }
  }

  Future<void> setPassword(String password) async {
    await SecureStorageService.setAppPassword(password);
    state = AuthState(status: AuthStatus.authenticated);
  }

  void lock() {
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> resetApp() async {
    await SecureStorageService.removePassword();
    state = AuthState(status: AuthStatus.noPasswordSet);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
