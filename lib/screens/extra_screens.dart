import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

TextStyle _title() => GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark);

/// Ayat acak dari GET /v3/quran/random
class RandomAyahScreen extends StatefulWidget {
  const RandomAyahScreen({super.key});

  @override
  State<RandomAyahScreen> createState() => _RandomAyahScreenState();
}

class _RandomAyahScreenState extends State<RandomAyahScreen> {
  Ayah? _ayah;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    AudioService.stop();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    AudioService.stop();
    try {
      final a = await QuranApi.randomAyah();
      if (mounted) setState(() => _ayah = a);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    if (mounted) setState(() => _loading = false);
  }

  Widget _chip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
        child: Text(t, style: const TextStyle(fontSize: 10.5, color: Colors.white)),
      );

  @override
  Widget build(BuildContext context) {
    final a = _ayah;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.dark,
        title: Text('Ayat Acak', style: _title()),
      ),
      body: a == null
          ? Center(
              child: _loading
                  ? const CircularProgressIndicator()
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(_error ?? 'Gagal memuat', textAlign: TextAlign.center),
                      TextButton(onPressed: _fetch, child: const Text('Coba lagi')),
                    ]),
            )
          : ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 24), children: [
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD6A9F7), Color(0xFF9B6BDB)]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(children: [
                  Text(a.surahName,
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(a.surahTranslation, style: const TextStyle(fontSize: 12, color: Colors.white70)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, children: [
                    _chip('QS ${a.surahNumber}:${a.ayahNumber}'),
                    _chip('Juz ${a.juz}'),
                    _chip('Hal. ${a.page}'),
                    _chip(a.revelation),
                  ]),
                ]),
              ),
              AyahTile(key: ValueKey(a.key), ayah: a, showSurah: true),
              const SizedBox(height: 8),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.dark,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _loading ? null : _fetch,
                icon: _loading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh_rounded),
                label: const Text('Ayat Acak Lainnya'),
              ),
            ]),
    );
  }
}

/// Daftar ayat yang di-bookmark (disimpan lokal).
class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.dark,
        title: Text('Bookmark', style: _title()),
      ),
      body: ValueListenableBuilder<List<Ayah>>(
        valueListenable: Store.bookmarks,
        builder: (_, list, __) {
          if (list.isEmpty) {
            return const Center(
              child: Text('Belum ada bookmark.\nTekan ikon bookmark pada sebuah ayat.',
                  textAlign: TextAlign.center, style: TextStyle(color: AppColors.grey)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            itemCount: list.length,
            itemBuilder: (_, i) => AyahTile(key: ValueKey(list[i].key), ayah: list[i], showSurah: true),
          );
        },
      ),
    );
  }
}
