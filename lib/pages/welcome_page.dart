import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'main_shell.dart';

/// Layar sambutan (mengikuti referensi desain).
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  void _start(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned(
                  left: -50,
                  top: 150,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: const BoxDecoration(
                      color: AppColors.peach,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.deepPurple.withAlpha(70),
                          blurRadius: 30,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Quran App',
                          style: appText(
                            size: 24,
                            weight: FontWeight.w700,
                            color: AppColors.deepPurple,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pelajari Al-Qur\'an dan\nbaca setiap hari',
                          textAlign: TextAlign.center,
                          style: appText(
                            size: 13,
                            color: AppColors.muted,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 22),
                        const _Illustration(),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: 180,
                          child: FilledButton(
                            onPressed: () => _start(context),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.peach,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text(
                              'Mulai',
                              style: appText(
                                size: 15,
                                weight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Illustration extends StatelessWidget {
  const _Illustration();

  @override
  Widget build(BuildContext context) {
    const star = Color(0x99FFFFFF);
    const cloud = Color(0x26FFFFFF);
    return Container(
      height: 250,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF6B3BBE),
        borderRadius: BorderRadius.circular(26),
      ),
      child: const Stack(
        children: [
          Positioned(left: 30, top: 30, child: Icon(Icons.star_rounded, size: 9, color: star)),
          Positioned(right: 44, top: 44, child: Icon(Icons.star_rounded, size: 12, color: star)),
          Positioned(left: 70, top: 78, child: Icon(Icons.star_rounded, size: 7, color: star)),
          Positioned(right: 28, top: 100, child: Icon(Icons.star_rounded, size: 8, color: star)),
          Positioned(left: 14, top: 120, child: Icon(Icons.cloud_rounded, size: 54, color: cloud)),
          Positioned(right: 10, top: 18, child: Icon(Icons.cloud_rounded, size: 46, color: cloud)),
          Center(
            child: Icon(
              Icons.menu_book_rounded,
              size: 130,
              color: Color(0xFFFFE6CF),
            ),
          ),
        ],
      ),
    );
  }
}
