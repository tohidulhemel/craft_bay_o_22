import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    super.key,
    required this.value,
    required this.onIncrement,
    required this.onDecrement,
    this.minValue = 1,
    this.maxValue = 99,
  });

  final int value;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;
  final int minValue;
  final int maxValue;

  @override
  Widget build(BuildContext context) {
    final canDecrement = value > minValue;
    final canIncrement = value < maxValue;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: Icons.remove,
          enabled: canDecrement,
          onTap: onDecrement,
        ),
        SizedBox(
          width: 28,
          child: Text(
            value.toString().padLeft(2, '0'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ),
        _StepperButton(
          icon: Icons.add,
          enabled: canIncrement,
          onTap: onIncrement,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Icon(icon, size: 14, color: Colors.white),
      ),
    );
  }
}
