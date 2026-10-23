# Quran App

Aplikasi mobile Al-Qur'an berbasis **Flutter (Dart)** yang menampilkan daftar surah, ayat per juz, ayat per halaman, dan ayat acak dari **MyQuran API v3**. Dibuat untuk UTS Pemrograman Mobile (Praktikum G).

## Deskripsi singkat
Pengguna dapat menelusuri Al-Qur'an lewat tiga cara (Surah, Juz, Halaman), membaca teks Arab beserta terjemahan Indonesia, membuka tafsir, memutar audio per ayat, dan mendapatkan satu ayat acak untuk direnungkan. Tampilan mengikuti referensi desain bernuansa ungu.

## Fitur utama
- Daftar 114 surah beserta arti, jenis wahyu, dan jumlah ayat, dengan pencarian.
- Ayat per **surah**, per **juz** (1–30), dan per **halaman** (1–604), dimuat bertahap saat menggulir.
- **Ayat acak** dengan tombol "Acak ayat lagi".
- Terjemahan, tafsir (Kemenag, Quraish Shihab, Jalalayn), dan audio per ayat.
- Salin ayat dan tandai **terakhir dibaca** (tersimpan di perangkat).
- Penanganan status **loading / success / error** memakai `FutureBuilder`, lengkap dengan tombol "Coba lagi".

## Sumber data (API)
| Kebutuhan | Endpoint |
|---|---|
| Daftar surah | `GET https://api.myquran.com/v3/quran` |
| Ayat acak | `GET https://api.myquran.com/v3/quran/random` |
| Ayat per juz | `GET https://api.myquran.com/v3/quran/juz/{n}` |
| Ayat per halaman | `GET https://api.myquran.com/v3/quran/page/{n}` |

Dokumentasi: https://api.myquran.com/v3/doc

> API tidak menyediakan endpoint "ayat per surah". Karena itu ayat sebuah surah diambil dari endpoint halaman, mulai dari halaman awal surah tersebut (tabel di `lib/core/surah_pages.dart`), lalu disaring berdasarkan `surah_number`.

## Teknologi dan package
| Package | Fungsi |
|---|---|
| `http` | Permintaan HTTP ke API |
| `google_fonts` | Font Poppins (UI) dan Amiri (teks Arab) |
| `audioplayers` | Memutar audio ayat dari `audio_url` |
| `shared_preferences` | Menyimpan penanda terakhir dibaca |

## Struktur folder
```
lib/
├── main.dart                  # entry point
├── core/                      # tema + tabel halaman awal surah
├── models/                    # Surah, Ayah, Tafsir, AyahMeta, AyahPage (fromJson)
├── services/                  # QuranApiService, sumber ayat, audio, last-read
├── pages/                     # welcome, main_shell, home, ayah_list, random, about
└── widgets/                   # tile ayat, header, tafsir sheet, state views
test/
└── models_test.dart           # unit test parsing JSON -> model
```

## Langkah menjalankan
1. Pastikan Flutter SDK sudah terpasang (`flutter doctor`).
2. Buat project Flutter di folder kosong, lalu salin berkas project ini ke atasnya:
   ```bash
   flutter create quran_app
   ```
   Timpa `pubspec.yaml`, `lib/`, dan `test/` dengan isi repositori ini. Hapus `test/widget_test.dart` bawaan.
3. **Android:** tambahkan izin internet pada `android/app/src/main/AndroidManifest.xml`, tepat di atas tag `<application ...>`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   ```
4. Pasang dependensi dan jalankan:
   ```bash
   flutter pub get
   flutter run
   ```
5. Jalankan pengujian: `flutter test`

Perangkat/emulator memerlukan koneksi internet.
