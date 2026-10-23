import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Tampilan saat data sedang dimuat (state: loading).
class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Memuat data…'});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 36,
            height: 36,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.violet,
            ),
          ),
          const SizedBox(height: 16),
          Text(message, style: appText(size: 13, color: AppColors.muted)),
        ],
      ),
    );
  }
}

/// Tampilan saat pengambilan data gagal (state: error) beserta tombol ulang.
class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.lavender,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: AppColors.violet,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Data gagal dimuat',
              style: appText(size: 16, weight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: appText(size: 13, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.violet,
                padding:
                    const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 20),
              label: Text(
                'Coba lagi',
                style: appText(
                  size: 14,
                  weight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tampilan saat data berhasil dimuat tetapi kosong.
class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: appText(size: 14, color: AppColors.muted),
        ),
      ),
    );
  }
}
