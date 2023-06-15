import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({required this.videoUrl});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  double _progress = 0.0;
  double _initialPosition = 0.0;
  IconData _playPauseIcon = Icons.play_arrow;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
          _controller.play();
        });
      });
    _controller.addListener(() {
      setState(() {
        _progress = _controller.value.position.inMilliseconds /
            _controller.value.duration.inMilliseconds;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onScrubStart(DragStartDetails details) {
    _controller.pause();
    _initialPosition = _progress;
  }

  void _onScrubUpdate(DragUpdateDetails details) {
    final RenderBox? box = context.findRenderObject() as RenderBox?;
    final height = box?.size.height ?? 0;

    final videoDuration = _controller.value.duration;
    final currentDuration = _controller.value.position;

    final distance = details.delta.dy;
    final maxSkip = videoDuration.inMilliseconds ~/
        5; // Adjust the division factor to control the initial skip increment

    final scaleFactor = .015 +
        (distance.abs() /
            height *
            0.01); // Adjust first number the factor to control the speed increase
    final skipMilliseconds = (maxSkip * scaleFactor).toInt();
    final skipDuration = Duration(milliseconds: skipMilliseconds);

    Duration scrubPosition;

    if (distance.isNegative) {
      scrubPosition = currentDuration - skipDuration;
    } else {
      scrubPosition = currentDuration + skipDuration;
    }

    if (scrubPosition < Duration.zero) {
      scrubPosition = Duration.zero;
    } else if (scrubPosition > videoDuration) {
      scrubPosition = videoDuration;
    }

    _controller.seekTo(scrubPosition);

    _controller.play();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _togglePlayPause,
        onVerticalDragStart: _onScrubStart,
        onVerticalDragUpdate: _onScrubUpdate,
        child: Center(
          child: AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: 4.0,
                    color: Colors.red.withOpacity(0.25),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: _progress,
                      child: Container(
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  @override
  void deactivate() {
    // Re-enable system overlays when the screen is deactivated
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.deactivate();
  }
}
