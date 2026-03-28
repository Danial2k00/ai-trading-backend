import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/design_system.dart';

/// Horizontal scrollable market pills (display label → API symbol).
class MarketOption {
  const MarketOption({required this.label, required this.apiSymbol});

  final String label;
  final String apiSymbol;
}

class MarketSelector extends StatelessWidget {
  const MarketSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<MarketOption> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final o = options[index];
          final isOn = selected == o.apiSymbol;
          return _Pill(
            label: o.label,
            selected: isOn,
            onTap: () {
              HapticFeedback.selectionClick();
              onSelected(o.apiSymbol);
            },
          );
        },
      ),
    );
  }
}

class _Pill extends StatefulWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_Pill> createState() => _PillState();
}

class _PillState extends State<_Pill> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.97 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: AppRadius.pill,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadius.pill,
              color: widget.selected ? AppColors.primary : AppColors.surface,
              border: Border.all(
                color: widget.selected ? AppColors.primary : AppColors.border,
                width: widget.selected ? 1.5 : 1,
              ),
              boxShadow: widget.selected ? AppShadows.subtle : null,
            ),
            child: Center(
              child: Text(
                widget.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.selected ? Colors.white : AppColors.textPrimary,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
