import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PlatformPalette? _platformPalette;
  Object? error;
  StreamSubscription? subscription;

  void dispose() {
    subscription?.cancel();
  }

  void _onPlatformUpdate(PlatformPalette palette) {
    if (!mounted) {
      return;
    }
    setState(() => _platformPalette = palette);
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    PlatformPalette? platformPalette;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformPalette = await PaletteFromWallpaper.getPalette();
    } on PlatformException catch (e) {
      error = e;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
    subscription =
        PaletteFromWallpaper.paletteUpdates.listen(_onPlatformUpdate);

    setState(() {
      _platformPalette = platformPalette;
    });
  }

  Widget square(Color? color) => Expanded(
        child: AspectRatio(
          aspectRatio: 1,
          child: Container(
            constraints: BoxConstraints.expand(),
            color: color,
            child: color == null ? Text('Unavailable') : null,
          ),
        ),
      );

  Widget palette(BuildContext context) => Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              square(_platformPalette!.primaryColor),
              square(_platformPalette!.secondaryColor),
              square(_platformPalette!.tertiaryColor),
            ],
            mainAxisSize: MainAxisSize.max,
          ),
          if (_platformPalette!.colorHints != null) ...[
            Text('HINT_SUPPORTS_DARK_TEXT: '
                '${_platformPalette!.colorHints! & PlatformPalette.HINT_SUPPORTS_DARK_TEXT}'),
            Text('HINT_SUPPORTS_DARK_THEME: '
                '${_platformPalette!.colorHints! & PlatformPalette.HINT_SUPPORTS_DARK_THEME}'),
          ] else
            Text('No hints available')
        ],
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PaletteFromWallpaper Example'),
        ),
        body: Center(
          child: _platformPalette != null
              ? palette(context)
              : Text(error == null ? 'Loading...' : 'Error: $error'),
        ),
      ),
    );
  }
}
