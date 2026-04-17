import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expanded = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon == null
          ? const SizedBox.shrink()
          : Icon(icon, size: 18, color: Colors.white),
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppPalette.roseDeep,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: AppPalette.rose.withOpacity(.4),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class GhostButton extends StatelessWidget {
  const GhostButton({super.key, required this.label, this.onPressed, this.icon});
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).textTheme.bodyMedium?.color;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 18, color: color),
      label: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        child: Text(label,
            style: TextStyle(
              fontSize: 14,
              color: color,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            )),
      ),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppPalette.gold),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
      ),
    );
  }
}

class Chip extends StatelessWidget {
  const Chip({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppPalette.gold.withOpacity(.15),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppPalette.gold.withOpacity(.4)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppPalette.gold,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: .5,
        ),
      ),
    );
  }
}
