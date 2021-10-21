# Palette From Wallpaper

An Flutter plugin for fetching an palette from the device wallpaper on Android
using the native [android.app.WallpaperManager.getWallpaperColors](https://developer.android.com/reference/android/app/WallpaperManager#getWallpaperColors(int))
and [android.app.WallpaperManager.OnColorsChangedListener](https://developer.android.com/reference/android/app/WallpaperManager.OnColorsChangedListener)
apis.

It is exposed in the `PaletteFromWallpaper.getPalette` method, and has an
Stream counterpart for the next `PlatformPalette`s in the
`PaletteFromWallpaper.paletteUpdates` field.

The functionality is also exposed in a more Fluttery api via the
`runPlatformThemedApp` function, which when called instead of `runApp`, inserts
an `InheritedPalette` on the root of the tree, and subscribes to the
`paletteUpdates` stream, always propagating the new palettes to the tree via
`BuildContext.dependOnInheritedWidgetOfExactType`, so that the app always use
the most up to date colors from the user wallpaper.

## Example

Checkout the [Example app](example/README.md)
