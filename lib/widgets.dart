import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import 'models.dart';
import 'store.dart';
import 'theme.dart';

/// Pemutar audio tunggal (satu audio aktif pada satu waktu).
class AudioService {
  static final _player = AudioPlayer();
  static final playingKey = ValueNotifier<String?>(null);
  static bool _ready = false;

  static void _setup() {
    if (_ready) return;
    _ready = true;
    _player.playerStateStream.listen((s) {
      if (s.processingState == ProcessingState.completed) playingKey.value = null;
    });
  }

  static Future<void> toggle(String key, String url) async {
    _setup();
    if (playingKey.value == key) {
      await stop();
      return;
    }
    try {
      playingKey.value = key;
      await _player.setUrl(url);
      await _player.play();
    } catch (_) {
      playingKey.value = null;
    }
  }

  static Future<void> stop() async {
    await _player.stop();
    playingKey.value = null;
  }
}

/// Ilustrasi Al-Quran di atas rehal (digambar dengan CustomPainter).
class BookIllustration extends StatelessWidget {
  const BookIllustration({super.key, this.width = 180});
  final double width;

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: width, height: width * .8, child: CustomPaint(painter: _BookPainter()));
}

class _BookPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width, h = s.height;
    Offset p(double x, double y) => Offset(w * x, h * y);
    double mx(double x, double m) => .5 + m * (x - .5);
    Path poly(List<Offset> pts) {
      final path = Path()..moveTo(pts[0].dx, pts[0].dy);
      for (final o in pts.skip(1)) {
        path.lineTo(o.dx, o.dy);
      }
      return path..close();
    }

    final leg = Paint()
      ..color = const Color(0xFF7A5BC7)
      ..strokeWidth = w * .04
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(p(.25, .95), p(.75, .62), leg);
    canvas.drawLine(p(.75, .95), p(.25, .62), leg);

    canvas.drawPath(
      poly([p(.04, .36), p(.5, .50), p(.96, .36), p(.96, .66), p(.5, .80), p(.04, .66)]),
      Paint()..color = const Color(0xFFF4B26B),
    );

    final line = Paint()
      ..color = const Color(0xFFB9A4E0)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    double yAt(double x, double t) => .30 + t * .28 + .10 * ((x - .08) / .42);
    for (final m in [1.0, -1.0]) {
      canvas.drawPath(
        poly([p(mx(.08, m), .30), p(.5, .40), p(.5, .68), p(mx(.08, m), .58)]),
        Paint()..color = const Color(0xFFF3ECFB),
      );
      for (final t in [.2, .4, .6, .8]) {
        canvas.drawLine(p(mx(.15, m), yAt(.15, t)), p(mx(.43, m), yAt(.43, t)), line);
      }
    }
    canvas.drawLine(
      p(.5, .40),
      p(.5, .68),
      Paint()
        ..color = const Color(0xFF5CC8D8)
        ..strokeWidth = 2.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

/// Lencana nomor surah (bentuk bintang 8 sudut sederhana).
class NumberBadge extends StatelessWidget {
  const NumberBadge(this.n, {super.key});
  final int n;

  @override
  Widget build(BuildContext context) {
    Widget sq(double angle) => Transform.rotate(
          angle: angle,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.primary, width: 1.2),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        );
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(alignment: Alignment.center, children: [
        sq(0),
        sq(.785),
        Text('$n',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.dark)),
      ]),
    );
  }
}

/// Kartu satu ayat: Arab, terjemahan, salin, putar audio, bookmark, tafsir.
class AyahTile extends StatefulWidget {
  const AyahTile({super.key, required this.ayah, this.showSurah = false});
  final Ayah ayah;
  final bool showSurah;

  @override
  State<AyahTile> createState() => _AyahTileState();
}

class _AyahTileState extends State<AyahTile> {
  bool _tafsir = false;

  Widget _btn(IconData icon, VoidCallback onTap, {Color color = AppColors.primary}) => InkResponse(
        onTap: onTap,
        radius: 20,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 7),
          child: Icon(icon, size: 19, color: color),
        ),
      );

  void _snack(String msg) {
    final m = ScaffoldMessenger.of(context);
    m.hideCurrentSnackBar();
    m.showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 1)));
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.ayah;
    return GestureDetector(
      onTap: () {
        Store.setLastRead(a);
        _snack('Ditandai terakhir dibaca: ${a.surahName} ayat ${a.ayahNumber}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.primary.withOpacity(.10), blurRadius: 14, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: AppColors.primary,
                child: Text('${a.ayahNumber}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
              ),
              if (widget.showSurah)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text('${a.surahName} • ${a.surahNumber}:${a.ayahNumber}',
                      style: const TextStyle(fontSize: 11, color: AppColors.dark)),
                ),
              const Spacer(),
              _btn(Icons.copy_rounded, () {
                Clipboard.setData(ClipboardData(
                    text: '${a.arab}\n\n${a.translation}\n(QS ${a.surahName}: ${a.ayahNumber})'));
                _snack('Ayat disalin');
              }),
              ValueListenableBuilder<String?>(
                valueListenable: AudioService.playingKey,
                builder: (_, k, __) {
                  final on = k == a.key;
                  return _btn(on ? Icons.stop_circle_rounded : Icons.play_arrow_rounded,
                      () => AudioService.toggle(a.key, a.audioUrl));
                },
              ),
              ValueListenableBuilder<List<Ayah>>(
                valueListenable: Store.bookmarks,
                builder: (_, __, ___) => _btn(
                  Store.isBookmarked(a) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  () => Store.toggleBookmark(a),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 14),
          Text(
            a.arab,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: GoogleFonts.amiri(fontSize: 26, height: 2, color: AppColors.dark),
          ),
          const SizedBox(height: 6),
          Text(a.translation, style: const TextStyle(fontSize: 12.5, height: 1.5, color: Color(0xFF444058))),
          if (a.tafsirShort.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => setState(() => _tafsir = !_tafsir),
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 32)),
                child: Text(_tafsir ? 'Sembunyikan tafsir' : 'Lihat tafsir',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary)),
              ),
            ),
            if (_tafsir)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColors.light, borderRadius: BorderRadius.circular(10)),
                child: Text(a.tafsirShort, style: const TextStyle(fontSize: 12, height: 1.5)),
              ),
          ],
        ]),
      ),
    );
  }
}
