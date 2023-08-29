import 'package:flutter/material.dart';

Future<void> showConfirmationDialog(
    BuildContext context, {
      required String title,
      required String message,
      Color? dialogColor,
      Function? onConfirm,
    }) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: dialogColor ?? Colors.white, // Màu nền của hộp thoại
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(message),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.red), // Màu của nút "Cancel"
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại khi nhấn "Cancel"
            },
          ),
          TextButton(
            child: Text(
              'Confirm',
              style: TextStyle(color: Colors.blue), // Màu của nút "Confirm"
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Đóng hộp thoại khi nhấn "Confirm"
              if (onConfirm != null) {
                onConfirm(); // Gọi hàm xử lý khi nhấn "Confirm"
              }
            },
          ),
        ],
      );
    },
  );
}
