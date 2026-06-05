import 'dart:ui';
import 'package:dexter/core/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'auth_provider.dart';
import '../settings/settings_provider.dart';

class LockScreen extends ConsumerStatefulWidget {
  const LockScreen({super.key});

  @override
  ConsumerState<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends ConsumerState<LockScreen>
    with SingleTickerProviderStateMixin {
  final _passwordController = TextEditingController();
  bool _isSubmitting = false;
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
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _submit() async {
    final password = _passwordController.text;
    if (password.isNotEmpty && !_isSubmitting) {
      setState(() => _isSubmitting = true);
      final authState = ref.read(authProvider);
      final notifier = ref.read(authProvider.notifier);

      if (authState.status == AuthStatus.noPasswordSet) {
        await notifier.setPassword(password);
      } else {
        await notifier.authenticate(password);
      }
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
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.value;

    final biometricsEnabled = settings?.biometricsEnabled ?? false;
    final hasFaceId =
        settings?.availableBiometrics.contains(BiometricType.face) ?? false;

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
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

          // Decorative shapes
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.secondary.withValues(alpha: 0.05),
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
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: (!isSetup && biometricsEnabled)
                                ? () => ref
                                      .read(authProvider.notifier)
                                      .tryBiometricLogin()
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
                                ? AppLocalizations.of(context)!.setupNewPassword
                                : AppLocalizations.of(context)!.enterPassword,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          TextField(
                            controller: _passwordController,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              letterSpacing: 4,
                              fontSize: 18,
                            ),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: const TextStyle(letterSpacing: 4),
                              errorText: state.error,
                              prefixIcon: const Icon(Icons.key),
                            ),
                            onSubmitted: (_) => _submit(),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submit,
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
                                          ? AppLocalizations.of(
                                              context,
                                            )!.saveAndStart
                                          : AppLocalizations.of(context)!.login,
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                          if (!isSetup && biometricsEnabled) ...[
                            const SizedBox(height: 16),
                            TextButton.icon(
                              onPressed: () => ref
                                  .read(authProvider.notifier)
                                  .tryBiometricLogin(),
                              icon: Icon(
                                hasFaceId
                                    ? Icons.face_rounded
                                    : Icons.fingerprint_rounded,
                              ),
                              label: Text(
                                hasFaceId ? 'Use Face ID' : 'Use Fingerprint',
                              ),
                              style: TextButton.styleFrom(
                                foregroundColor: theme.colorScheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                  horizontal: 24,
                                ),
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
        ],
      ),
    );
  }
}
