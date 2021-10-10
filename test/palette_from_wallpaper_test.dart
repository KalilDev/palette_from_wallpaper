import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:palette_from_wallpaper/palette_from_wallpaper.dart';

void main() {
  const MethodChannel channel =
      MethodChannel('package:palette_from_wallpaper/method');
  const EventChannel eventChannel =
      EventChannel('package:palette_from_wallpaper/events');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });
}
