import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

class Store {
  static late SharedPreferences _p;
  static final bookmarks = ValueNotifier<List<Ayah>>([]);
  static final lastRead = ValueNotifier<Ayah?>(null);

  static Future<void> init() async {
    _p = await SharedPreferences.getInstance();
    bookmarks.value = (_p.getStringList('bookmarks') ?? [])
        .map((e) => Ayah.fromMap(jsonDecode(e) as Map<String, dynamic>))
        .toList();
    final lr = _p.getString('last_read');
    if (lr != null) lastRead.value = Ayah.fromMap(jsonDecode(lr) as Map<String, dynamic>);
  }

  static bool get seenWelcome => _p.getBool('seen_welcome') ?? false;
  static Future<void> setSeenWelcome() => _p.setBool('seen_welcome', true);

  static bool isBookmarked(Ayah a) => bookmarks.value.any((b) => b.key == a.key);

  static Future<void> toggleBookmark(Ayah a) async {
    final list = [...bookmarks.value];
    final i = list.indexWhere((b) => b.key == a.key);
    if (i >= 0) {
      list.removeAt(i);
    } else {
      list.insert(0, a);
    }
    bookmarks.value = list;
    await _p.setStringList('bookmarks', list.map((e) => jsonEncode(e.toMap())).toList());
  }

  static Future<void> setLastRead(Ayah a) async {
    lastRead.value = a;
    await _p.setString('last_read', jsonEncode(a.toMap()));
  }
}
