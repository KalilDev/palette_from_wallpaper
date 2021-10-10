import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'plugin.dart';

/// Runs the app with an injected [InheritedPalette] at the root of the tree, so
/// that an [PlatformPalette] is always available.
///
/// * On initialization
/// In case the [initialOrFallback] is defined and [startEagerly] is true, the
/// app will be started with the [initialOrFallback] palette, and switch to the
/// platform result once ready.
///
/// In case the [startEagerly] is false, the palette will be retrieved, and only
/// then runApp will be called. [onError] becomes required, and
/// [initialOrFallback] will be used if provided and the platform returns null.
///
/// * On updates
/// If the stream emits an [PlatformPalette], it will be used. If the stream
/// emits an error, [onUpdateError] will be called, if specified, and the result
/// will be used as the new palette, and if the result is null, the palette will
/// not change. If [onUpdateError] is not defined, the palette will not change.
void runPlatformThemedApp(
  Widget home, {
  PlatformPalette Function()? initialOrFallback,
  PlatformPalette Function(PlatformException)? onError,
  PlatformPalette? Function(PlatformException)? onUpdateError,
  bool startEagerly = false,
}) async {
  if (startEagerly) {
    ArgumentError.checkNotNull(initialOrFallback);
  }
  WidgetsFlutterBinding.ensureInitialized();
  if (initialOrFallback == null || !startEagerly) {
    ArgumentError.checkNotNull(onError);
    return PaletteFromWallpaper.getPalette(nullOk: initialOrFallback != null)
        .onError<MissingPluginException>(
            (e, s) => throw PlatformException(code: 'MISSING_IMPLEMENTATION'))
        .onError<PlatformException>((error, stackTrace) => onError!(error))
        .then((palette) => _PaletteApp(
              home: home,
              palette: palette ?? initialOrFallback!(),
              onUpdateError: onUpdateError,
            ))
        .then(runApp);
  }
  return runApp(_PaletteApp(
    home: home,
    palette: initialOrFallback(),
    onUpdateError: onUpdateError,
    maybeFuturePalette: PaletteFromWallpaper.getPalette()
        .onError<MissingPluginException>(
            (e, s) => throw PlatformException(code: 'MISSING_IMPLEMENTATION'))
        .onError<PlatformException>((e, s) => onError?.call(e))
        .then((value) => value ?? initialOrFallback()),
  ));
}

class _PaletteApp extends StatefulWidget {
  final Widget home;
  final PlatformPalette palette;
  final Future<PlatformPalette>? maybeFuturePalette;
  final PlatformPalette? Function(PlatformException)? onUpdateError;
  const _PaletteApp({
    Key? key,
    required this.home,
    required this.palette,
    this.onUpdateError,
    this.maybeFuturePalette,
  }) : super(key: key);

  @override
  _PaletteAppState createState() => _PaletteAppState();
}

class _PaletteAppState extends State<_PaletteApp> {
  late PlatformPalette palette;
  StreamSubscription? subscription;
  void initState() {
    super.initState();
    palette = widget.palette;

    if (widget.maybeFuturePalette != null) {
      _initWithFuture();
      return;
    }
    _initSubscription();
  }

  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  void _initWithFuture() async {
    try {
      final palette = await widget.maybeFuturePalette!;
      _onUpdate(palette);
    } finally {
      _initSubscription();
    }
  }

  void _onUpdate(PlatformPalette palette) {
    if (!mounted) {
      return;
    }
    if (palette == this.palette) {
      return;
    }
    setState(() => this.palette = palette);
  }

  void _initSubscription() {
    if (!mounted) {
      return;
    }
    try {
      subscription = PaletteFromWallpaper.paletteUpdates
          .cast<PlatformPalette?>()
          .handleError(
              (e, s) => throw PlatformException(code: 'MISSING_IMPLEMENTATION'),
              test: (e) => e is MissingPluginException)
          .handleError((Object error) =>
              widget.onUpdateError?.call(error as PlatformException))
          .where((event) => event != null)
          .cast<PlatformPalette>()
          .listen(_onUpdate);
    } on PlatformException catch (e) {
      widget.onUpdateError?.call(e);
    } on MissingPluginException {
      widget.onUpdateError
          ?.call(PlatformException(code: 'MISSING_IMPLEMENTATION'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return InheritedPalette(palette, widget.home);
  }
}

class InheritedPalette extends InheritedWidget {
  final PlatformPalette palette;

  InheritedPalette(this.palette, Widget child) : super(child: child);

  static PlatformPalette of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedPalette>()!.palette;

  @override
  bool updateShouldNotify(InheritedPalette oldWidget) =>
      palette != oldWidget.palette;
}

extension ContextE on BuildContext {
  PlatformPalette get palette => InheritedPalette.of(this);
}
