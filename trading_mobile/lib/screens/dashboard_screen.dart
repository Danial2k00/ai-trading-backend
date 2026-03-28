import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/network/api_exception.dart';
import '../providers/dashboard_providers.dart';
import '../theme/design_system.dart';
import '../widgets/chart_container.dart';
import '../widgets/market_selector.dart';
import '../widgets/signal_card.dart';

final _markets = [
  MarketOption(label: 'BTC/USDT', apiSymbol: 'BTCUSDT'),
  MarketOption(label: 'EUR/USD', apiSymbol: 'EURUSDT'),
  MarketOption(label: 'XAU/USD', apiSymbol: 'PAXGUSDT'),
];

final _timeframes = ['1m', '15m', '1h', '4h'];

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pair = ref.watch(selectedPairSymbolProvider);
    final tf = ref.watch(selectedTimeframeProvider);
    final signalAsync = ref.watch(dashboardSignalProvider);
    final displayLabel = _markets.firstWhere((m) => m.apiSymbol == pair, orElse: () => _markets.first).label;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? null : AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 6,
        onPressed: () {
          HapticFeedback.mediumImpact();
          context.push('/ai-chat');
        },
        icon: const Icon(Icons.chat_bubble_rounded),
        label: const Text('AI Chat'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            ref.invalidate(dashboardSignalProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Trading Dashboard',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.4,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Live overview · $displayLabel · $tf',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      IconButton.filledTonal(
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.surface,
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: AppColors.border),
                        ),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Filters — connect saved layouts in a future release')),
                          );
                        },
                        icon: const Icon(Icons.tune_rounded),
                        tooltip: 'Filters',
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(
                child: MarketSelector(
                  options: _markets,
                  selected: pair,
                  onSelected: (sym) {
                    ref.read(selectedPairSymbolProvider.notifier).state = sym;
                    ref.invalidate(dashboardSignalProvider);
                  },
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: _TimeframeBar(
                    values: _timeframes,
                    selected: tf,
                    onSelected: (v) => ref.read(selectedTimeframeProvider.notifier).state = v,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: ChartContainer(
                    title: 'Market overview',
                    subtitle: '$displayLabel · $tf · stylized preview',
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: signalAsync.when(
                    data: (s) => SignalCard.fromModel(
                      s,
                      onRefresh: () => ref.invalidate(dashboardSignalProvider),
                    ),
                    loading: () => _LoadingPanel(
                      title: 'Computing AI signal…',
                      subtitle: 'RSI · MACD · Moving averages',
                    ),
                    error: (e, _) => _ErrorPanel(
                      message: e is ApiException ? e.message : e.toString(),
                      onRetry: () => ref.invalidate(dashboardSignalProvider),
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: _AnalystCard(onTap: () => context.push('/ai-chat')),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeframeBar extends StatelessWidget {
  const _TimeframeBar({
    required this.values,
    required this.selected,
    required this.onSelected,
  });

  final List<String> values;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final v in values)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _TfButton(
                label: v,
                selected: selected == v,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelected(v);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _TfButton extends StatelessWidget {
  const _TfButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      child: Material(
        color: selected ? AppColors.primary : AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        elevation: selected ? 2 : 0,
        shadowColor: AppColors.primary.withValues(alpha: 0.25),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppColors.textPrimary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnalystCard extends StatelessWidget {
  const _AnalystCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            gradient: LinearGradient(
              colors: [
                AppColors.primary,
                AppColors.primary.withValues(alpha: 0.82),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: AppShadows.card,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ask AI Analyst',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explain setups, risk, and macro context — preview',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.92),
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white.withValues(alpha: 0.9)),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoadingPanel extends StatelessWidget {
  const _LoadingPanel({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: AppRadius.card,
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.subtle,
      ),
      child: Row(
        children: [
          const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.sm),
          FilledButton.tonal(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
