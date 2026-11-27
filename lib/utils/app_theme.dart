import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color.dart';
import 'app_style.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => _build(
        brightness: Brightness.light,
        bg: AppColor.lightBg,
        surface: AppColor.white,
        text: AppColor.black,
      );

  static ThemeData get dark => _build(
        brightness: Brightness.dark,
        bg: AppColor.darkBg,
        surface: AppColor.darkCard,
        text: AppColor.white,
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color text,
  }) {
    final base = ThemeData(brightness: brightness);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppStyle.radius),
      borderSide: BorderSide(
          color: brightness == Brightness.light
              ? AppColor.lightGrey
              : AppColor.primary.withValues(alpha: .5)),
    );

    return base.copyWith(
      scaffoldBackgroundColor: bg,
      primaryColor: AppColor.primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColor.primary,
        brightness: brightness,
        primary: AppColor.primary,
        surface: surface,
        onSurface: text,
      ),
      textTheme: GoogleFonts.poppinsTextTheme(base.textTheme)
          .apply(bodyColor: text, displayColor: text),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColor.primary,
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 20, fontWeight: FontWeight.w500, color: AppColor.primary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.transparent,
        hintStyle: const TextStyle(color: AppColor.grey, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColor.primary, width: 1.5)),
        errorBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColor.red)),
        focusedErrorBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColor.red)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(56),
          textStyle: AppStyle.button,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppStyle.radius)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColor.primary),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        shape: CircleBorder(side: BorderSide(color: Colors.white, width: 4)),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      dividerColor: AppColor.primary.withValues(alpha: .2),
    );
  }
}
