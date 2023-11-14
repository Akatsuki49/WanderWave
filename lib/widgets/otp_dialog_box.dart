import 'package:flutter/material.dart';

void showOTPDialog({
  required BuildContext context,
  required TextEditingController codeController,
  required VoidCallback onPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text("Enter OTP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              keyboardType: TextInputType.number,
              controller: codeController,
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: onPressed,
            child: const Text("Enter"),
          ),
        ],
      );
    },
  );
}
