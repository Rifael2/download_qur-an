import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/json_helpers.dart';

/// Penanda "terakhir dibaca" yang disimpan di perangkat.
class LastRead {
  const LastRead({
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    required this.page,
  });

  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final int page;

  Map<String, dynamic> toJson() => {
        'surahName': surahName,
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'page': page,
      };

  factory LastRead.fromJson(Map<String, dynamic> json) => LastRead(
        surahName: asString(json['surahName']),
        surahNumber: asInt(json['surahNumber']),
        ayahNumber: asInt(json['ayahNumber']),
        page: asInt(json['page'], 1),
      );
}

class LastReadStore {
  static const String _key = 'last_read_v1';

  Future<LastRead?> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return LastRead.fromJson(Map<String, dynamic>.from(decoded));
      }
    } catch (_) {
      // Data rusak diabaikan; dianggap belum ada penanda.
    }
    return null;
  }

  Future<void> save(LastRead value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(value.toJson()));
  }
}
