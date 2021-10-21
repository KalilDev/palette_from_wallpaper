// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaletteFromWallpaper {
  static const MethodChannel _channel =
      MethodChannel('package:palette_from_wallpaper/method');
  static const EventChannel _eventChannel =
      EventChannel('package:palette_from_wallpaper/events');

  static final Stream<PlatformPalette> paletteUpdates = _eventChannel
      .receiveBroadcastStream()
      .map((event) => PlatformPalette._fromMap(event as Map<dynamic, dynamic>));

  /// Get the [PlatformPalette] from the native implementation
  static Future<PlatformPalette?> getPalette({bool nullOk = true}) async {
    final paletteMap =
        await _channel.invokeMethod<Map<dynamic, dynamic>>('getPalette');
    if (paletteMap == null) {
      if (!nullOk) {
        throw PlatformException(code: 'NO_PALETTE');
      }
      return null;
    }
    return PlatformPalette._fromMap(paletteMap);
  }

  /// Get the [PlatformPalette] from the native implementation, while swallowing
  /// errors for an more convenient usage
  static Future<PlatformPalette?> get palette async {
    try {
      return getPalette();
    } on PlatformException {
      return null;
    }
  }
}

/// An enumeration of where did the [PlatformPalette] originate.
///
/// This may be useful to know so that the app may choose an more customized
/// theme in case the source is not the platform for example.
enum PaletteSource {
  platform,
  fallback,
  errorHandler,
}

/// The palette of the user's wallpaper originated from the android class
/// `android.app.WallpaperColors`, computed by the WallpaperManager
class PlatformPalette {
  factory PlatformPalette._fromMap(Map<dynamic, dynamic> map) {
    final primary = map['primaryColor'] as int;
    final secondary = map['secondaryColor'] as int?;
    final tertiary = map['tertiaryColor'] as int?;
    final colorHints = map['colorHints'] as int?;
    return PlatformPalette._(
      primaryColor: Color(primary),
      secondaryColor: secondary == null ? null : Color(secondary),
      tertiaryColor: tertiary == null ? null : Color(tertiary),
      colorHints: colorHints,
      source: PaletteSource.platform,
    );
  }

  const PlatformPalette._({
    required this.primaryColor,
    required this.secondaryColor,
    required this.tertiaryColor,
    required this.colorHints,
    required this.source,
  });

  @Deprecated(
      'The unnamed constructor was deprecated so that the user is explicit about the source when creating an PlatformPalette object!')
  const PlatformPalette({
    required this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.colorHints,
  }) : source = PaletteSource.fallback;

  const PlatformPalette.fallback({
    required this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.colorHints,
  }) : source = PaletteSource.fallback;

  const PlatformPalette.errorHandler({
    required this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.colorHints,
  }) : source = PaletteSource.errorHandler;

  final Color primaryColor;
  final Color? secondaryColor;
  final Color? tertiaryColor;
  final int? colorHints;
  final PaletteSource source;

  /// Specifies that dark text is preferred over the current wallpaper for best
  /// presentation.
  ///
  /// eg. A launcher may set its text color to black if this flag is specified.
  static const int HINT_SUPPORTS_DARK_TEXT = 1;

  /// Specifies that dark theme is preferred over the current wallpaper for best
  /// presentation.
  ///
  /// eg. A launcher may set its drawer color to black if this flag is
  /// specified.
  static const int HINT_SUPPORTS_DARK_THEME = 2;
}
