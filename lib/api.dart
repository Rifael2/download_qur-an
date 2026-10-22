import 'dart:convert';

import 'package:http/http.dart' as http;

import 'data.dart';
import 'models.dart';

class ApiException implements Exception {
  ApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AyahChunk {
  AyahChunk(this.items, this.hasMore);
  final List<Ayah> items;
  final bool hasMore;
}

typedef ChunkFetcher = Future<AyahChunk> Function(int step);

/// Semua endpoint berasal dari https://api.myquran.com/v3/quran
class QuranApi {
  static const _base = 'https://api.myquran.com/v3/quran';
  static const _headers = {'Accept': 'application/json'};
  static List<Surah>? _surahCache;

  static Future<Map<String, dynamic>> _get(String path) async {
    try {
      final res = await http
          .get(Uri.parse('$_base$path'), headers: _headers)
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) {
        throw ApiException('Permintaan gagal (${res.statusCode})');
      }
      final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
      if (body['status'] != true) throw ApiException('Respons API tidak valid');
      return body;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Tidak dapat terhubung. Periksa koneksi internet.');
    }
  }

  /// GET /v3/quran  -> daftar surah
  static Future<List<Surah>> surahs() async {
    if (_surahCache != null) return _surahCache!;
    final body = await _get('');
    _surahCache = (body['data'] as List)
        .map((e) => Surah.fromJson(e as Map<String, dynamic>))
        .toList();
    return _surahCache!;
  }

  /// GET /v3/quran/random -> ayat acak
  static Future<Ayah> randomAyah() async {
    final body = await _get('/random');
    return Ayah.fromApi(body['data'] as Map<String, dynamic>);
  }

  static Future<AyahChunk> _ayahs(String path, int apiPage) async {
    final body = await _get(apiPage > 1 ? '$path?page=$apiPage' : path);
    final items = (body['data'] as List)
        .map((e) => Ayah.fromApi(e as Map<String, dynamic>))
        .toList();
    final p = body['pagination'];
    final limit = p is Map ? ((p['limit'] as num?)?.toInt() ?? 0) : 0;
    final total = p is Map ? ((p['total'] as num?)?.toInt() ?? items.length) : items.length;
    final page = p is Map ? ((p['page'] as num?)?.toInt() ?? apiPage) : apiPage;
    return AyahChunk(items, limit > 0 && page * limit < total);
  }

  /// GET /v3/quran/juz/{n}  (per "step" = satu halaman pagination API)
  static Future<AyahChunk> juz(int n, int step) => _ayahs('/juz/$n', step + 1);

  /// GET /v3/quran/page/{n}  -> seluruh ayat satu halaman mushaf
  /// (menelusuri pagination API sampai semua ayat terambil)
  static Future<List<Ayah>> pageAll(int n) async {
    final all = <Ayah>[];
    final seen = <int>{};
    for (var p = 1; p <= 20; p++) {
      final c = await _ayahs('/page/$n', p);
      final fresh = c.items.where((a) => seen.add(a.id)).toList();
      if (fresh.isEmpty) break;
      all.addAll(fresh);
      if (!c.hasMore) break;
    }
    return all;
  }

  /// Ayat satu surah: ambil halaman mushaf dari halaman awal surah,
  /// lalu saring berdasarkan nomor surah.
  static Future<AyahChunk> surahChunk(int number, int step) async {
    final start = kSurahStartPage[number - 1];
    final end = number < 114 ? kSurahStartPage[number] : 604;
    final items =
        (await pageAll(start + step)).where((a) => a.surahNumber == number).toList();
    return AyahChunk(items, start + step < end);
  }
}
