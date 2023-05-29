part of video_player_oneplusdream;

class VideoPlayerGlobal {
  /// private constructor
  static final VideoPlayerGlobal _instance = VideoPlayerGlobal._internal();
  MethodChannel? _methodChannel;

  // using a factory is important
  // because it promises to return _an_ object of this type
  // but it doesn't promise to make a new one.
  factory VideoPlayerGlobal() {
    return _instance;
  }

  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  VideoPlayerGlobal._internal() {
    // initialization logic
    if (!kIsWeb) {
      _methodChannel = const MethodChannel('oneplusdream/global_channel');
    }
  }

  Future<void> cachePlayingItems(List<String> urls,
      {bool concurrent = true}) async {
    return _methodChannel?.invokeMethod("cache", {
      "urls": urls,
      "concurrent": concurrent,
    });
  }

  Future<void> cancelCache(List<String> urls) async {
    return _methodChannel?.invokeMethod("cancelCache", urls);
  }

  Future<void> clearAllCache() async {
    return _methodChannel?.invokeMethod("clearAllCache");
  }
}
