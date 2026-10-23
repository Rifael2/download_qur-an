/// Fungsi bantu agar parsing JSON tahan terhadap field yang null / tipe berbeda.

int asInt(dynamic v, [int fallback = 0]) {
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fallback;
  return fallback;
}

String asString(dynamic v, [String fallback = '']) =>
    v == null ? fallback : v.toString();

bool asBool(dynamic v) => v == true;

Map<String, dynamic> asMap(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

List<Map<String, dynamic>> asMapList(dynamic v) {
  if (v is! List) return <Map<String, dynamic>>[];
  return v
      .whereType<Map>()
      .map((m) => Map<String, dynamic>.from(m))
      .toList();
}

/// Membersihkan sisa entitas HTML / baris kosong berlebih pada teks tafsir.
String cleanText(String s) {
  return s
      .replaceAll('&nbsp;', ' ')
      .replaceAll('\r', '')
      .replaceAll(RegExp(r'[ \t]+\n'), '\n')
      .replaceAll(RegExp(r'\n{3,}'), '\n\n')
      .trim();
}
