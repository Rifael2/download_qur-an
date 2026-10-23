import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Lencana bernomor berbentuk bintang segi delapan (dua persegi bertumpuk).
class NumberBadge extends StatelessWidget {
  const NumberBadge(this.number, {super.key, this.size = 42});

  final int number;
  final double size;

  @override
  Widget build(BuildContext context) {
    final edge = size * 0.66;
    final decoration = BoxDecoration(
      border: Border.all(color: AppColors.violet, width: 1.3),
      borderRadius: BorderRadius.circular(6),
    );
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(width: edge, height: edge, decoration: decoration),
          Transform.rotate(
            angle: 0.7853981634,
            child: Container(width: edge, height: edge, decoration: decoration),
          ),
          Text(
            '$number',
            style: appText(
              size: size * 0.29,
              weight: FontWeight.w600,
              color: AppColors.violet,
            ),
          ),
        ],
      ),
    );
  }
}
