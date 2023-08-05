import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player_oneplusdream/video_player_oneplusdream.dart';
import 'package:video_player_oneplusdream_example/cache.dart';

import 'first.dart';

class HomeRoute extends StatelessWidget {
  HomeRoute({super.key});
  VideoPlayerController controller = createVideoController();
  List<PlayingItem> items = [
    PlayingItem(
      id: '1',
      url: "https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8",
      title: "Rabbit",
      position: 20.0,
    ),
    // PlayingItem(
    //   id: '3',
    //   url:
    //       "https://d305e11xqcgjdr.cloudfront.net/stories/ee09c3b8-5b0c-4aff-b1fe-58f175328850/2.mp4",
    //   title: "Rabbit 3",
    // ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 300,
                child: VideoPlayerOnePlusDream(
                  items,
                  controller: controller,
                  enableMarquee: true,
                  enablePreventScreenCapture: true,
                  marqueeText: "Marquee",
                  autoPlay: true,
                  hideControls: false,
                  onPlaying: (event) {
                    print(
                        "status ${event.status} position: ${event.currentPosition}");
                    print("onPlaying ${event.item.url}");
                  },
                ),
              ),
              ElevatedButton(
                  onPressed: () async {
                    controller.togglePause(true);
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CacheRoute()),
                    );
                    await controller.togglePause(false);
                  },
                  child: const Text("go to cache page")),
              ElevatedButton(
                  onPressed: () async {
                    controller.togglePause(true);
                    print("pause to navigate into new page");
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => FirstRoute()),
                    );
                    print("back and play again");
                    await controller.togglePause(false);
                  },
                  child: const Text("go to new page")),
              ElevatedButton(
                  onPressed: () {
                    controller.toggleFullScreen(
                        ToggleFullScreenParam(isFullScreen: true));
                  },
                  child: const Text("open full screen")),
              ElevatedButton(
                  onPressed: () {
                    VideoPlayerGlobal().clearAllCache();
                  },
                  child: const Text("clear All Cache"))
            ],
          ),
        ),
      ),
    );
  }
}
