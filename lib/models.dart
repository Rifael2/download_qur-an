import 'data.dart';

int _i(dynamic v) => (v as num?)?.toInt() ?? 0;
String _s(dynamic v) => v?.toString() ?? '';
Map<String, dynamic> _m(dynamic v) => v is Map<String, dynamic> ? v : <String, dynamic>{};

class Surah {
  const Surah({
    required this.number,
    required this.latin,
    required this.translation,
    required this.revelation,
    required this.ayahs,
    required this.audioUrl,
  });

  factory Surah.fromJson(Map<String, dynamic> j) => Surah(
        number: _i(j['number']),
        latin: _s(j['name_latin']).isEmpty ? _s(j['name']) : _s(j['name_latin']),
        translation: _s(j['translation']),
        revelation: _s(j['revelation']),
        ayahs: _i(j['number_of_ayahs']),
        audioUrl: _s(j['audio_url']),
      );

  final int number, ayahs;
  final String latin, translation, revelation, audioUrl;

  String get arabic => kSurahArabic[number - 1];
}

class Ayah {
  const Ayah({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.arab,
    required this.translation,
    required this.audioUrl,
    required this.tafsirShort,
    required this.surahName,
    required this.surahTranslation,
    required this.revelation,
    required this.juz,
    required this.page,
  });

  factory Ayah.fromApi(Map<String, dynamic> j) {
    final s = _m(j['surah']);
    final m = _m(j['meta']);
    final k = _m(_m(j['tafsir'])['kemenag']);
    return Ayah(
      id: _i(j['id']),
      surahNumber: _i(j['surah_number']),
      ayahNumber: _i(j['ayah_number']),
      arab: _s(j['arab']),
      translation: _s(j['translation']),
      audioUrl: _s(j['audio_url']),
      tafsirShort: _s(k['short']).replaceAll('&nbsp;', ' ').trim(),
      surahName: _s(s['name_latin']),
      surahTranslation: _s(s['translation']),
      revelation: _s(s['revelation']),
      juz: _i(m['juz']),
      page: _i(m['page']),
    );
  }

  factory Ayah.fromMap(Map<String, dynamic> m) => Ayah(
        id: _i(m['id']),
        surahNumber: _i(m['surahNumber']),
        ayahNumber: _i(m['ayahNumber']),
        arab: _s(m['arab']),
        translation: _s(m['translation']),
        audioUrl: _s(m['audioUrl']),
        tafsirShort: _s(m['tafsirShort']),
        surahName: _s(m['surahName']),
        surahTranslation: _s(m['surahTranslation']),
        revelation: _s(m['revelation']),
        juz: _i(m['juz']),
        page: _i(m['page']),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'surahNumber': surahNumber,
        'ayahNumber': ayahNumber,
        'arab': arab,
        'translation': translation,
        'audioUrl': audioUrl,
        'tafsirShort': tafsirShort,
        'surahName': surahName,
        'surahTranslation': surahTranslation,
        'revelation': revelation,
        'juz': juz,
        'page': page,
      };

  final int id, surahNumber, ayahNumber, juz, page;
  final String arab, translation, audioUrl, tafsirShort, surahName, surahTranslation, revelation;

  String get key => '$surahNumber:$ayahNumber';
}
