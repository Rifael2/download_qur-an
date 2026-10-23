import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/surah_pages.dart';
import '../models/ayah.dart';
import '../models/ayah_page.dart';
import '../models/json_helpers.dart';
import '../models/surah.dart';

/// Kesalahan yang sudah diterjemahkan ke pesan yang ramah pengguna.
class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

String describeError(Object? error) {
  if (error is ApiException) return error.message;
  return 'Terjadi kesalahan yang tidak terduga. Silakan coba lagi.';
}

/// Satu-satunya pintu akses ke MyQuran API v3.
///
/// Endpoint yang dipakai:
///  - GET /v3/quran              -> daftar surah
///  - GET /v3/quran/random       -> ayat acak
///  - GET /v3/quran/juz/{n}      -> ayat per juz   (berpaginasi)
///  - GET /v3/quran/page/{n}     -> ayat per halaman (berpaginasi)
class QuranApiService {
  QuranApiService._();
  static final QuranApiService instance = QuranApiService._();

  static const String _base = 'https://api.myquran.com/v3/quran';
  static const Map<String, String> _headers = {'Accept': 'application/json'};
  static const Duration _timeout = Duration(seconds: 25);

  final http.Client _client = http.Client();

  // ---------------------------------------------------------------------------
  // Lapisan HTTP
  // ---------------------------------------------------------------------------

  /// Mengirim GET, memeriksa status HTTP, lalu mengurai JSON menjadi Map.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri, headers: _headers).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
        'Waktu tunggu habis. Periksa koneksi internet lalu coba lagi.',
      );
    } catch (_) {
      throw const ApiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
      );
    }

    if (response.statusCode != 200) {
      throw ApiException(
        'Server menolak permintaan (kode ${response.statusCode}).',
      );
    }

    try {
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) {
        throw const FormatException('Respons bukan objek JSON');
      }
      final json = Map<String, dynamic>.from(decoded);
      if (json['status'] == false) {
        throw const ApiException('Server melaporkan permintaan tidak berhasil.');
      }
      return json;
    } on FormatException {
      throw const ApiException('Data dari server tidak dapat diproses.');
    }
  }

  // ---------------------------------------------------------------------------
  // Endpoint
  // ---------------------------------------------------------------------------

  Future<List<Surah>> fetchSurahList() async {
    final json = await _getJson(Uri.parse(_base));
    final list = asMapList(json['data']).map(Surah.fromJson).toList();
    if (list.isEmpty) {
      throw const ApiException('Daftar surah kosong.');
    }
    return list;
  }

  Future<Ayah> fetchRandomAyah() async {
    final json = await _getJson(Uri.parse('$_base/random'));
    final data = asMap(json['data']);
    if (data.isEmpty) {
      throw const ApiException('Ayat acak tidak tersedia.');
    }
    return Ayah.fromJson(data);
  }

  Future<AyahPage> fetchJuz(int juz, {int page = 1}) =>
      _fetchAyahPage('juz/$juz', page);

  Future<AyahPage> fetchPage(int number, {int page = 1}) =>
      _fetchAyahPage('page/$number', page);

  Future<AyahPage> _fetchAyahPage(String path, int page) async {
    var uri = Uri.parse('$_base/$path');
    if (page > 1) {
      uri = uri.replace(queryParameters: {'page': '$page'});
    }
    final json = await _getJson(uri);
    final items = asMapList(json['data']).map(Ayah.fromJson).toList();
    final p = asMap(json['pagination']);
    return AyahPage(
      items: items,
      page: asInt(p['page'], page),
      limit: asInt(p['limit'], items.length),
      total: asInt(p['total'], items.length),
    );
  }

  /// Mengambil SEMUA ayat pada satu halaman mushaf (menelusuri paginasi).
  Future<List<Ayah>> fetchMushafPage(int number) async {
    final result = <Ayah>[];
    final seen = <int>{};
    var page = 1;
    while (page <= 30) {
      final res = await fetchPage(number, page: page);
      var added = 0;
      for (final ayah in res.items) {
        if (seen.add(ayah.id)) {
          result.add(ayah);
          added++;
        }
      }
      if (added == 0 || !res.hasMore) break;
      page++;
    }
    return result;
  }

  /// Mengambil ayat milik [surah] mulai dari halaman mushaf [startPage].
  ///
  /// Hasilnya hanya ayat dari surah tersebut. `nextCursor` berisi nomor
  /// halaman berikutnya, atau null jika surah sudah selesai.
  Future<AyahBatch> fetchSurahBatch(
    Surah surah,
    int startPage, {
    bool isFirst = false,
  }) async {
    var page = startPage.clamp(1, totalMushafPages).toInt();
    var lastMine = <Ayah>[];

    for (var guard = 0; guard < 8; guard++) {
      final all = await fetchMushafPage(page);
      final mine = all.where((a) => a.surahNumber == surah.number).toList();
      final passed = all.any((a) => a.surahNumber > surah.number);
      final finished = surah.numberOfAyahs > 0 &&
          mine.any((a) => a.ayahNumber >= surah.numberOfAyahs);
      lastMine = mine;

      // Pengaman: jika awal surah ternyata ada di halaman sebelumnya.
      if (isFirst && mine.isNotEmpty && mine.first.ayahNumber > 1 && page > 1) {
        page--;
        continue;
      }
      // Pengaman: halaman ini belum memuat surah yang dicari.
      if (mine.isEmpty && !passed && page < totalMushafPages) {
        page++;
        continue;
      }

      final done = passed || finished || page >= totalMushafPages;
      return AyahBatch(
        items: mine,
        nextCursor: done ? null : page + 1,
        total: surah.numberOfAyahs,
      );
    }
    return AyahBatch(items: lastMine, total: surah.numberOfAyahs);
  }
}
