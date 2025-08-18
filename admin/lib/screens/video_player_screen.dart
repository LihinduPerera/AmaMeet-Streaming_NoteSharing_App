import 'package:ama_meet_admin/models/class_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = VlcPlayerController.network(
      widget.video.url,
      autoPlay: true,
      options: VlcPlayerOptions(),
    );
  }

  @override
  void dispose() {
    _isDisposed = true;
    WidgetsBinding.instance.removeObserver(this);
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
            child: VlcPlayer(
              controller: _controller,
              aspectRatio: 16 / 9,
              placeholder: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}