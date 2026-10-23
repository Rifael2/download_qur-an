import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'about_page.dart';
import 'home_page.dart';
import 'random_ayah_page.dart';

/// Kerangka utama dengan bilah navigasi bawah (Beranda, Ayat Acak, Tentang).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  bool _randomOpened = false;

  void _select(int i) {
    setState(() {
      _index = i;
      if (i == 1) _randomOpened = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          const HomePage(),
          // Dibuat saat pertama dibuka agar tidak memanggil API sebelum perlu.
          _randomOpened ? const RandomAyahPage() : const SizedBox.shrink(),
          const AboutPage(),
        ],
      ),
      bottomNavigationBar: _BottomBar(index: _index, onSelect: _select),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: AppColors.violet.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                selected: index == 0,
                onTap: () => onSelect(0),
              ),
              GestureDetector(
                onTap: () => onSelect(1),
                child: Tooltip(
                  message: 'Ayat acak',
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.violet, AppColors.deepPurple],
                      ),
                      border: index == 1
                          ? Border.all(color: AppColors.peach, width: 3)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.violet.withAlpha(90),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.shuffle_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              _NavItem(
                icon: Icons.info_outline_rounded,
                label: 'Tentang',
                selected: index == 2,
                onTap: () => onSelect(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.violet : AppColors.muted;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: appText(
                size: 11,
                weight: selected ? FontWeight.w600 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
