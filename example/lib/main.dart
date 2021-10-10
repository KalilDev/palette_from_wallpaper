import 'package:flutter/material.dart';
import 'dart:async';

import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';

void main() {
  runPlatformThemedApp(
    MyApp(),
    onError: (e) => PlatformPalette(primaryColor: Colors.red),
    initialOrFallback: () => PlatformPalette(primaryColor: Colors.blue),
    startEagerly: true,
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? subscription;
  final scaffold = GlobalKey<ScaffoldState>();

  void dispose() {
    super.dispose();
    subscription?.cancel();
  }

  void _onPlatformUpdate(PlatformPalette palette) {
    if (!mounted) {
      return;
    }
    scaffold.currentState!
        .showSnackBar(SnackBar(content: Text('Updated theme!')));
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() {
    try {
      subscription =
          PaletteFromWallpaper.paletteUpdates.listen(_onPlatformUpdate);
    } on Object {}
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
              square(context.palette.primaryColor),
              square(context.palette.secondaryColor),
              square(context.palette.tertiaryColor),
            ],
            mainAxisSize: MainAxisSize.max,
          ),
          if (context.palette.colorHints != null) ...[
            Text('HINT_SUPPORTS_DARK_TEXT: '
                '${context.palette.colorHints! & PlatformPalette.HINT_SUPPORTS_DARK_TEXT}'),
            Text('HINT_SUPPORTS_DARK_THEME: '
                '${context.palette.colorHints! & PlatformPalette.HINT_SUPPORTS_DARK_THEME}'),
          ] else
            Text('No hints available')
        ],
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: scaffold,
        appBar: AppBar(
          title: const Text('PaletteFromWallpaper Example'),
          backgroundColor: context.palette.primaryColor,
        ),
        body: Center(
          child: palette(context),
        ),
      ),
    );
  }
}
