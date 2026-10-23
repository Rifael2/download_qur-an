import 'ayah.dart';

/// Satu halaman respons berpaginasi dari API (`data` + `pagination`).
class AyahPage {
  const AyahPage({
    required this.items,
    required this.page,
    required this.limit,
    required this.total,
  });

  final List<Ayah> items;
  final int page;
  final int limit;
  final int total;

  bool get hasMore => items.isNotEmpty && limit > 0 && page * limit < total;
}

/// Hasil satu kali pemuatan pada layar daftar ayat.
/// [nextCursor] bernilai null jika seluruh data sudah termuat.
class AyahBatch {
  const AyahBatch({required this.items, this.nextCursor, this.total});

  final List<Ayah> items;
  final int? nextCursor;
  final int? total;
}
