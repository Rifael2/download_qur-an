import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/models/ayah.dart';
import 'package:quran_app/models/ayah_page.dart';
import 'package:quran_app/models/surah.dart';

void main() {
  group('Surah.fromJson', () {
    test('membaca satu item daftar surah', () {
      final surah = Surah.fromJson({
        'number': 1,
        'name': 'Al-Fatihah',
        'name_latin': 'Al-Fatihah',
        'number_of_ayahs': 7,
        'translation': 'Pembukaan',
        'revelation': 'Makkiyah',
        'description': 'Surat Al Faatihah',
        'audio_url': 'https://cdn.myquran.com/audio/surah/1.mp3',
      });

      expect(surah.number, 1);
      expect(surah.nameLatin, 'Al-Fatihah');
      expect(surah.numberOfAyahs, 7);
      expect(surah.revelation, 'Makkiyah');
    });

    test('tidak error saat field hilang', () {
      final surah = Surah.fromJson(<String, dynamic>{});
      expect(surah.number, 0);
      expect(surah.nameLatin, '');
    });
  });

  group('Ayah.fromJson', () {
    final json = <String, dynamic>{
      'id': 1,
      'surah_number': 1,
      'ayah_number': 1,
      'arab': 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
      'translation': 'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
      'audio_url': 'https://cdn.myquran.com/audio/ayah/001001.mp3',
      'image_url': 'https://cdn.myquran.com/img/ayah/1_1.png',
      'tafsir': {
        'kemenag': {'short': 'Ringkas&nbsp;', 'long': 'Panjang'},
        'quraish': 'Quraish',
        'jalalayn': 'Jalalayn',
      },
      'meta': {
        'juz': 1,
        'page': 1,
        'manzil': 1,
        'ruku': 1,
        'hizb_quarter': 1,
        'sajda': {'recommended': false, 'obligatory': false},
      },
      'surah': {
        'number': 1,
        'name': 'Al-Fatihah',
        'name_latin': 'Al-Fatihah',
        'number_of_ayahs': 7,
        'translation': 'Pembukaan',
        'revelation': 'Makkiyah',
      },
    };

    test('membaca ayat lengkap beserta tafsir, meta, dan surah', () {
      final ayah = Ayah.fromJson(json);

      expect(ayah.id, 1);
      expect(ayah.ayahNumber, 1);
      expect(ayah.tafsir.kemenagShort, 'Ringkas'); // &nbsp; dibersihkan
      expect(ayah.tafsir.jalalayn, 'Jalalayn');
      expect(ayah.meta.page, 1);
      expect(ayah.meta.hasSajda, isFalse);
      expect(ayah.surah.nameLatin, 'Al-Fatihah');
    });

    test('tetap aman jika tafsir, meta, dan surah tidak ada', () {
      final ayah = Ayah.fromJson({
        'id': 5,
        'surah_number': 2,
        'ayah_number': 3,
        'arab': 'x',
        'translation': 'y',
      });

      expect(ayah.surah.number, 2);
      expect(ayah.tafsir.quraish, '');
      expect(ayah.meta.juz, 0);
    });
  });

  group('AyahPage.hasMore', () {
    final ayah = Ayah.fromJson({'id': 1, 'surah_number': 1, 'ayah_number': 1});

    test('true jika masih ada halaman berikutnya', () {
      final page = AyahPage(items: [ayah], page: 1, limit: 10, total: 25);
      expect(page.hasMore, isTrue);
    });

    test('false jika halaman terakhir', () {
      final page = AyahPage(items: [ayah], page: 3, limit: 10, total: 25);
      expect(page.hasMore, isFalse);
    });

    test('false jika data kosong (mencegah perulangan tak berujung)', () {
      const page = AyahPage(items: [], page: 1, limit: 10, total: 25);
      expect(page.hasMore, isFalse);
    });
  });
}
