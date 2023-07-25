part of video_player_oneplusdream;

typedef OnPlayingCallback = void Function(PlayingEventDetail event);
typedef BackCallback = void Function();

abstract class VideoPlayerController {
  Future<void> init(
    int videoId,
    VideoPlayerOnePlusDreamState videoPlayerState,
  );
  Future<void> play(PlayingItem item);
  Future<void> seek(int position);
  Future<int> currentPosition();
  Future<void> toggleFullScreen(ToggleFullScreenParam param);
  Future<void> togglePause(bool isPause);
  void dispose();
}
