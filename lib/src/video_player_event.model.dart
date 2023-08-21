part of video_player_oneplusdream;

const TOGGLE_FULL_SCREEEN = "toggleFullScreen";
const ON_BACK_CLICKED = "onBack";
const ON_PLAYING = "onPlaying";
const ON_LOAD_ERROR = "onLoadError";
const ON_VOLUME_CHANGE = "onVolumeChange";
const RELEASE = "release";

class BackEvent extends VideoEvent<void> {
  BackEvent(int videoId) : super(videoId, null);
}

class PlayingEvent extends VideoEvent<PlayingEventDetail> {
  PlayingEvent(int videoId, PlayingEventDetail event) : super(videoId, event);
}

class LoadErrorEvent extends VideoEvent<String> {
  LoadErrorEvent(int videoId, String error) : super(videoId, error);
}

class VolumeChangeEvent extends VideoEvent<VolumeChangeEventDetail> {
  VolumeChangeEvent(
      int videoId, VolumeChangeEventDetail volumeChangeEventDetail)
      : super(videoId, volumeChangeEventDetail);
}

class PlayingEventDetail {
  PlayingItem item;
  PlayingStatus? status;
  num? currentPosition;
  PlayingEventDetail(this.item, this.status, this.currentPosition);
  factory PlayingEventDetail.fromJson(json) {
    return PlayingEventDetail(PlayingItem.fromJson(json["item"]),
        parsePlayingStatus(json["status"]), json['currentPosition']);
  }
  Map<String, dynamic> toJson() => {
        'item': item.toJson(),
        'status': status?.name,
        'currentPosition': currentPosition,
      };
}

class VolumeChangeEventDetail {
  double volume;
  bool isMuted;
  VolumeChangeEventDetail(this.volume, this.isMuted);
  factory VolumeChangeEventDetail.fromJson(json) {
    return VolumeChangeEventDetail(json["volume"], json["muted"]);
  }
  Map<String, dynamic> toJson() => {
        'volume': volume,
        'muted': isMuted,
      };
}

enum PlayingStatus {
  start,
  pause,
  play,
  end,
  error,
  release,
}

final playingStatuses = [
  PlayingStatus.start,
  PlayingStatus.pause,
  PlayingStatus.play,
  PlayingStatus.end,
  PlayingStatus.error,
  PlayingStatus.release
];

PlayingStatus? parsePlayingStatus(int v) {
  return v <= playingStatuses.length - 1 ? playingStatuses[v] : null;
}

class VideoEvent<T> {
  VideoEvent(this.videoId, this.value);
  final int videoId;
  final T value;
}

class ToggleFullScreenParam {
  bool isFullScreen;
  ToggleFullScreenParam({this.isFullScreen = true});

  Map<String, dynamic> toJson() => {
        'isFullScreen': isFullScreen,
      };
}
