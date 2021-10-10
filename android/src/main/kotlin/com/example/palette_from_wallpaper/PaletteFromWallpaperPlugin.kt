package com.example.palette_from_wallpaper

import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.StreamHandler
import android.app.Activity
import android.app.WallpaperColors
import android.app.WallpaperManager
import android.app.WallpaperManager.OnColorsChangedListener
import android.os.Build
import android.os.Looper
import android.os.Handler
import android.util.Log

// Producing sensor events on Android.// SensorEventListener/EventChannel adapter.
class WallpaperEventListener(private val activity: () -> Activity) :
  EventChannel.StreamHandler, OnColorsChangedListener {
  private var wallpaperManager: WallpaperManager? = null
  private var eventSink: EventChannel.EventSink? = null

  // EventChannel.StreamHandler methods
  override fun onListen(
    arguments: Any?, eventSink: EventChannel.EventSink?) {
    if (this.wallpaperManager == null) {
      this.wallpaperManager = WallpaperManager.getInstance(activity())
    }
    this.eventSink = eventSink
    registerIfActive()
  }
  override fun onCancel(arguments: Any?) {
    unregisterIfActive()
    eventSink = null
  }

  // OnColorsChangedListener methods.
  override fun onColorsChanged(colors: WallpaperColors?, which: Int) {
    if (which and WallpaperManager.FLAG_SYSTEM != WallpaperManager.FLAG_SYSTEM) {
      Log.w("WallpaperEventListener", "IGNORED");
      return
    }
  
    if (colors == null) {
      return
    }
    eventSink?.success(mapFromColors(colors!!));
    Log.w("WallpaperEventListener", "SUCCESS");
  }

  // Lifecycle methods.
  fun registerIfActive() {
    if (eventSink == null) return
    wallpaperManager!!.addOnColorsChangedListener(
      this,
      Handler(Looper.getMainLooper())
      )
  }

  fun unregisterIfActive() {
    if (eventSink == null) return
    wallpaperManager!!.removeOnColorsChangedListener(this)
  }
}

fun mapFromColors(colors: WallpaperColors): Map<String, Int?> {
  if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
    return mapOf(
      "primaryColor" to colors.primaryColor.toArgb(),
      "secondaryColor" to colors.secondaryColor?.toArgb(),
      "tertiaryColor" to colors.tertiaryColor?.toArgb()
    );
  } else {
    return mapOf(
      "primaryColor" to colors.primaryColor.toArgb(),
      "secondaryColor" to colors.secondaryColor?.toArgb(),
      "tertiaryColor" to colors.tertiaryColor?.toArgb(),
      "colorHints" to colors.colorHints
    );
  }

}

/** PaletteFromWallpaperPlugin */
class PaletteFromWallpaperPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var eventChannel : EventChannel
  private var activity: Activity? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "package:palette_from_wallpaper/method")
    channel.setMethodCallHandler(this)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "package:palette_from_wallpaper/events")
    eventChannel.setStreamHandler(WallpaperEventListener({->activity!!}))
  }

  fun preO_MR1GetPaletteMap(): Map<String, Int?> {
    return mapOf(
    );
  }

  fun currGetPaletteMap(): Map<String, Int?> {
    var wallpaperManager = WallpaperManager.getInstance(activity!!);
    var wallpaperColors = wallpaperManager.getWallpaperColors(WallpaperManager.FLAG_SYSTEM)!!
    return mapFromColors(wallpaperColors);
  }

   fun getPaletteMap(): Map<String, Int?> {
    if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O_MR1) {
      return preO_MR1GetPaletteMap();
    } else {
      return currGetPaletteMap();
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "getPalette") {
      try {
        result.success(getPaletteMap())
      } catch ( e: Exception) {
        result.error("UNAVAILABLE_PALLETE", "No palette available!", null)
      }
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(@NonNull binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity();
  }

  override fun onReattachedToActivityForConfigChanges(@NonNull binding: ActivityPluginBinding) {
    onAttachedToActivity(binding);
  }
}
