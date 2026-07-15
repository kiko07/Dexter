import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/utils/secure_storage_service.dart';

const _authProbeTimeout = Duration(seconds: 3);
const _authPromptTimeout = Duration(seconds: 30);

enum AuthStatus {
  loading,
  unauthenticated, // Needs password
  authenticated, // Logged in
  noPasswordSet, // First time setup
  storageError, // Secure storage is unavailable or unreadable
}

class AuthState {
  final AuthStatus status;
  final String? error;
  final int failedAttempts;
  final DateTime? lockoutUntil;

  AuthState({
    this.status = AuthStatus.loading,
    this.error,
    this.failedAttempts = 0,
    this.lockoutUntil,
  });

  bool get isLockedOut =>
      lockoutUntil != null && DateTime.now().isBefore(lockoutUntil!);
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
      } else {
        state = AuthState(status: AuthStatus.noPasswordSet);
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.storageError, error: e.toString());
    }
  }

  Future<void> tryBiometricLogin({required String localizedReason}) async {
    if (state.status == AuthStatus.storageError || state.isLockedOut) return;
    final enabled = await SecureStorageService.isBiometricsEnabled();
    if (!enabled) return;

    final LocalAuthentication auth = LocalAuthentication();
    try {
      final canAuthenticateWithBiometrics = await auth.canCheckBiometrics
          .timeout(_authProbeTimeout, onTimeout: () => false);
      final canAuthenticate =
          canAuthenticateWithBiometrics ||
          await auth.isDeviceSupported().timeout(
            _authProbeTimeout,
            onTimeout: () => false,
          );

      if (canAuthenticate) {
        final didAuthenticate = await auth
            .authenticate(localizedReason: localizedReason, biometricOnly: true)
            .timeout(_authPromptTimeout, onTimeout: () => false);
        // Only set authenticated if state is still unauthenticated
        // (guards against race with password entry)
        if (didAuthenticate && state.status == AuthStatus.unauthenticated) {
          state = AuthState(status: AuthStatus.authenticated);
        }
      }
    } catch (e) {
      // Ignore biometric errors gracefully
    }
  }

  Future<void> authenticate(String password) async {
    if (state.isLockedOut || state.status == AuthStatus.storageError) return;

    try {
      final isValid = await SecureStorageService.verifyPassword(password);
      if (isValid) {
        state = AuthState(status: AuthStatus.authenticated);
      } else {
        final failedAttempts = state.failedAttempts + 1;
        final lockoutUntil = failedAttempts >= 5
            ? DateTime.now().add(_backoffFor(failedAttempts))
            : null;
        state = AuthState(
          status: AuthStatus.unauthenticated,
          error: 'incorrectPassword',
          failedAttempts: failedAttempts,
          lockoutUntil: lockoutUntil,
        );
      }
    } catch (e) {
      state = AuthState(status: AuthStatus.storageError, error: e.toString());
    }
  }

  Future<bool> setPassword(String password) async {
    try {
      await SecureStorageService.setAppPassword(password);
      state = AuthState(status: AuthStatus.authenticated);
      return true;
    } catch (e) {
      state = AuthState(status: AuthStatus.storageError, error: e.toString());
      return false;
    }
  }

  void lock() {
    state = AuthState(status: AuthStatus.unauthenticated);
  }

  Future<void> resetApp() async {
    await SecureStorageService.removePassword();
    state = AuthState(status: AuthStatus.noPasswordSet);
  }

  Duration _backoffFor(int failedAttempts) {
    final exponent = (failedAttempts - 5).clamp(0, 4).toInt();
    final seconds = (30 * (1 << exponent)).clamp(30, 300).toInt();
    return Duration(seconds: seconds);
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
