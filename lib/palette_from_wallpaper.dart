// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaletteFromWallpaper {
  static const MethodChannel _methodChannel =
      MethodChannel('palette_from_wallpaper');

  static const EventChannel _eventChannel = EventChannel('UPDATES');

  static final Stream<PlatformPalette> paletteUpdates = _eventChannel
      .receiveBroadcastStream()
      .map((event) => PlatformPalette._fromMap(event as Map<dynamic, dynamic>));

  /// Get the [PlatformPalette] from the native implementation
  static Future<PlatformPalette?> getPalette() async {
    final paletteMap =
        await _methodChannel.invokeMethod<Map<dynamic, dynamic>>('getPalette');
    if (paletteMap == null) {
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

class PlatformPalette {
  factory PlatformPalette._fromMap(Map<dynamic, dynamic> map) {
    final primary = map['primaryColor'] as int;
    final secondary = map['secondaryColor'] as int?;
    final tertiary = map['tertiaryColor'] as int?;
    final colorHints = map['colorHints'] as int?;
    return PlatformPalette(
      primaryColor: Color(primary),
      secondaryColor: secondary == null ? null : Color(secondary),
      tertiaryColor: tertiary == null ? null : Color(tertiary),
      colorHints: colorHints,
    );
  }

  const PlatformPalette({
    required this.primaryColor,
    this.secondaryColor,
    this.tertiaryColor,
    this.colorHints,
  });
  final Color primaryColor;
  final Color? secondaryColor;
  final Color? tertiaryColor;
  final int? colorHints;

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
