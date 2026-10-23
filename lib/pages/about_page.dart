import 'package:flutter/material.dart';

import '../core/theme.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Text(
            'Tentang aplikasi',
            style: appText(
              size: 22,
              weight: FontWeight.w600,
              color: AppColors.deepPurple,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              'Quran App membantu membaca Al-Qur\'an lewat daftar surah, juz, '
              'dan halaman, lengkap dengan terjemahan, tafsir, dan audio per '
              'ayat. Fitur ayat acak menampilkan satu ayat untuk direnungkan.',
              style: appText(size: 13.5, height: 1.65),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Sumber data',
            style: appText(size: 15, weight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const _Row(label: 'Daftar surah', value: 'GET /v3/quran'),
          const _Row(label: 'Ayat acak', value: 'GET /v3/quran/random'),
          const _Row(label: 'Ayat per juz', value: 'GET /v3/quran/juz/{n}'),
          const _Row(label: 'Ayat per halaman', value: 'GET /v3/quran/page/{n}'),
          const SizedBox(height: 6),
          Text(
            'Semua data berasal dari api.myquran.com.',
            style: appText(size: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 22),
          Text('Versi', style: appText(size: 15, weight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('1.0.0', style: appText(size: 13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Text(label, style: appText(size: 13, color: AppColors.muted)),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value,
              style: appText(
                size: 12.5,
                weight: FontWeight.w500,
                color: AppColors.deepPurple,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
