import 'package:flutter/material.dart';

/// Text styles (colors are inherited from the active theme unless overridden).
class AppStyle {
  AppStyle._();

  static const TextStyle title24 =
      TextStyle(fontSize: 24, fontWeight: FontWeight.w700);
  static const TextStyle title20 =
      TextStyle(fontSize: 20, fontWeight: FontWeight.w600);
  static const TextStyle title18 =
      TextStyle(fontSize: 18, fontWeight: FontWeight.w600);
  static const TextStyle body16 =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w500);
  static const TextStyle body14 =
      TextStyle(fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle caption12 =
      TextStyle(fontSize: 12, fontWeight: FontWeight.w400);
  static const TextStyle button =
      TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white);

  static const double radius = 16;
  static const double pagePadding = 16;
}
