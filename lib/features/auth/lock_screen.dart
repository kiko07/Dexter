import 'dart:async';
import 'dart:ui';

import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../settings/settings_provider.dart';
import 'auth_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
  bool _obscurePassword = true;
  bool _hasRequestedBiometrics = false;
  Timer? _lockoutTicker;
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    _animController.forward();
    _lockoutTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && ref.read(authProvider).isLockedOut) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _lockoutTicker?.cancel();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final authState = ref.read(authProvider);
    if (_isSubmitting ||
        authState.isLockedOut ||
        authState.status == AuthStatus.storageError) {
      return;
    }

    setState(() => _isSubmitting = true);
    final notifier = ref.read(authProvider.notifier);
    try {
      if (authState.status == AuthStatus.noPasswordSet) {
        await notifier.setPassword(_passwordController.text);
      } else {
        await notifier.authenticate(_passwordController.text);
        if (ref.read(authProvider).error == 'incorrectPassword') {
          _passwordController.clear();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);
    final isSetup = state.status == AuthStatus.noPasswordSet;
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider).value;
    final l10n = AppLocalizations.of(context)!;

    if (!_hasRequestedBiometrics &&
        state.status == AuthStatus.unauthenticated) {
      _hasRequestedBiometrics = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted ||
            ref.read(authProvider).status != AuthStatus.unauthenticated) {
          return;
        }
        ref
            .read(authProvider.notifier)
            .tryBiometricLogin(localizedReason: l10n.authenticateToUnlock);
      });
    }

    if (state.status == AuthStatus.storageError) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: theme.colorScheme.error,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.secureStorageErrorTitle,
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.secureStorageErrorMessage,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final biometricsEnabled = settings?.biometricsEnabled ?? false;
    final hasFaceId =
        settings?.availableBiometrics.contains(BiometricType.face) ?? false;
    final lockoutRemaining = state.lockoutUntil?.difference(DateTime.now());
    final isLockedOut =
        lockoutRemaining != null && lockoutRemaining.inSeconds > 0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.1),
                    theme.scaffoldBackgroundColor,
                    theme.colorScheme.secondary.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: SlideTransition(
              position: _slideAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      width: 340,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: (!isSetup && biometricsEnabled)
                                  ? () => ref
                                        .read(authProvider.notifier)
                                        .tryBiometricLogin(
                                          localizedReason:
                                              l10n.authenticateToUnlock,
                                        )
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isSetup
                                      ? Icons.lock_outline
                                      : (biometricsEnabled
                                            ? (hasFaceId
                                                  ? Icons.face_rounded
                                                  : Icons.fingerprint_rounded)
                                            : Icons.lock),
                                  size: 48,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              isSetup
                                  ? l10n.setupNewPassword
                                  : l10n.enterPassword,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textAlign: TextAlign.start,
                              style: const TextStyle(fontSize: 18),
                              validator: (value) =>
                                  value == null || value.length < 4
                                  ? l10n.passwordTooShort
                                  : null,
                              decoration: InputDecoration(
                                hintText: '********',
                                errorText: state.error == 'incorrectPassword'
                                    ? l10n.currentPasswordIncorrect
                                    : state.error,
                                prefixIcon: const Icon(Icons.key),
                                suffixIcon: IconButton(
                                  tooltip: _obscurePassword
                                      ? l10n.showPassword
                                      : l10n.hidePassword,
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_rounded
                                        : Icons.visibility_off_rounded,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              onFieldSubmitted: (_) => _submit(),
                            ),
                            if (isLockedOut) ...[
                              const SizedBox(height: 12),
                              Text(
                                l10n.lockedOutSeconds(
                                  lockoutRemaining.inSeconds,
                                ),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _isSubmitting || isLockedOut
                                    ? null
                                    : _submit,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: _isSubmitting
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        isSetup
                                            ? l10n.saveAndStart
                                            : l10n.login,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                              ),
                            ),
                            if (!isSetup && biometricsEnabled) ...[
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: isLockedOut
                                    ? null
                                    : () => ref
                                          .read(authProvider.notifier)
                                          .tryBiometricLogin(
                                            localizedReason:
                                                l10n.authenticateToUnlock,
                                          ),
                                icon: Icon(
                                  hasFaceId
                                      ? Icons.face_rounded
                                      : Icons.fingerprint_rounded,
                                ),
                                label: Text(
                                  hasFaceId
                                      ? l10n.useFaceId
                                      : l10n.useFingerprint,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
