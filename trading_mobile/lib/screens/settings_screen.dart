import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/application/auth_providers.dart';
import '../features/auth/data/auth_repository.dart';
import '../providers/api_config_provider.dart';
import '../theme/design_system.dart';
import '../theme/theme_mode_provider.dart';
import '../widgets/settings_tile.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _apiCtrl;

  @override
  void initState() {
    super.initState();
    _apiCtrl = TextEditingController(text: ref.read(apiBaseUrlProvider));
  }

  @override
  void dispose() {
    _apiCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveApiUrl() async {
    final url = _apiCtrl.text.trim();
    if (url.isEmpty) return;
    await persistApiBaseUrl(url);
    ref.read(apiBaseUrlProvider.notifier).state = url;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API base URL saved. Requests use the new host immediately.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(themeModeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? null : AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Account, preferences, and connectivity.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            SettingsTile(
              icon: Icons.info_outline_rounded,
              title: 'App info',
              subtitle: 'AI Trading · v1.0.0',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'AI Trading',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© ${DateTime.now().year}',
                );
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            SettingsTile(
              icon: Icons.warning_amber_rounded,
              title: 'Risk disclaimer',
              subtitle: 'Not financial advice',
              onTap: () => _showSheet(
                context,
                title: 'Risk disclaimer',
                body:
                    'Trading involves substantial risk. Past performance does not guarantee future results. '
                    'This app provides informational signals only and does not constitute investment advice.',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            SettingsTile(
              icon: Icons.gavel_rounded,
              title: 'Terms & conditions',
              subtitle: 'Usage and liability',
              onTap: () => _showSheet(
                context,
                title: 'Terms & conditions',
                body:
                    'By using this app you agree to the product terms, privacy practices, and acceptable use policy. '
                    'Replace this placeholder with your legal documents before production.',
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: AppRadius.card,
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.subtle,
              ),
              child: SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Dark mode'),
                subtitle: const Text('Reduce glare in low light'),
                value: mode == ThemeMode.dark,
                activeThumbColor: AppColors.primary,
                onChanged: (v) async {
                  HapticFeedback.selectionClick();
                  final next = v ? ThemeMode.dark : ThemeMode.light;
                  ref.read(themeModeProvider.notifier).state = next;
                  await persistThemeMode(next);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                borderRadius: AppRadius.card,
                color: AppColors.surface,
                border: Border.all(color: AppColors.border),
                boxShadow: AppShadows.subtle,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API base URL',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Example: http://10.0.2.2:8000 for Android emulator',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextField(
                    controller: _apiCtrl,
                    keyboardType: TextInputType.url,
                    decoration: const InputDecoration(
                      hintText: 'http://127.0.0.1:8000',
                      prefixIcon: Icon(Icons.link_rounded),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: _saveApiUrl,
                      child: const Text('Save URL'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            _LogoutButton(
              onPressed: () async {
                HapticFeedback.mediumImpact();
                await ref.read(authRepositoryProvider).logout();
                ref.read(authTokenProvider.notifier).state = null;
                if (context.mounted) context.go('/login');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSheet(BuildContext context, {required String title, required String body}) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.sheet),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
            bottom: AppSpacing.lg + MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.md),
              Text(body, style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(height: 1.5)),
            ],
          ),
        );
      },
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        gradient: LinearGradient(
          colors: [
            AppColors.sell.withValues(alpha: 0.95),
            AppColors.sell.withValues(alpha: 0.75),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.card,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.logout_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'Log out',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
