import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../store.dart';
import '../theme.dart';
import '../widgets.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: Stack(alignment: Alignment.center, clipBehavior: Clip.none, children: [
            Positioned(
              left: -70,
              child: Container(
                width: 230,
                height: 230,
                decoration: const BoxDecoration(color: AppColors.peach, shape: BoxShape.circle),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 36, vertical: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [BoxShadow(color: Color(0x33000000), blurRadius: 30, offset: Offset(0, 14))],
              ),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 8),
                Text('Quran App',
                    style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark)),
                const SizedBox(height: 8),
                const Text('Learn Quran and\nRecite once everyday',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.grey)),
                const SizedBox(height: 24),
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(color: const Color(0xFF5B34A8), borderRadius: BorderRadius.circular(20)),
                  child: Stack(alignment: Alignment.center, children: [
                    const Positioned(top: 26, left: 30, child: Icon(Icons.star_rounded, size: 10, color: Colors.amber)),
                    const Positioned(top: 50, right: 36, child: Icon(Icons.star_rounded, size: 8, color: Colors.amber)),
                    const Positioned(top: 90, left: 60, child: Icon(Icons.star_rounded, size: 7, color: Colors.amber)),
                    const Padding(padding: EdgeInsets.only(bottom: 30), child: BookIllustration(width: 190)),
                    Positioned(
                      bottom: 16,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.peach,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                        ),
                        onPressed: () {
                          Store.setSeenWelcome();
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
                        },
                        child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
