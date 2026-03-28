import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/design_system.dart';
import '../widgets/alert_tile.dart';

final _pairBtcProvider = StateProvider<bool>((ref) => true);
final _pairEurProvider = StateProvider<bool>((ref) => true);
final _pairXauProvider = StateProvider<bool>((ref) => false);

final _priceAlertsProvider = StateProvider<bool>((ref) => true);
final _signalAlertsProvider = StateProvider<bool>((ref) => true);
final _volAlertsProvider = StateProvider<bool>((ref) => false);

final _telegramProvider = StateProvider<bool>((ref) => false);
final _whatsappProvider = StateProvider<bool>((ref) => false);
final _pushProvider = StateProvider<bool>((ref) => true);

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final btc = ref.watch(_pairBtcProvider);
    final eur = ref.watch(_pairEurProvider);
    final xau = ref.watch(_pairXauProvider);
    final price = ref.watch(_priceAlertsProvider);
    final signal = ref.watch(_signalAlertsProvider);
    final vol = ref.watch(_volAlertsProvider);
    final tg = ref.watch(_telegramProvider);
    final wa = ref.watch(_whatsappProvider);
    final push = ref.watch(_pushProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? null : AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 96),
          children: [
            Text(
              'Alerts',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pair coverage, alert types, and delivery channels.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionTitle(title: 'Pair alerts'),
            const SizedBox(height: AppSpacing.sm),
            AlertTile(
              title: 'BTC / USDT',
              subtitle: 'Volatility & signal thresholds',
              value: btc,
              leading: _PairAvatar(label: '₿', color: AppColors.primary),
              onChanged: (v) => ref.read(_pairBtcProvider.notifier).state = v,
            ),
            const SizedBox(height: AppSpacing.sm),
            AlertTile(
              title: 'EUR / USD',
              subtitle: 'Macro session windows',
              value: eur,
              leading: _PairAvatar(label: '€', color: AppColors.hold),
              onChanged: (v) => ref.read(_pairEurProvider.notifier).state = v,
            ),
            const SizedBox(height: AppSpacing.sm),
            AlertTile(
              title: 'XAU / USD',
              subtitle: 'Safe-haven moves',
              value: xau,
              leading: _PairAvatar(label: 'Au', color: AppColors.buy),
              onChanged: (v) => ref.read(_pairXauProvider.notifier).state = v,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionTitle(title: 'Alert types'),
            const SizedBox(height: AppSpacing.sm),
            AlertTile(
              title: 'Price alerts',
              subtitle: 'Breakouts, retests, liquidity sweeps',
              value: price,
              leading: const Icon(Icons.show_chart_rounded, color: AppColors.primary),
              onChanged: (v) => ref.read(_priceAlertsProvider.notifier).state = v,
            ),
            const SizedBox(height: AppSpacing.sm),
            AlertTile(
              title: 'Signal alerts',
              subtitle: 'BUY / SELL / HOLD from AI stack',
              value: signal,
              leading: const Icon(Icons.bolt_rounded, color: AppColors.hold),
              onChanged: (v) => ref.read(_signalAlertsProvider.notifier).state = v,
            ),
            const SizedBox(height: AppSpacing.sm),
            AlertTile(
              title: 'Volatility alerts',
              subtitle: 'ATR spikes & regime shifts',
              value: vol,
              leading: const Icon(Icons.waves_rounded, color: AppColors.sell),
              onChanged: (v) => ref.read(_volAlertsProvider.notifier).state = v,
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionTitle(title: 'Delivery channels'),
            const SizedBox(height: AppSpacing.sm),
            AlertTile(
              title: 'Telegram',
              subtitle: 'Bot token required in backend',
              value: tg,
              leading: const Icon(Icons.send_rounded, color: Color(0xFF229ED9)),
              onChanged: (v) => ref.read(_telegramProvider.notifier).state = v,
            ),
            const SizedBox(height: AppSpacing.sm),
            AlertTile(
              title: 'WhatsApp',
              subtitle: 'Business API integration',
              value: wa,
              leading: const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
              onChanged: (v) => ref.read(_whatsappProvider.notifier).state = v,
            ),
            const SizedBox(height: AppSpacing.sm),
            AlertTile(
              title: 'Push notifications',
              subtitle: 'Firebase / APNs — see stub in services',
              value: push,
              leading: const Icon(Icons.notifications_active_rounded, color: AppColors.primary),
              onChanged: (v) => ref.read(_pushProvider.notifier).state = v,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
    );
  }
}

class _PairAvatar extends StatelessWidget {
  const _PairAvatar({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: color,
            ),
      ),
    );
  }
}
