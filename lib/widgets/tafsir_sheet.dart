import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/ayah.dart';

/// Bottom sheet berisi tafsir Kemenag, Quraish Shihab, dan Jalalayn.
Future<void> showTafsirSheet(BuildContext context, Ayah ayah) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) => SizedBox(
      height: MediaQuery.of(sheetContext).size.height * 0.85,
      child: _TafsirSheet(ayah: ayah),
    ),
  );
}

class _TafsirSheet extends StatelessWidget {
  const _TafsirSheet({required this.ayah});
  final Ayah ayah;

  @override
  Widget build(BuildContext context) {
    final t = ayah.tafsir;
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tafsir ${ayah.surah.nameLatin} : ${ayah.ayahNumber}',
                style: appText(
                  size: 17,
                  weight: FontWeight.w600,
                  color: AppColors.deepPurple,
                ),
              ),
            ),
          ),
          TabBar(
            labelColor: AppColors.violet,
            unselectedLabelColor: AppColors.muted,
            indicatorColor: AppColors.violet,
            labelStyle: appText(size: 13, weight: FontWeight.w600),
            unselectedLabelStyle: appText(size: 13),
            tabs: const [
              Tab(text: 'Kemenag'),
              Tab(text: 'Quraish'),
              Tab(text: 'Jalalayn'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _TafsirText(blocks: {
                  'Ringkas': t.kemenagShort,
                  'Penjelasan lengkap': t.kemenagLong,
                }),
                _TafsirText(blocks: {'': t.quraish}),
                _TafsirText(blocks: {'': t.jalalayn}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TafsirText extends StatelessWidget {
  const _TafsirText({required this.blocks});
  final Map<String, String> blocks;

  @override
  Widget build(BuildContext context) {
    final filled = blocks.entries.where((e) => e.value.trim().isNotEmpty);
    if (filled.isEmpty) {
      return Center(
        child: Text(
          'Tafsir tidak tersedia untuk ayat ini.',
          style: appText(size: 13, color: AppColors.muted),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        for (final e in filled) ...[
          if (e.key.isNotEmpty) ...[
            Text(
              e.key,
              style: appText(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.violet,
              ),
            ),
            const SizedBox(height: 6),
          ],
          SelectableText(
            e.value,
            style: appText(size: 13.5, height: 1.7),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
