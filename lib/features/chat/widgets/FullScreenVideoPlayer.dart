import 'dart:async';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenVideoPlayer extends StatefulWidget {
  static const String routeName = '/full-screen-video';
  final String videoUrl;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoUrl, required bool initialPlayState,
  }) : super(key: key);

  @override
  _FullScreenVideoPlayerState createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late CachedVideoPlayerController videoPlayerController;
  bool isPlay = false;
  bool showControls = true;
  late Timer _hideControlsTimer;
  bool isLandscape = false;

  @override
  void initState() {
    super.initState();
    videoPlayerController = CachedVideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          isPlay = true; // Start playing by default
          videoPlayerController.play();
        });
      });

    videoPlayerController.addListener(() {
      if (!videoPlayerController.value.isPlaying && isPlay) {
        setState(() {
          isPlay = false;
        });
      } else if (videoPlayerController.value.isPlaying && !isPlay) {
        setState(() {
          isPlay = true;
        });
      }
    });

    _startHideControlsTimer();
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    _hideControlsTimer.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (isPlay) {
        videoPlayerController.pause();
      } else {
        videoPlayerController.play();
      }
      isPlay = !isPlay;
    });
    _resetHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        showControls = false;
      });
    });
  }

  void _resetHideControlsTimer() {
    _hideControlsTimer.cancel();
    setState(() {
      showControls = true;
    });
    _startHideControlsTimer();
  }

  void _toggleOrientation() {
    setState(() {
      isLandscape = !isLandscape;
      if (isLandscape) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            showControls = !showControls;
          });
          _resetHideControlsTimer();
        },
        onHorizontalDragUpdate: (details) {
          final position = details.localPosition.dx;
          final screenWidth = MediaQuery.of(context).size.width;
          final value = position / screenWidth;
          final newPosition = value * videoPlayerController.value.duration.inMilliseconds;
          videoPlayerController.seekTo(Duration(milliseconds: newPosition.toInt()));
          _resetHideControlsTimer();
        },
        child: Center(
          child: AspectRatio(
            aspectRatio: videoPlayerController.value.isInitialized
                ? videoPlayerController.value.aspectRatio
                : 16 / 9,
            child: Stack(
              children: [
                CachedVideoPlayer(videoPlayerController),
                if (showControls)
                  Align(
                    alignment: Alignment.center,
                    child: IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        isPlay ? Icons.pause_circle : Icons.play_circle,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                if (showControls)
                  Positioned(
                    top: 40,
                    left: 20,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                if (showControls)
                  Positioned(
                    bottom: 20,
                    left: 0,
                    right: 0,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(videoPlayerController.value.position),
                              style: const TextStyle(color: Colors.white),
                            ),
                            IconButton(
                              icon: Icon(
                                isLandscape ? Icons.fullscreen_exit : Icons.fullscreen,
                                color: Colors.white,
                              ),
                              onPressed: _toggleOrientation,
                            ),
                          ],
                        ),
                        Slider(
                          value: videoPlayerController.value.position.inMilliseconds.toDouble().clamp(
                            0.0,
                            videoPlayerController.value.duration.inMilliseconds.toDouble(),
                          ),
                          min: 0.0,
                          max: videoPlayerController.value.duration.inMilliseconds.toDouble(),
                          onChanged: (value) {
                            videoPlayerController.seekTo(Duration(milliseconds: value.toInt()));
                            _resetHideControlsTimer();
                          },
                        ),
                        Text(
                          _formatDuration(videoPlayerController.value.duration),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
