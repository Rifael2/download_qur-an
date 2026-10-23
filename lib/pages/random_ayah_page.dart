import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../models/ayah.dart';
import '../services/ayah_audio.dart';
import '../services/ayah_sources.dart';
import '../services/last_read_store.dart';
import '../services/quran_api_service.dart';
import '../widgets/state_views.dart';
import '../widgets/tafsir_sheet.dart';
import '../widgets/ui_helpers.dart';
import 'ayah_list_page.dart';

/// Menampilkan satu ayat acak dari `GET /v3/quran/random`.
class RandomAyahPage extends StatefulWidget {
  const RandomAyahPage({super.key});

  @override
  State<RandomAyahPage> createState() => _RandomAyahPageState();
}

class _RandomAyahPageState extends State<RandomAyahPage> {
  final QuranApiService _api = QuranApiService.instance;
  final LastReadStore _store = LastReadStore();

  late Future<Ayah> _future;
  late final AyahAudio _audio;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchRandomAyah();
    _audio = AyahAudio(
      onChanged: () {
        if (mounted) setState(() {});
      },
      onError: (message) {
        if (mounted) showMessage(context, message);
      },
    );
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void _reload() {
    _audio.stop();
    setState(() {
      _future = _api.fetchRandomAyah();
    });
  }

  Future<void> _copy(Ayah ayah) async {
    final text = '${ayah.arab}\n\n${ayah.translation}\n\n'
        '(QS ${ayah.surah.nameLatin}: ${ayah.ayahNumber})';
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showMessage(context, 'Ayat disalin ke papan klip');
  }

  Future<void> _bookmark(Ayah ayah) async {
    await _store.save(
      LastRead(
        surahName: ayah.surah.nameLatin,
        surahNumber: ayah.surahNumber,
        ayahNumber: ayah.ayahNumber,
        page: ayah.meta.page > 0 ? ayah.meta.page : 1,
      ),
    );
    if (mounted) showMessage(context, 'Ditandai sebagai terakhir dibaca');
  }

  void _openPage(Ayah ayah) {
    final page = ayah.meta.page > 0 ? ayah.meta.page : 1;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AyahListPage(source: MushafPageSource(page)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<Ayah>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView(message: 'Mengambil ayat acak…');
          }
          if (snapshot.hasError || snapshot.data == null) {
            return ErrorView(
              message: describeError(snapshot.error),
              onRetry: _reload,
            );
          }
          return _buildContent(snapshot.data!);
        },
      ),
    );
  }

  Widget _buildContent(Ayah ayah) {
    final playing = _audio.playingId == ayah.id;
    final meta = ayah.meta;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        Text(
          'Ayat Acak',
          style: appText(
            size: 22,
            weight: FontWeight.w600,
            color: AppColors.deepPurple,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Renungkan satu ayat hari ini.',
          style: appText(size: 13, color: AppColors.muted),
        ),
        const SizedBox(height: 18),
        Container(
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
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.lilac, AppColors.violet],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    ayah.surah.nameLatin,
                    textAlign: TextAlign.center,
                    style: appText(
                      size: 22,
                      weight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${ayah.surah.translation} • Ayat ${ayah.ayahNumber}'
                    '${ayah.surah.numberOfAyahs > 0 ? ' dari ${ayah.surah.numberOfAyahs}' : ''}',
                    textAlign: TextAlign.center,
                    style: appText(size: 12.5, color: Colors.white),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    ayah.arab,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: arabicText(size: 29, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          ayah.translation,
          style: appText(size: 14.5, height: 1.7),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (ayah.surah.revelation.isNotEmpty) _Chip(ayah.surah.revelation),
            if (meta.juz > 0) _Chip('Juz ${meta.juz}'),
            if (meta.page > 0) _Chip('Halaman ${meta.page}'),
            if (meta.hasSajda) _Chip('Ayat sajdah'),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: playing
                    ? Icons.stop_circle_outlined
                    : Icons.play_circle_outline_rounded,
                label: playing ? 'Hentikan' : 'Putar',
                onTap: () => _audio.toggle(ayah),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                icon: Icons.auto_stories_outlined,
                label: 'Tafsir',
                onTap: () => showTafsirSheet(context, ayah),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                icon: Icons.copy_rounded,
                label: 'Salin',
                onTap: () => _copy(ayah),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.bookmark_border_rounded,
                label: 'Tandai',
                onTap: () => _bookmark(ayah),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionButton(
                icon: Icons.menu_book_outlined,
                label: 'Baca halaman',
                onTap: () => _openPage(ayah),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _reload,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.peach,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          icon: const Icon(Icons.shuffle_rounded),
          label: Text(
            'Acak ayat lagi',
            style: appText(
              size: 15,
              weight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.lavender,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: appText(
          size: 11.5,
          weight: FontWeight.w500,
          color: AppColors.deepPurple,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.violet,
        side: const BorderSide(color: AppColors.lavender, width: 1.5),
        backgroundColor: AppColors.lavender.withAlpha(110),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: Icon(icon, size: 19),
      label: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          label,
          style: appText(
            size: 12.5,
            weight: FontWeight.w500,
            color: AppColors.violet,
          ),
        ),
      ),
    );
  }
}
