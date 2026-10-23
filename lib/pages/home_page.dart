import 'package:flutter/material.dart';

import '../core/surah_pages.dart';
import '../core/theme.dart';
import '../models/surah.dart';
import '../services/ayah_sources.dart';
import '../services/last_read_store.dart';
import '../services/quran_api_service.dart';
import '../widgets/number_badge.dart';
import '../widgets/state_views.dart';
import 'ayah_list_page.dart';

/// Beranda: sapaan, kartu "terakhir dibaca", serta tab Surah / Juz / Halaman.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final QuranApiService _api = QuranApiService.instance;
  final LastReadStore _lastReadStore = LastReadStore();
  final TextEditingController _search = TextEditingController();
  late final TabController _tabs = TabController(length: 3, vsync: this);

  late Future<List<Surah>> _surahFuture;
  late Future<LastRead?> _lastReadFuture;

  bool _searching = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _surahFuture = _api.fetchSurahList();
    _lastReadFuture = _lastReadStore.load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _open(AyahSource source) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => AyahListPage(source: source)),
    );
    if (!mounted) return;
    setState(() {
      _lastReadFuture = _lastReadStore.load();
    });
  }

  void _toggleSearch() {
    setState(() {
      _searching = !_searching;
      if (_searching) {
        _tabs.animateTo(0);
      } else {
        _search.clear();
        _query = '';
      }
    });
  }

  List<Surah> _filter(List<Surah> all) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return all;
    return all.where((s) {
      return s.nameLatin.toLowerCase().contains(q) ||
          s.translation.toLowerCase().contains(q) ||
          s.number.toString() == q;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(child: _buildTop()),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabsDelegate(_tabs),
          ),
        ],
        body: TabBarView(
          controller: _tabs,
          children: [
            _buildSurahTab(),
            _buildJuzTab(),
            _buildPageTab(),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // Bagian atas: judul, sapaan, terakhir dibaca
  // --------------------------------------------------------------------------

  Widget _buildTop() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book_rounded, color: AppColors.violet),
              const SizedBox(width: 8),
              Text(
                'Quran App',
                style: appText(
                  size: 16,
                  weight: FontWeight.w600,
                  color: AppColors.deepPurple,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _toggleSearch,
                tooltip: _searching ? 'Tutup pencarian' : 'Cari surah',
                icon: Icon(
                  _searching ? Icons.close_rounded : Icons.search_rounded,
                  color: AppColors.deepPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_searching)
            TextField(
              controller: _search,
              autofocus: true,
              onChanged: (v) => setState(() => _query = v),
              style: appText(size: 14),
              decoration: InputDecoration(
                hintText: 'Cari nama, arti, atau nomor surah',
                hintStyle: appText(size: 13, color: AppColors.muted),
                prefixIcon:
                    const Icon(Icons.search_rounded, color: AppColors.muted),
                filled: true,
                fillColor: AppColors.lavender,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            )
          else ...[
            Text(
              'Assalamualaikum',
              style: appText(size: 13, color: AppColors.muted),
            ),
            Text(
              'Selamat membaca',
              style: appText(
                size: 22,
                weight: FontWeight.w600,
                color: AppColors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
            _buildLastReadCard(),
          ],
        ],
      ),
    );
  }

  Widget _buildLastReadCard() {
    return FutureBuilder<LastRead?>(
      future: _lastReadFuture,
      builder: (context, snapshot) {
        final last = snapshot.data;
        final title = last?.surahName ?? 'Al-Fatihah';
        final detail = last == null
            ? 'Belum ada penanda • mulai dari halaman 1'
            : 'Ayat ${last.ayahNumber} • Halaman ${last.page}';
        final page = last?.page ?? 1;

        return GestureDetector(
          onTap: () => _open(MushafPageSource(page)),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppColors.violet.withAlpha(70),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Container(
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
                      right: -8,
                      bottom: -14,
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 112,
                        color: Colors.white.withAlpha(46),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_stories_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Terakhir dibaca',
                                style: appText(
                                  size: 12,
                                  weight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            title,
                            style: appText(
                              size: 19,
                              weight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            detail,
                            style: appText(
                              size: 11.5,
                              color: Colors.white.withAlpha(230),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // Tab Surah (data dari GET /v3/quran, memakai FutureBuilder)
  // --------------------------------------------------------------------------

  Widget _buildSurahTab() {
    return FutureBuilder<List<Surah>>(
      future: _surahFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView(message: 'Memuat daftar surah…');
        }
        if (snapshot.hasError) {
          return ErrorView(
            message: describeError(snapshot.error),
            onRetry: () {
              setState(() {
                _surahFuture = _api.fetchSurahList();
              });
            },
          );
        }

        final shown = _filter(snapshot.data ?? const <Surah>[]);
        if (shown.isEmpty) {
          return const EmptyView(message: 'Surah tidak ditemukan.');
        }
        return ListView.separated(
          key: const PageStorageKey<String>('tab_surah'),
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: shown.length,
          separatorBuilder: (_, __) =>
              const Divider(height: 1, color: AppColors.lavender),
          itemBuilder: (context, i) => _SurahTile(
            surah: shown[i],
            onTap: () => _open(SurahSource(shown[i])),
          ),
        );
      },
    );
  }

  Widget _buildJuzTab() {
    return ListView.separated(
      key: const PageStorageKey<String>('tab_juz'),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: totalJuz,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: AppColors.lavender),
      itemBuilder: (context, i) {
        final juz = i + 1;
        return InkWell(
          onTap: () => _open(JuzSource(juz)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                NumberBadge(juz),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Juz $juz',
                    style: appText(size: 14.5, weight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageTab() {
    return GridView.builder(
      key: const PageStorageKey<String>('tab_page'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: totalMushafPages,
      itemBuilder: (context, i) {
        final page = i + 1;
        return InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _open(MushafPageSource(page)),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.lavender,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              '$page',
              style: appText(
                size: 13,
                weight: FontWeight.w600,
                color: AppColors.deepPurple,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile({required this.surah, required this.onTap});

  final Surah surah;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            NumberBadge(surah.number),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.nameLatin,
                    style: appText(size: 14.5, weight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.revelation} • ${surah.numberOfAyahs} ayat',
                    style: appText(size: 11.5, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                surah.translation,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: appText(
                  size: 12.5,
                  weight: FontWeight.w500,
                  color: AppColors.violet,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabsDelegate extends SliverPersistentHeaderDelegate {
  _TabsDelegate(this.controller);

  final TabController controller;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: controller,
        labelColor: AppColors.violet,
        unselectedLabelColor: AppColors.muted,
        indicatorColor: AppColors.violet,
        dividerColor: AppColors.lavender,
        labelStyle: appText(size: 14, weight: FontWeight.w600),
        unselectedLabelStyle: appText(size: 14),
        tabs: const [
          Tab(text: 'Surah'),
          Tab(text: 'Juz'),
          Tab(text: 'Halaman'),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsDelegate oldDelegate) =>
      oldDelegate.controller != controller;
}
