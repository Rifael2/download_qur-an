import 'package:flutter/material.dart';

import '../core/theme.dart';

void showMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.deepPurple,
        content: Text(message, style: appText(size: 13, color: Colors.white)),
      ),
    );
}
