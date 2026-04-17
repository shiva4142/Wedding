import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

class GoldDivider extends StatelessWidget {
  const GoldDivider({super.key, this.symbol = '✦', this.width = 80});
  final String symbol;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: width,
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, AppPalette.gold, AppPalette.gold],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              symbol,
              style: const TextStyle(color: AppPalette.gold, fontSize: 18),
            ),
          ),
          Container(
            width: width,
            height: 1,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppPalette.gold, AppPalette.gold, Colors.transparent],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
