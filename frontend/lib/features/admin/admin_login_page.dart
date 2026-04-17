import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart' as ui;

class AdminLoginPage extends ConsumerStatefulWidget {
  const AdminLoginPage({super.key});

  @override
  ConsumerState<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends ConsumerState<AdminLoginPage> {
  final _email = TextEditingController(text: 'admin@wedding.com');
  final _password = TextEditingController(text: 'wedding2026');
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(adminTokenProvider.notifier)
          .login(_email.text.trim(), _password.text);
      if (mounted) context.go('/admin/dashboard');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Could not reach backend ($e)');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFE5EC), Color(0xFFFDF6E3), Color(0xFFFFF5F7)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: GlassCard(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Text('Wedding Admin',
                        style: AppTheme.script(size: 32, color: AppPalette.roseDeep)),
                    const SizedBox(height: 4),
                    Text('Welcome back',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontSize: 28)),
                    const SizedBox(height: 4),
                    const Text(
                      'Sign in to manage your guest list & RSVPs.',
                      style: TextStyle(color: AppPalette.muted),
                    ),
                    const SizedBox(height: 22),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onSubmitted: (_) => _submit(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!,
                          style: const TextStyle(color: AppPalette.roseDeep)),
                    ],
                    const SizedBox(height: 18),
                    ui.PrimaryButton(
                      label: _loading ? 'Signing in...' : 'Sign in',
                      icon: Icons.login,
                      onPressed: _loading ? null : _submit,
                      expanded: true,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Default: admin@wedding.com / wedding2026 (change via backend env)',
                      style: TextStyle(fontSize: 11, color: AppPalette.muted),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: .15),
            ),
          ),
        ),
      ),
    );
  }
}
