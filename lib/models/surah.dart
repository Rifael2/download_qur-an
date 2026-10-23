import 'json_helpers.dart';

/// Model satu surah. Dipakai oleh `GET /v3/quran` dan juga objek `surah`
/// yang tertanam di setiap ayat.
class Surah {
  const Surah({
    required this.number,
    required this.name,
    required this.nameLatin,
    required this.numberOfAyahs,
    required this.translation,
    required this.revelation,
    this.description = '',
    this.audioUrl = '',
  });

  final int number;
  final String name;
  final String nameLatin;
  final int numberOfAyahs;
  final String translation;
  final String revelation;
  final String description;
  final String audioUrl;

  factory Surah.fromJson(Map<String, dynamic> json) {
    final name = asString(json['name']);
    return Surah(
      number: asInt(json['number']),
      name: name,
      nameLatin: asString(json['name_latin'], name),
      numberOfAyahs: asInt(json['number_of_ayahs']),
      translation: asString(json['translation']),
      revelation: asString(json['revelation']),
      description: cleanText(asString(json['description'])),
      audioUrl: asString(json['audio_url']),
    );
  }
}
