import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Pembaca ayat dengan infinite scroll (dipakai untuk surah, juz, dan halaman).
class ReaderScreen extends StatefulWidget {
  const ReaderScreen({
    super.key,
    required this.title,
    required this.fetch,
    this.surah,
    this.expected,
    this.showSurah = false,
  });

  final String title;
  final ChunkFetcher fetch;
  final Surah? surah;
  final int? expected;
  final bool showSurah;

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final _ctrl = ScrollController();
  final _items = <Ayah>[];
  int _step = 0;
  bool _loading = false, _hasMore = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(() {
      if (_ctrl.position.pixels > _ctrl.position.maxScrollExtent - 400) _loadMore();
    });
    _loadMore();
  }

  @override
  void dispose() {
    AudioService.stop();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadMore() async {
    if (_loading || !_hasMore) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final c = await widget.fetch(_step);
      if (!mounted) return;
      setState(() {
        _items.addAll(c.items);
        _step++;
        _hasMore = c.hasMore && (widget.expected == null || _items.length < widget.expected!);
        _loading = false;
      });
      final s = widget.surah;
      if (s != null && _items.isNotEmpty && Store.lastRead.value?.surahNumber != s.number) {
        Store.setLastRead(_items.first);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _hasMore && _ctrl.hasClients && _ctrl.position.maxScrollExtent < 400) _loadMore();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasHeader = widget.surah != null;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.dark,
        title: Text(widget.title,
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.dark)),
      ),
      body: ListView.builder(
        controller: _ctrl,
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: (hasHeader ? 1 : 0) + _items.length + 1,
        itemBuilder: (_, i) {
          if (hasHeader && i == 0) return _SurahHeader(widget.surah!);
          final idx = i - (hasHeader ? 1 : 0);
          if (idx < _items.length) {
            return AyahTile(key: ValueKey(_items[idx].key), ayah: _items[idx], showSurah: widget.showSurah);
          }
          if (_loading) {
            return const Padding(padding: EdgeInsets.all(24), child: Center(child: CircularProgressIndicator()));
          }
          if (_error != null) {
            return Column(children: [
              Text(_error!, textAlign: TextAlign.center),
              TextButton(onPressed: _loadMore, child: const Text('Coba lagi')),
            ]);
          }
          return const SizedBox(height: 24);
        },
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  const _SurahHeader(this.s);
  final Surah s;

  @override
  Widget build(BuildContext context) {
    final key = 'surah:${s.number}';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFD6A9F7), Color(0xFF9B6BDB)]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.3), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(children: [
        Text(s.arabic, style: GoogleFonts.amiri(fontSize: 34, color: Colors.white)),
        Text(s.latin, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        Text(s.translation, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 8),
        Text('${s.revelation.toUpperCase()} • ${s.ayahs} AYAT',
            style: const TextStyle(fontSize: 10.5, letterSpacing: 1, color: Colors.white70)),
        if (s.number != 1 && s.number != 9) ...[
          const SizedBox(height: 10),
          Text('بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ', style: GoogleFonts.amiri(fontSize: 24, color: Colors.white)),
        ],
        if (s.audioUrl.isNotEmpty)
          ValueListenableBuilder<String?>(
            valueListenable: AudioService.playingKey,
            builder: (_, k, __) => TextButton.icon(
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () => AudioService.toggle(key, s.audioUrl),
              icon: Icon(k == key ? Icons.stop_circle_rounded : Icons.play_circle_rounded),
              label: Text(k == key ? 'Hentikan audio' : 'Putar surah', style: const TextStyle(fontSize: 12)),
            ),
          ),
      ]),
    );
  }
}
