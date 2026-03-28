import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/api_exception.dart';
import '../models/signal_model.dart';
import '../providers/dashboard_providers.dart';
import '../theme/design_system.dart';
import '../widgets/signal_card.dart';

final _filterProvider = StateProvider<String>((ref) => 'ALL');

class SignalsScreen extends ConsumerWidget {
  const SignalsScreen({super.key});

  List<SignalHistoryItem> _applyFilter(List<SignalHistoryItem> items, String f) {
    if (f == 'ALL') return items;
    return items.where((e) => e.signal == f).toList();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(_filterProvider);
    final async = ref.watch(signalsHistoryProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? null : AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            ref.invalidate(signalsHistoryProvider);
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Signals History',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Filtered AI outputs with confidence and indicator context.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: _FilterTabs(
                    selected: filter,
                    onChanged: (v) => ref.read(_filterProvider.notifier).state = v,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
              async.when(
                data: (items) {
                  final list = _applyFilter(items, filter);
                  if (list.isEmpty) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            'No signals match this filter yet.\nPull to refresh or generate signals from Dashboard.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList.separated(
                    itemCount: list.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: SignalCard.fromHistory(list[index]),
                      );
                    },
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ),
                error: (e, _) => SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            e is ApiException ? e.message : e.toString(),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          FilledButton(
                            onPressed: () => ref.invalidate(signalsHistoryProvider),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
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

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  static const _tabs = ['ALL', 'BUY', 'SELL', 'HOLD'];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _tabs.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == _tabs.length - 1 ? 0 : 8),
              child: _FilterChip(
                label: _tabs[i] == 'ALL' ? 'All' : _tabs[i],
                selected: selected == _tabs[i],
                onTap: () {
                  HapticFeedback.selectionClick();
                  onChanged(_tabs[i]);
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
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
      child: Material(
        color: selected ? AppColors.primarySoft : AppColors.surface,
        borderRadius: AppRadius.pill,
        child: InkWell(
          borderRadius: AppRadius.pill,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: AppRadius.pill,
              border: Border.all(color: selected ? AppColors.primary : AppColors.border),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: selected ? AppColors.primary : AppColors.textSecondary,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
