import 'package:ama_meet_admin/models/class_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'dart:async';

class VideoPlayerScreen extends StatefulWidget {
  final ClassVideo video;
  const VideoPlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with WidgetsBindingObserver {
  late VlcPlayerController _controller;
  bool _isDisposed = false;
  Timer? _hideTimer;
  bool showControls = true;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  bool isPlaying = false;
  double playbackSpeed = 1.0;
  Map<int, String> subtitleTracks = {};
  Map<int, String> audioTracks = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = VlcPlayerController.network(
      widget.video.url,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );

    _controller.addListener(_updatePlayerState);

    // Fetch tracks after initialization
    _controller.addOnInitListener(() async {
      subtitleTracks = await _controller.getSpuTracks() ?? {};
      audioTracks = await _controller.getAudioTracks() ?? {};
      setState(() {});
    });

    _startHideTimer();
  }

  void _updatePlayerState() {
    if (!_isDisposed && mounted) {
      setState(() {
        position = _controller.value.position;
        duration = _controller.value.duration;
        isPlaying = _controller.value.isPlaying;
        playbackSpeed = _controller.value.playbackSpeed;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    _controller.removeListener(_updatePlayerState);
    _controller.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isDisposed) {
      switch (state) {
        case AppLifecycleState.paused:
        case AppLifecycleState.detached:
          _controller.pause();
          break;
        case AppLifecycleState.resumed:
          // Don't auto-resume, let user control playback
          break;
        default:
          break;
      }
    }
  }

  Future<bool> _onWillPop() async {
    _controller.stop();
    return true;
  }

  void _toggleControls() {
    setState(() {
      showControls = !showControls;
    });
    if (showControls) {
      _startHideTimer();
    } else {
      _hideTimer?.cancel();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          showControls = false;
        });
      }
    });
  }

  void _seekRelative(int seconds) {
    Duration newPosition = position + Duration(seconds: seconds);
    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    } else if (newPosition > duration) {
      newPosition = duration;
    }
    _controller.setTime(newPosition.inMilliseconds);
    // Show controls after seeking
    if (!showControls) {
      _toggleControls();
    }
  }

  void _togglePlay() {
    if (isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  String _formatDuration(Duration d) {
    if (d == Duration.zero) return '0:00';
    int minutes = d.inMinutes;
    int seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: [
            // Playback Speed
            const ListTile(
              title: Text('Playback Speed', style: TextStyle(color: Colors.white)),
            ),
            ...[0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) => ListTile(
                  title: Text('$speed x', style: TextStyle(color: playbackSpeed == speed ? Colors.blue : Colors.white)),
                  onTap: () {
                    _controller.setPlaybackSpeed(speed);
                    Navigator.pop(context);
                  },
                )),
            if (subtitleTracks.isNotEmpty) ...[
              const Divider(color: Colors.white30),
              const ListTile(
                title: Text('Subtitles', style: TextStyle(color: Colors.white)),
              ),
              ...subtitleTracks.entries.map((entry) => ListTile(
                    title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      _controller.setSpuTrack(entry.key);
                      Navigator.pop(context);
                    },
                  )),
            ],
            if (audioTracks.isNotEmpty) ...[
              const Divider(color: Colors.white30),
              const ListTile(
                title: Text('Audio Tracks', style: TextStyle(color: Colors.white)),
              ),
              ...audioTracks.entries.map((entry) => ListTile(
                    title: Text(entry.value, style: const TextStyle(color: Colors.white)),
                    onTap: () {
                      _controller.setAudioTrack(entry.key);
                      Navigator.pop(context);
                    },
                  )),
            ],
          ],
        );
      },
    );
  }

  Widget _buildGestures() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _toggleControls,
            onDoubleTap: () => _seekRelative(-10),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _toggleControls,
            onDoubleTap: () => _seekRelative(10),
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black54,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: _togglePlay,
            ),
            Text(
              _formatDuration(position),
              style: const TextStyle(color: Colors.white),
            ),
            Expanded(
              child: Slider(
                value: duration.inSeconds > 0 ? position.inSeconds.toDouble() : 0,
                min: 0,
                max: duration.inSeconds.toDouble(),
                activeColor: Colors.blue,
                inactiveColor: Colors.white70,
                onChanged: (value) {
                  _controller.setTime(Duration(seconds: value.toInt()).inMilliseconds);
                },
              ),
            ),
            Text(
              _formatDuration(duration),
              style: const TextStyle(color: Colors.white),
            ),
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: _showSettings,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              _controller.stop();
              if (mounted) Navigator.of(context).pop();
            },
          ),
          title: Text(
            widget.video.filename,
            style: const TextStyle(fontSize: 16),
          ),
          elevation: 0,
        ),
        body: Center(
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                VlcPlayer(
                  controller: _controller,
                  aspectRatio: 16 / 9,
                  placeholder: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
                _buildGestures(),
                if (showControls) _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}