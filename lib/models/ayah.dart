import 'json_helpers.dart';
import 'surah.dart';

class Tafsir {
  const Tafsir({
    this.kemenagShort = '',
    this.kemenagLong = '',
    this.quraish = '',
    this.jalalayn = '',
  });

  final String kemenagShort;
  final String kemenagLong;
  final String quraish;
  final String jalalayn;

  factory Tafsir.fromJson(Map<String, dynamic> json) {
    final kemenag = asMap(json['kemenag']);
    return Tafsir(
      kemenagShort: cleanText(asString(kemenag['short'])),
      kemenagLong: cleanText(asString(kemenag['long'])),
      quraish: cleanText(asString(json['quraish'])),
      jalalayn: cleanText(asString(json['jalalayn'])),
    );
  }
}

class AyahMeta {
  const AyahMeta({
    this.juz = 0,
    this.page = 0,
    this.manzil = 0,
    this.ruku = 0,
    this.hizbQuarter = 0,
    this.sajdaRecommended = false,
    this.sajdaObligatory = false,
  });

  final int juz;
  final int page;
  final int manzil;
  final int ruku;
  final int hizbQuarter;
  final bool sajdaRecommended;
  final bool sajdaObligatory;

  bool get hasSajda => sajdaRecommended || sajdaObligatory;

  factory AyahMeta.fromJson(Map<String, dynamic> json) {
    final sajda = asMap(json['sajda']);
    return AyahMeta(
      juz: asInt(json['juz']),
      page: asInt(json['page']),
      manzil: asInt(json['manzil']),
      ruku: asInt(json['ruku']),
      hizbQuarter: asInt(json['hizb_quarter']),
      sajdaRecommended: asBool(sajda['recommended']),
      sajdaObligatory: asBool(sajda['obligatory']),
    );
  }
}

/// Model satu ayat. Dipakai oleh endpoint random, juz, dan page.
class Ayah {
  const Ayah({
    required this.id,
    required this.surahNumber,
    required this.ayahNumber,
    required this.arab,
    required this.translation,
    required this.audioUrl,
    required this.imageUrl,
    required this.tafsir,
    required this.meta,
    required this.surah,
  });

  final int id;
  final int surahNumber;
  final int ayahNumber;
  final String arab;
  final String translation;
  final String audioUrl;
  final String imageUrl;
  final Tafsir tafsir;
  final AyahMeta meta;
  final Surah surah;

  factory Ayah.fromJson(Map<String, dynamic> json) {
    final surahNumber = asInt(json['surah_number']);
    final surahMap = asMap(json['surah']);
    final surah = surahMap.isEmpty
        ? Surah(
            number: surahNumber,
            name: 'Surah $surahNumber',
            nameLatin: 'Surah $surahNumber',
            numberOfAyahs: 0,
            translation: '',
            revelation: '',
          )
        : Surah.fromJson(surahMap);

    return Ayah(
      id: asInt(json['id']),
      surahNumber: surahNumber == 0 ? surah.number : surahNumber,
      ayahNumber: asInt(json['ayah_number']),
      arab: asString(json['arab']),
      translation: asString(json['translation']),
      audioUrl: asString(json['audio_url']),
      imageUrl: asString(json['image_url']),
      tafsir: Tafsir.fromJson(asMap(json['tafsir'])),
      meta: AyahMeta.fromJson(asMap(json['meta'])),
      surah: surah,
    );
  }
}
