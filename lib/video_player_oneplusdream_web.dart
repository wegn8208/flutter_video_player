// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html;
import 'dart:js';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:rxdart/rxdart.dart';

import 'video_player_oneplusdream.dart';
import 'video_player_oneplusdream_platform_interface.dart';
import 'dart:js' as js;

bool _imported = false;

/// A web implementation of the VideoPlayerOneplusdreamPlatform of the VideoPlayerOneplusdream plugin.
class VideoPlayerOneplusdreamWeb extends VideoPlayerOneplusdreamPlatform {
  dynamic player;
  final List<String> scripts = [
    "packages/video_player_oneplusdream/lib/assets/videojs_playlist.min.js",
    "packages/video_player_oneplusdream/lib/assets/controller.js"
  ];

  Future<void> importJSFile(String library) async {
    final head = html.querySelector('head');
    if (library.endsWith('.js')) {
      await _createScriptTag(library, head: head);
    } else if (library.endsWith('.css')) {
      await _createCssLinkTag(library, head: head);
    }
  }

  Future<void> _createScriptTag(String library, {html.Element? head}) async {
    late html.ScriptElement script;
    if (library.startsWith('http')) {
      script = html.ScriptElement()
        ..type = "text/javascript"
        ..charset = "utf-8"
        ..async = true
        ..src = library;
    } else {
      var val = await rootBundle.loadString(library);
      script = html.ScriptElement()
        ..type = "text/javascript"
        ..charset = "utf-8"
        ..async = true
        ..text = val;
    }
    head?.children.add(script);
  }

  Future<void> _createCssLinkTag(String library, {html.Element? head}) async {
    if (library.startsWith('http')) {
      var link = html.LinkElement()
        ..rel = "stylesheet"
        ..href = library;
      head?.children.add(link);
    } else {
      var val = await rootBundle.loadString(library);
      final html.StyleElement ele = html.StyleElement()..text = val;
      head?.children.add(ele);
    }
  }

  @override
  Future<void> toggleFullScreen(
      int videoId, ToggleFullScreenParam param) async {
    print('oneplusdream $videoId toggleFullScreen ${param.isFullScreen}');
    final _videoElement = html.document.getElementById('video_$videoId');
    final _player = _videoElement == null
        ? player
        : js.context.callMethod('videojs', [
            _videoElement,
          ]);
    JsFunction func = _player['requestFullscreen'];
    func.apply([], thisArg: _player);
  }

  @override
  Future<void> play(int videoId, PlayingItem item) async {
    print('oneplusdream $videoId play ${item.url}');
    final _videoElement = html.document.getElementById('video_$videoId');
    final _player = _videoElement == null
        ? player
        : js.context.callMethod('videojs', [
            _videoElement,
          ]);

    JsFunction func = _player['src'];
    func.apply([
      js.JsObject.jsify({"src": item.url}),
    ], thisArg: _player);
    if ((item.position ?? 0) > 0) {
      JsFunction setCurrentTime = _player['currentTime'];
      setCurrentTime.apply([item.position], thisArg: _player);
    }
    JsFunction setTitle = _player['updateTitleFunc'];
    setTitle.apply([item.title], thisArg: _player);
  }

  @override
  Future seek(int videoId, int position) async {
    // print('oneplusdream $videoId play ${item.url}');
    // JsFunction func = player['seek'];
    // func.apply([
    // js.JsObject.jsify({"src": item.url}),
    // ], thisArg: player);
    if ((position ?? 0) > 0) {
      final _videoElement = html.document.getElementById('video_$videoId');
      final _player = _videoElement == null
          ? player
          : js.context.callMethod('videojs', [
              _videoElement,
            ]);
      JsFunction setCurrentTime = _player['currentTime'];
      setCurrentTime.apply([position], thisArg: _player);
    }
  }

  @override
  Future<int> currentPosition(int videoId) async {
    final _videoElement = html.document.getElementById('video_$videoId');
    final _player = _videoElement == null
        ? player
        : js.context.callMethod('videojs', [
            _videoElement,
          ]);
    JsFunction getCurrentTime = _player['currentTime'];
    final position = getCurrentTime.apply([], thisArg: _player);
    return position.toInt();
  }

  @override
  Future<void> togglePause(int videoId, bool isPause) async {
    final _videoElement = html.document.getElementById('video_$videoId');
    final _player = _videoElement == null
        ? player
        : js.context.callMethod('videojs', [
            _videoElement,
          ]);

    if (isPause) {
      JsFunction func = _player['pause'];
      func.apply([], thisArg: _player);
    } else {
      JsFunction func = _player['play'];
      func.apply([], thisArg: _player);
    }
  }

  @override
  Future<void> dispose({required int videoId}) async {
    print('oneplusdream $videoId dispose');
    js.context['oneplusdreamOnPlayerListen_$videoId'] = null;
  }

  final StreamController<VideoEvent<Object?>> _videoEventStreamController =
      StreamController<VideoEvent<Object?>>.broadcast();

  Stream<VideoEvent<Object?>> _events(int videoId) =>
      _videoEventStreamController.stream
          .where((VideoEvent<Object?> event) => event.videoId == videoId);

  @override
  Stream<BackEvent> onBack({required int videoId}) {
    return _events(videoId).whereType<BackEvent>();
  }

  @override
  Stream<PlayingEvent> onPlaying({required int videoId}) {
    return _events(videoId).whereType<PlayingEvent>();
  }

  @override
  Future<void> init(int videoId) async {
    print('oneplusdream $videoId init');
    js.context['oneplusdreamOnPlayerListen_$videoId'] = (method, arguments) {
      try {
        switch (method) {
          case ON_BACK_CLICKED:
            print('oneplusdream $videoId on back clicked');
            _videoEventStreamController.add(BackEvent(videoId));
            break;
          case ON_PLAYING:
            print('oneplusdream $videoId on playing $arguments');
            _videoEventStreamController.add(
                PlayingEvent(videoId, PlayingEventDetail.fromJson(arguments)));
            break;
          default:
            print('oneplusdream $videoId method not implemented');
            throw MissingPluginException();
        }
      } catch (e) {
        print("event error: $e");
      }
    };
  }

  void initPlayer(int videoId, Map<String, dynamic> params) async {
    if (!_imported) {
      for (var srcipt in scripts) {
        await importJSFile(srcipt);
      }
      _imported = true;
    }
    player = js.context.callMethod('videojs', [
      html.document.getElementById('video_$videoId'),
      js.JsObject.jsify({
        "fill": true,
        "responsive": true,
        "controls": !(params['hideControls'] ?? false),
        "autoplay": params['autoPlay'] ?? true,
        "preload": params['preload'] ?? true,
        "poster": params["posterImage"],
        "playbackRates": [0.5, 1, 1.25, 1.5, 2],
        "muted": params["muted"],
        "normalizeAutoplay": true,
        "playsinline": params["playsinline"],
      })
    ]);

    js.context.callMethod('oneplusdreamInitialPlayer',
        [player, js.JsObject.jsify(params), videoId]);
  }

  static void registerWith(Registrar registrar) {
    VideoPlayerOneplusdreamPlatform.instance = VideoPlayerOneplusdreamWeb();
  }

  @override
  Widget buildView(
    int creationId,
    PlatformViewCreatedCallback onPlatformViewCreated, {
    Map<String, dynamic> params = const <String, dynamic>{},
  }) {
    print('oneplusdream $creationId buildView');
    return HtmlElementView(
      viewType: 'video_$creationId',
      onPlatformViewCreated: (id) {
        initPlayer(creationId, params);
      },
    );
  }
}
