import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  Flushbar(
    message: text,
    duration: Duration(seconds: 3),
    margin: EdgeInsets.all(8),
    borderRadius: BorderRadius.circular(8),
    backgroundColor: Colors.black87,
    flushbarPosition: FlushbarPosition.TOP,
  )..show(context);
}
