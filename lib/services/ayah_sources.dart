import '../core/surah_pages.dart';
import '../models/ayah_page.dart';
import '../models/surah.dart';
import 'quran_api_service.dart';

/// Abstraksi "dari mana ayat diambil" agar satu layar daftar ayat dapat
/// dipakai untuk surah, juz, maupun halaman.
///
/// [cursor] adalah penanda posisi pemuatan; artinya ditentukan tiap sumber.
abstract class AyahSource {
  const AyahSource();

  String get title;
  String get headerTitle;
  String get headerSubtitle;
  String get headerMeta;
  bool get showSurahLabel => true;
  bool get showBasmalah => false;
  int get firstCursor;

  Future<AyahBatch> load(int cursor, {bool isFirst = false});
}

class SurahSource extends AyahSource {
  SurahSource(this.surah);

  final Surah surah;
  final QuranApiService _api = QuranApiService.instance;

  @override
  String get title => surah.nameLatin;
  @override
  String get headerTitle => surah.nameLatin;
  @override
  String get headerSubtitle => surah.translation;
  @override
  String get headerMeta => '${surah.revelation} • ${surah.numberOfAyahs} ayat';
  @override
  bool get showSurahLabel => false;
  @override
  bool get showBasmalah => surah.number != 9;

  /// cursor = nomor halaman mushaf.
  @override
  int get firstCursor {
    final i = surah.number - 1;
    if (i < 0 || i >= surahStartPages.length) return 1;
    return surahStartPages[i];
  }

  @override
  Future<AyahBatch> load(int cursor, {bool isFirst = false}) =>
      _api.fetchSurahBatch(surah, cursor, isFirst: isFirst);
}

class JuzSource extends AyahSource {
  JuzSource(this.juz);

  final int juz;
  final QuranApiService _api = QuranApiService.instance;

  @override
  String get title => 'Juz $juz';
  @override
  String get headerTitle => 'Juz $juz';
  @override
  String get headerSubtitle => 'Ayat per juz';
  @override
  String get headerMeta => 'Juz $juz dari $totalJuz';

  /// cursor = nomor halaman paginasi API.
  @override
  int get firstCursor => 1;

  @override
  Future<AyahBatch> load(int cursor, {bool isFirst = false}) async {
    final res = await _api.fetchJuz(juz, page: cursor);
    return AyahBatch(
      items: res.items,
      nextCursor: res.hasMore ? cursor + 1 : null,
      total: res.total,
    );
  }
}

class MushafPageSource extends AyahSource {
  MushafPageSource(this.pageNumber);

  final int pageNumber;
  final QuranApiService _api = QuranApiService.instance;

  @override
  String get title => 'Halaman $pageNumber';
  @override
  String get headerTitle => 'Halaman $pageNumber';
  @override
  String get headerSubtitle => 'Ayat per halaman';
  @override
  String get headerMeta => 'Halaman $pageNumber dari $totalMushafPages';

  /// cursor = nomor halaman paginasi API.
  @override
  int get firstCursor => 1;

  @override
  Future<AyahBatch> load(int cursor, {bool isFirst = false}) async {
    final res = await _api.fetchPage(pageNumber, page: cursor);
    return AyahBatch(
      items: res.items,
      nextCursor: res.hasMore ? cursor + 1 : null,
      total: res.total,
    );
  }
}
