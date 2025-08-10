import 'package:crypto/crypto.dart';
import 'dart:convert';

String sha256Hash(String input) {
  return sha256.convert(utf8.encode(input)).toString();
}