import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Kartu gradien ungu di bagian atas daftar ayat (mengikuti referensi desain).
class HeaderCard extends StatelessWidget {
  const HeaderCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.meta,
    this.showBasmalah = false,
  });

  final String title;
  final String subtitle;
  final String meta;
  final bool showBasmalah;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withAlpha(80),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.lilac, AppColors.violet],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -14,
                bottom: -18,
                child: Icon(
                  Icons.menu_book_rounded,
                  size: 130,
                  color: Colors.white.withAlpha(40),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
                child: Column(
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: appText(
                        size: 24,
                        weight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: appText(size: 13, color: Colors.white),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 1,
                      width: 150,
                      color: Colors.white.withAlpha(100),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      meta,
                      textAlign: TextAlign.center,
                      style: appText(
                        size: 12,
                        weight: FontWeight.w500,
                        color: Colors.white.withAlpha(230),
                      ),
                    ),
                    if (showBasmalah) ...[
                      const SizedBox(height: 4),
                      Text(
                        'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        style: arabicText(
                          size: 26,
                          color: Colors.white,
                          height: 1.9,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
