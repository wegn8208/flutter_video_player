import '../video_player_oneplusdream.dart';
import '../video_player_oneplusdream_platform_interface.dart';

class MobileVideoPlayerController implements VideoPlayerController {
  /// The videoId for this controller
  int _videoId = -1;
  VideoPlayerOnePlusDreamState? _videoPlayerState;

  @override
  Future<void> init(
    int videoId,
    VideoPlayerOnePlusDreamState videoPlayerState,
  ) async {
    _videoId = videoId;
    _videoPlayerState = videoPlayerState;
    await VideoPlayerOneplusdreamPlatform.instance.init(_videoId);
    _connectStreams(_videoId);
  }

  void _connectStreams(int videoId) {
    if (_videoPlayerState?.widget.onBack != null) {
      VideoPlayerOneplusdreamPlatform.instance
          .onBack(videoId: videoId)
          .listen((_) => _videoPlayerState?.widget.onBack!());
    }
    if (_videoPlayerState?.widget.onPlaying != null) {
      VideoPlayerOneplusdreamPlatform.instance
          .onPlaying(videoId: videoId)
          .listen((e) => _videoPlayerState?.widget.onPlaying!(e.value));
    }
  }

  Future<void> play(PlayingItem item) {
    return VideoPlayerOneplusdreamPlatform.instance.play(_videoId, item);
  }

  Future<void> toggleFullScreen(ToggleFullScreenParam param) {
    return VideoPlayerOneplusdreamPlatform.instance
        .toggleFullScreen(_videoId, param);
  }

  Future<void> togglePause(bool isPause) {
    return VideoPlayerOneplusdreamPlatform.instance
        .togglePause(_videoId, isPause);
  }

  /// Disposes of the platform resources
  void dispose() {
    VideoPlayerOneplusdreamPlatform.instance.dispose(videoId: _videoId);
  }
}

VideoPlayerController createVideoController() => MobileVideoPlayerController();
