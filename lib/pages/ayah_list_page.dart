import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../models/ayah.dart';
import '../services/ayah_audio.dart';
import '../services/ayah_sources.dart';
import '../services/last_read_store.dart';
import '../services/quran_api_service.dart';
import '../widgets/ayah_tile.dart';
import '../widgets/header_card.dart';
import '../widgets/state_views.dart';
import '../widgets/tafsir_sheet.dart';
import '../widgets/ui_helpers.dart';

/// Layar daftar ayat yang dipakai untuk surah, juz, dan halaman.
///
/// Pemuatan pertama memakai [FutureBuilder] (loading / error / success).
/// Sisa ayat dimuat bertahap saat pengguna menggulir ke bawah.
class AyahListPage extends StatefulWidget {
  const AyahListPage({super.key, required this.source});

  final AyahSource source;

  @override
  State<AyahListPage> createState() => _AyahListPageState();
}

class _AyahListPageState extends State<AyahListPage> {
  final LastReadStore _store = LastReadStore();
  final List<Ayah> _items = <Ayah>[];

  late Future<void> _initial;
  late final AyahAudio _audio;

  int? _nextCursor;
  int? _total;
  bool _loadingMore = false;
  String? _moreError;

  @override
  void initState() {
    super.initState();
    _audio = AyahAudio(
      onChanged: () {
        if (mounted) setState(() {});
      },
      onError: (message) {
        if (mounted) showMessage(context, message);
      },
    );
    _initial = _loadFirst();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  Future<void> _loadFirst() async {
    final batch = await widget.source.load(
      widget.source.firstCursor,
      isFirst: true,
    );
    _items
      ..clear()
      ..addAll(batch.items);
    _nextCursor = batch.nextCursor;
    _total = batch.total;
    _moreError = null;
    _loadingMore = false;
  }

  Future<void> _loadMore() async {
    final cursor = _nextCursor;
    if (cursor == null || _loadingMore || !mounted) return;

    setState(() {
      _loadingMore = true;
      _moreError = null;
    });

    try {
      final batch = await widget.source.load(cursor);
      if (!mounted) return;
      setState(() {
        final known = _items.map((a) => a.id).toSet();
        final fresh = batch.items.where((a) => !known.contains(a.id)).toList();
        _items.addAll(fresh);
        _nextCursor = fresh.isEmpty ? null : batch.nextCursor;
        _total = batch.total ?? _total;
        _loadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _moreError = describeError(e);
        _loadingMore = false;
      });
    }
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
    if (mounted) {
      showMessage(
        context,
        '${ayah.surah.nameLatin} ayat ${ayah.ayahNumber} ditandai terakhir dibaca',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.source.title)),
      body: FutureBuilder<void>(
        future: _initial,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView(message: 'Memuat ayat…');
          }
          if (snapshot.hasError) {
            return ErrorView(
              message: describeError(snapshot.error),
              onRetry: () {
                setState(() {
                  _initial = _loadFirst();
                });
              },
            );
          }
          if (_items.isEmpty) {
            return const EmptyView(message: 'Tidak ada ayat yang ditemukan.');
          }
          return _buildList();
        },
      ),
    );
  }

  Widget _buildList() {
    final source = widget.source;
    final count = _items.length;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: count + 2, // header + ayat + footer
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: HeaderCard(
              title: source.headerTitle,
              subtitle: source.headerSubtitle,
              meta: source.headerMeta,
              showBasmalah: source.showBasmalah,
            ),
          );
        }
        if (index <= count) {
          final ayah = _items[index - 1];
          return AyahTile(
            ayah: ayah,
            isPlaying: _audio.playingId == ayah.id,
            showSurahLabel: source.showSurahLabel,
            onPlay: () => _audio.toggle(ayah),
            onCopy: () => _copy(ayah),
            onBookmark: () => _bookmark(ayah),
            onTafsir: () => showTafsirSheet(context, ayah),
          );
        }
        return _buildFooter(count);
      },
    );
  }

  Widget _buildFooter(int count) {
    if (_moreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Text(
              _moreError!,
              textAlign: TextAlign.center,
              style: appText(size: 12.5, color: AppColors.muted),
            ),
            TextButton(
              onPressed: _loadMore,
              child: Text(
                'Coba lagi',
                style: appText(
                  size: 13,
                  weight: FontWeight.w500,
                  color: AppColors.violet,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_nextCursor != null) {
      // Pemuatan otomatis ketika footer terlihat (akhir daftar tercapai).
      if (!_loadingMore) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _loadMore());
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: AppColors.violet,
            ),
          ),
        ),
      );
    }

    final total = _total;
    final label = (total != null && total > 0 && total != count)
        ? '$count ayat ditampilkan'
        : '$count ayat • selesai';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(label, style: appText(size: 12, color: AppColors.muted)),
      ),
    );
  }
}
