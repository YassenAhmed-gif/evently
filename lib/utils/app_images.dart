import 'package:flutter/material.dart';

/// Asset paths. Export the illustrations from Figma into assets/images/
/// using these exact file names. Until then, [AppImage] shows an icon fallback.
class AppImages {
  AppImages._();

  static const String _base = 'assets/images/';

  static const String logo = '${_base}logo.png';
  static const String onboarding1 = '${_base}onboarding_1.png';
  static const String onboarding2 = '${_base}onboarding_2.png';
  static const String onboarding3 = '${_base}onboarding_3.png';
  static const String onboarding4 = '${_base}onboarding_4.png';
  static const String forgot = '${_base}forgot_password.png';
  static const String google = '${_base}google.png';
  static const String avatar = '${_base}avatar.png';
}

/// Image that never crashes if the asset is missing.
class AppImage extends StatelessWidget {
  final String path;
  final double? width;
  final double? height;
  final IconData fallback;
  final Color? fallbackColor;

  const AppImage(
    this.path, {
    super.key,
    this.width,
    this.height,
    this.fallback = Icons.image_outlined,
    this.fallbackColor,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: width,
      height: height,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => SizedBox(
        width: width,
        height: height,
        child: Icon(
          fallback,
          size: (width ?? height ?? 80) * 0.6,
          color: fallbackColor ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
