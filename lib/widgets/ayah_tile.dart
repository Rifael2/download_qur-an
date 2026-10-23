import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../models/ayah.dart';

/// Satu ayat: nomor + aksi (salin, putar, tandai), teks Arab, terjemahan.
class AyahTile extends StatelessWidget {
  const AyahTile({
    super.key,
    required this.ayah,
    required this.isPlaying,
    required this.showSurahLabel,
    required this.onPlay,
    required this.onCopy,
    required this.onBookmark,
    required this.onTafsir,
  });

  final Ayah ayah;
  final bool isPlaying;
  final bool showSurahLabel;
  final VoidCallback onPlay;
  final VoidCallback onCopy;
  final VoidCallback onBookmark;
  final VoidCallback onTafsir;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 13,
                  backgroundColor: AppColors.violet,
                  child: Text(
                    '${ayah.ayahNumber}',
                    style: appText(
                      size: 11,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                if (showSurahLabel)
                  Expanded(
                    child: Text(
                      ayah.surah.nameLatin,
                      overflow: TextOverflow.ellipsis,
                      style: appText(
                        size: 12.5,
                        weight: FontWeight.w500,
                        color: AppColors.deepPurple,
                      ),
                    ),
                  )
                else
                  const Spacer(),
                _ActionIcon(
                  icon: Icons.copy_rounded,
                  tooltip: 'Salin ayat',
                  onTap: onCopy,
                ),
                _ActionIcon(
                  icon: isPlaying
                      ? Icons.stop_circle_outlined
                      : Icons.play_circle_outline_rounded,
                  tooltip: isPlaying ? 'Hentikan audio' : 'Putar audio',
                  onTap: onPlay,
                ),
                _ActionIcon(
                  icon: Icons.bookmark_border_rounded,
                  tooltip: 'Tandai terakhir dibaca',
                  onTap: onBookmark,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            ayah.arab,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: arabicText(size: 28),
          ),
          const SizedBox(height: 6),
          Text(
            ayah.translation,
            style: appText(
              size: 13.5,
              height: 1.6,
              color: AppColors.ink.withAlpha(215),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              TextButton.icon(
                onPressed: onTafsir,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.violet,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(Icons.auto_stories_outlined, size: 18),
                label: Text(
                  'Tafsir',
                  style: appText(size: 12.5, weight: FontWeight.w500,
                      color: AppColors.violet),
                ),
              ),
              if (ayah.meta.hasSajda) ...[
                const SizedBox(width: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.peach.withAlpha(60),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    ayah.meta.sajdaObligatory ? 'Sajdah wajib' : 'Ayat sajdah',
                    style: appText(
                      size: 11,
                      weight: FontWeight.w500,
                      color: const Color(0xFFB4592A),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const Divider(height: 1, color: AppColors.lavender),
        ],
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      icon: Icon(icon, size: 22, color: AppColors.violet),
    );
  }
}
