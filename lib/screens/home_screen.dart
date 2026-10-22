import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../api.dart';
import '../models.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'extra_screens.dart';
import 'reader_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Surah>? _surahs;
  String? _error;
  bool _searching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final s = await QuranApi.surahs();
      if (mounted) setState(() => _surahs = s);
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _push(Widget page) => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

  void _openSurah(Surah s) => _push(ReaderScreen(
        title: s.latin,
        surah: s,
        expected: s.ayahs,
        fetch: (step) => QuranApi.surahChunk(s.number, step),
      ));

  void _openJuz(int n) => _push(ReaderScreen(
        title: 'Juz $n',
        showSurah: true,
        fetch: (step) => QuranApi.juz(n, step),
      ));

  void _openPage(int n) => _push(ReaderScreen(
        title: 'Halaman $n',
        showSurah: true,
        fetch: (_) async => AyahChunk(await QuranApi.pageAll(n), false),
      ));

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: SafeArea(
          child: Column(children: [
            _header(),
            Expanded(
              child: _error != null
                  ? Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(_error!, textAlign: TextAlign.center),
                        TextButton(onPressed: _load, child: const Text('Coba lagi')),
                      ]),
                    )
                  : _surahs == null
                      ? const Center(child: CircularProgressIndicator())
                      : _content(),
            ),
          ]),
        ),
        bottomNavigationBar: _bottomBar(),
      ),
    );
  }

  Widget _header() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
        child: Row(children: [
          Expanded(
            child: _searching
                ? TextField(
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'Cari surah…', border: InputBorder.none),
                    onChanged: (v) => setState(() => _query = v),
                  )
                : Text('Quran App',
                    style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark)),
          ),
          IconButton(
            icon: Icon(_searching ? Icons.close_rounded : Icons.search_rounded, color: AppColors.dark),
            onPressed: () => setState(() {
              _searching = !_searching;
              _query = '';
            }),
          ),
        ]),
      );

  Widget _content() {
    final q = _query.trim().toLowerCase();
    final list = q.isEmpty
        ? _surahs!
        : _surahs!
            .where((s) => s.latin.toLowerCase().contains(q) || s.translation.toLowerCase().contains(q))
            .toList();
    return Column(children: [
      Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Assalamualaikum', style: TextStyle(fontSize: 12, color: AppColors.grey)),
            Text('Sahabat Quran',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark)),
          ]),
        ),
      ),
      _lastRead(),
      const TabBar(
        labelColor: AppColors.dark,
        unselectedLabelColor: AppColors.grey,
        indicatorColor: AppColors.dark,
        labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        tabs: [Tab(text: 'Surah'), Tab(text: 'Juz'), Tab(text: 'Halaman')],
      ),
      Expanded(
        child: TabBarView(children: [
          list.isEmpty
              ? const Center(child: Text('Surah tidak ditemukan'))
              : ListView.builder(
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final s = list[i];
                    return ListTile(
                      onTap: () => _openSurah(s),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                      leading: NumberBadge(s.number),
                      title: Text(s.latin, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      subtitle: Text('${s.revelation.toUpperCase()} • ${s.ayahs} AYAT',
                          style: const TextStyle(fontSize: 9.5, color: AppColors.grey, letterSpacing: .4)),
                      trailing: Text(s.arabic, style: GoogleFonts.amiri(fontSize: 22, color: AppColors.primary)),
                    );
                  },
                ),
          ListView.builder(
            itemCount: 30,
            itemBuilder: (_, i) => ListTile(
              onTap: () => _openJuz(i + 1),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              leading: NumberBadge(i + 1),
              title: Text('Juz ${i + 1}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.grey),
            ),
          ),
          GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, mainAxisSpacing: 10, crossAxisSpacing: 10),
            itemCount: 604,
            itemBuilder: (_, i) => InkWell(
              onTap: () => _openPage(i + 1),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(12)),
                child: Text('${i + 1}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.dark)),
              ),
            ),
          ),
        ]),
      ),
    ]);
  }

  Widget _lastRead() => ValueListenableBuilder<Ayah?>(
        valueListenable: Store.lastRead,
        builder: (_, a, __) {
          final s = _surahs!.firstWhere((s) => s.number == (a?.surahNumber ?? 1), orElse: () => _surahs!.first);
          return GestureDetector(
            onTap: () => _openSurah(s),
            child: Container(
              height: 112,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              padding: const EdgeInsets.fromLTRB(16, 12, 4, 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFC49BF2), Color(0xFF8B5CC9)]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Row(children: const [
                      Icon(Icons.menu_book_rounded, size: 13, color: Colors.white70),
                      SizedBox(width: 6),
                      Text('Terakhir dibaca', style: TextStyle(fontSize: 10, color: Colors.white70)),
                    ]),
                    const SizedBox(height: 8),
                    Text(s.latin,
                        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                    Text('Ayat No ${a?.ayahNumber ?? 1}',
                        style: const TextStyle(fontSize: 10, color: Colors.white70)),
                  ]),
                ),
                const BookIllustration(width: 130),
              ]),
            ),
          );
        },
      );

  Widget _bottomBar() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(.14), blurRadius: 16, offset: const Offset(0, -4))],
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              const Icon(Icons.menu_book_rounded, color: AppColors.primary),
              Tooltip(
                message: 'Ayat acak',
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _push(const RandomAyahScreen()),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(color: AppColors.dark, shape: BoxShape.circle),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Bookmark',
                onPressed: () => _push(const BookmarksScreen()),
                icon: const Icon(Icons.bookmark_rounded, color: AppColors.grey),
              ),
            ]),
          ),
        ),
      );
}
