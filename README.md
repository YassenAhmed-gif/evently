# Evently (Flutter)

## Run
```
flutter pub get        # also generates lib/l10n/app_localizations.dart
flutter create .       # only if android/ios folders are missing
flutter run
```

## Structure
- lib/utils      -> app_color, app_theme, app_routes, app_images, app_style
- lib/l10n       -> app_en.arb, app_ar.arb (EN + AR with RTL)
- lib/providers  -> theme, locale, nav, profile, events (Provider)
- lib/screens    -> splash, onboarding, auth, main (bottom nav + FAB), home/map/favorites/profile tabs, create event
- lib/widgets    -> reusable widgets (text field, bottom sheet, chips, event card)

## Images
Export illustrations from Figma into assets/images/ using the names in utils/app_images.dart.
