import 'package:ama_meet_admin/models/class_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'dart:async';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class VlcPlayerScreen extends StatefulWidget {
  final ClassVideo video;
  const VlcPlayerScreen({super.key, required this.video});

  @override
  State<VlcPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VlcPlayerScreen>
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
  double _brightness = 0.5;
  double _volume = 1.0;
  bool _showBrightnessOverlay = false;
  bool _showVolumeOverlay = false;
  Timer? _overlayTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WakelockPlus.enable(); // Prevent screen sleep

    _initializeController();
    _fetchInitialBrightness();
  }

  void _initializeController() {
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

  Future<void> _fetchInitialBrightness() async {
    try {
      _brightness = await ScreenBrightness().current;
      setState(() {});
    } catch (e) {
      // Handle error if needed
    }
  }

  void _updatePlayerState() {
    if (!_isDisposed && mounted) {
      setState(() {
        position = _controller.value.position;
        duration = _controller.value.duration;
        isPlaying = _controller.value.isPlaying;
        playbackSpeed = _controller.value.playbackSpeed;
        _volume = _controller.value.volume / 100.0;
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
    _hideTimer?.cancel();
    _overlayTimer?.cancel();
    _controller.removeListener(_updatePlayerState);
    _controller.stop();
    _controller.dispose();
    WakelockPlus.disable(); // Allow screen sleep
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

  void _startOverlayTimer() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _showBrightnessOverlay = false;
          _showVolumeOverlay = false;
        });
      }
    });
  }

  Widget _buildBrightnessOverlay() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.brightness_6, color: Colors.white),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _brightness,
            color: Colors.blue,
            backgroundColor: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeOverlay() {
    IconData volumeIcon = _volume == 0 ? Icons.volume_off : Icons.volume_up;
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(volumeIcon, color: Colors.white),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _volume,
            color: Colors.blue,
            backgroundColor: Colors.white70,
          ),
        ],
      ),
    );
  }

  Widget _buildGestures() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _toggleControls,
            onDoubleTap: () => _seekRelative(-10),
            onVerticalDragStart: (_) {
              setState(() {
                _showBrightnessOverlay = true;
              });
            },
            onVerticalDragUpdate: (details) async {
              double delta = -details.delta.dy / MediaQuery.of(context).size.height;
              double newBrightness = (_brightness + delta).clamp(0.0, 1.0);
              try {
                await ScreenBrightness().setScreenBrightness(newBrightness);
                setState(() {
                  _brightness = newBrightness;
                });
              } catch (e) {}
            },
            onVerticalDragEnd: (_) {
              _startOverlayTimer();
            },
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: _toggleControls,
            onDoubleTap: () => _seekRelative(10),
            onVerticalDragStart: (_) {
              setState(() {
                _showVolumeOverlay = true;
              });
            },
            onVerticalDragUpdate: (details) {
              double delta = -details.delta.dy / MediaQuery.of(context).size.height;
              double newVolume = (_volume + delta).clamp(0.0, 1.0);
              _controller.setVolume((newVolume * 100).toInt());
              setState(() {
                _volume = newVolume;
              });
            },
            onVerticalDragEnd: (_) {
              _startOverlayTimer();
            },
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
                if (_showBrightnessOverlay)
                  Positioned(
                    left: 20,
                    top: MediaQuery.of(context).size.height / 2 - 50,
                    child: _buildBrightnessOverlay(),
                  ),
                if (_showVolumeOverlay)
                  Positioned(
                    right: 20,
                    top: MediaQuery.of(context).size.height / 2 - 50,
                    child: _buildVolumeOverlay(),
                  ),
                if (showControls) _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
