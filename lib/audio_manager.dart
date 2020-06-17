import 'dart:async';
import 'package:flutter/services.dart';

export 'package:audio_manager/src/AudioInfo.dart';
export 'package:audio_manager/src/AudioType.dart';

class AudioManagerSimple {
  static const MethodChannel _channel = const MethodChannel('audio_manager');
  static Map<String, Function> _listeners = new Map();

  static Future<dynamic> _utilsHandler(MethodCall methodCall) async {
    _listeners.forEach((event, callback) {
      if (methodCall.method == event) {
        callback();
      }
    });
  }

  static Future showNotification(
      {bool hasNext = false,
      bool hasPrev = false,
      bool buffering = false}) async {
    try {
      _channel.setMethodCallHandler(_utilsHandler);
      await _channel.invokeListMethod("show",
          {"hasNext": hasNext, "hasPrev": hasPrev, "buffering": buffering});
    } catch (error) {
      print("Failed to play on iOS: ${error.message}");
    }
  }

  static Future hide() async {
    try {
      _channel.setMethodCallHandler(_utilsHandler);
      await _channel.invokeListMethod("hide");
    } catch (error) {
      print("Failed to play on iOS: ${error.message}");
    }
  }

  static Future play(
      {String url,
      bool hasNext = false,
      bool hasPrev = false,
      String imageUrl}) async {
    try {
      _channel.setMethodCallHandler(_utilsHandler);
      await _channel.invokeListMethod("start", {
        "url": url,
        "hasNext": hasNext,
        "hasPrev": hasPrev,
        "imageUrl": imageUrl
      });
    } catch (error) {
      print("Failed to play on iOS: ${error.message}");
    }
  }

  static Future updateInfo(
      {String title, String artist, int duration, int currentPosition}) async {
    try {
      await _channel.invokeListMethod("updateInfo", {
        "title": title,
        "artist": artist,
        "duration": duration,
        "currentPosition": currentPosition
      });
    } catch (error) {
      print("Failed to update info on iOS: ${error.message}");
    }
  }

  static stop() {
    _channel.invokeMethod('stop');
  }

  static resume() async {
    try {
      await _channel.invokeMethod('resume');
    } on PlatformException catch (e) {
      print("Failed to resume on iOS: '${e.message}'.");
    }
  }

  static pause() async {
    try {
      await _channel.invokeMethod('pause');
    } on PlatformException catch (e) {
      print("Failed to pause on iOS: '${e.message}'.");
    }
  }

  static setListener(String event, Function callback) {
    _listeners.addAll({event: callback});
  }
}
