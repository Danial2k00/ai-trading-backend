import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/signal_model.dart';
import '../theme/design_system.dart';
import '../utils/indicator_parser.dart';

/// Premium AI signal card — dashboard (expanded) or history (compact).
class SignalCard extends StatelessWidget {
  const SignalCard({
    super.key,
    required this.pair,
    required this.signal,
    required this.confidence,
    required this.timeframe,
    required this.reason,
    this.timestamp,
    this.onRefresh,
    this.compact = false,
  });

  factory SignalCard.fromModel(
    SignalModel m, {
    Key? key,
    VoidCallback? onRefresh,
    bool compact = false,
  }) {
    return SignalCard(
      key: key,
      pair: m.pair,
      signal: m.signal,
      confidence: m.confidence,
      timeframe: m.timeframe,
      reason: m.reason,
      onRefresh: onRefresh,
      compact: compact,
    );
  }

  factory SignalCard.fromHistory(
    SignalHistoryItem h, {
    Key? key,
    bool compact = true,
  }) {
    return SignalCard(
      key: key,
      pair: h.pair,
      signal: h.signal,
      confidence: h.confidence,
      timeframe: h.timeframe,
      reason: h.reason,
      timestamp: h.createdAt,
      compact: compact,
    );
  }

  final String pair;
  final String signal;
  final double confidence;
  final String timeframe;
  final String reason;
  final String? timestamp;
  final VoidCallback? onRefresh;
  final bool compact;

  Color _signalColor() {
    switch (signal) {
      case 'BUY':
        return AppColors.buy;
      case 'SELL':
        return AppColors.sell;
      default:
        return AppColors.hold;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = _signalColor();
    final parsed = ParsedIndicators.fromReason(reason);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.97, end: 1),
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: AppRadius.card,
          color: AppColors.surface,
          border: Border.all(color: AppColors.border),
          boxShadow: AppShadows.card,
        ),
        child: Padding(
          padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pair,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$timeframe · AI composite',
                          style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  _SignalBadge(label: signal, color: accent),
                  if (onRefresh != null) ...[
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.primarySoft,
                        foregroundColor: AppColors.primary,
                      ),
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        onRefresh!();
                      },
                      icon: const Icon(Icons.refresh_rounded),
                      tooltip: 'Refresh',
                    ),
                  ],
                ],
              ),
              if (!compact) ...[
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Text(
                      'Confidence',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${confidence.toStringAsFixed(1)}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: AppRadius.pill,
                  child: LinearProgressIndicator(
                    value: (confidence / 100).clamp(0, 1),
                    minHeight: 8,
                    backgroundColor: AppColors.surfaceMuted,
                    valueColor: AlwaysStoppedAnimation<Color>(accent),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                _IndicatorRow(parsed: parsed),
                const SizedBox(height: AppSpacing.md),
              ] else ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: AppRadius.pill,
                        child: LinearProgressIndicator(
                          value: (confidence / 100).clamp(0, 1),
                          minHeight: 6,
                          backgroundColor: AppColors.surfaceMuted,
                          valueColor: AlwaysStoppedAnimation<Color>(accent),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${confidence.toStringAsFixed(0)}%',
                      style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                _IndicatorRow(parsed: parsed, dense: true),
              ],
              const SizedBox(height: AppSpacing.sm),
              Text(
                reason,
                maxLines: compact ? 3 : 6,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: AppColors.textPrimary,
                ),
              ),
              if (timestamp != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  _formatTs(timestamp!),
                  style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textMuted),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTs(String iso) {
    final dt = DateTime.tryParse(iso);
    if (dt == null) return iso;
    final local = dt.toLocal();
    return '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}

class _SignalBadge extends StatelessWidget {
  const _SignalBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: AppRadius.pill,
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
      ),
    );
  }
}

class _IndicatorRow extends StatelessWidget {
  const _IndicatorRow({required this.parsed, this.dense = false});

  final ParsedIndicators parsed;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final items = [
      _IndChip(title: 'RSI', value: parsed.rsi ?? '—'),
      _IndChip(title: 'MACD', value: parsed.macd ?? '—'),
      _IndChip(title: 'MA', value: parsed.movingAverages ?? '—'),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: dense ? 8 : 12),
          Expanded(child: items[i]),
        ],
      ],
    );
  }
}

class _IndChip extends StatelessWidget {
  const _IndChip({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}
