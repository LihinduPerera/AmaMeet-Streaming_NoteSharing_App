import 'package:ama_meet_admin/models/class_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YouTubePlayerScreen extends StatefulWidget {
  final ClassVideo video;
  const YouTubePlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<YouTubePlayerScreen> createState() => _YouTubePlayerScreenState();
}

class _YouTubePlayerScreenState extends State<YouTubePlayerScreen>
    with WidgetsBindingObserver {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Extract video ID from YouTube URL
    final videoId = YoutubePlayer.convertUrlToId(widget.video.url);
    
    if (videoId == null) {
      // Handle error case
      return;
    }

    _controller = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
        enableCaption: true,
        captionLanguage: 'en',
        forceHD: false,
        loop: false,
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Reset orientation when leaving
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        return true;
      },
      child: YoutubePlayerBuilder(
        onExitFullScreen: () {
          SystemChrome.setPreferredOrientations([
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
          ]);
        },
        player: YoutubePlayer(
          controller: _controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: Colors.red,
          topActions: <Widget>[
            const SizedBox(width: 8.0),
            Expanded(
              child: Text(
                widget.video.filename,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 25.0,
              ),
              onPressed: () {
                // You can implement settings dialog here
              },
            ),
          ],
          onReady: () {
            setState(() {
              _isPlayerReady = true;
            });
          },
          onEnded: (data) {
            // Handle video end
          },
        ),
        builder: (context, player) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              widget.video.filename,
              style: const TextStyle(fontSize: 16),
            ),
            elevation: 0,
            actions: [
              if (widget.video.youtubePrivacyStatus != null)
                Container(
                  margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getPrivacyColor(widget.video.youtubePrivacyStatus!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.video.youtubePrivacyStatus!.name.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          body: Column(
            children: [
              player,
              Expanded(
                child: Container(
                  color: Colors.black,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.video.sectionTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Uploaded: ${DateTime.fromMillisecondsSinceEpoch(widget.video.uploadedAt).toString().split('.')[0]}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.play_arrow,
                            color: Colors.red,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "YouTube Video",
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      if (widget.video.youtubePrivacyStatus != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              _getPrivacyIcon(widget.video.youtubePrivacyStatus!),
                              color: _getPrivacyColor(widget.video.youtubePrivacyStatus!),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "Privacy: ${widget.video.youtubePrivacyStatus!.name.toUpperCase()}",
                              style: TextStyle(
                                color: _getPrivacyColor(widget.video.youtubePrivacyStatus!),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPrivacyColor(YouTubePrivacyStatus status) {
    switch (status) {
      case YouTubePrivacyStatus.public:
        return Colors.green;
      case YouTubePrivacyStatus.private:
        return Colors.red;
      case YouTubePrivacyStatus.unlisted:
        return Colors.orange;
    }
  }

  IconData _getPrivacyIcon(YouTubePrivacyStatus status) {
    switch (status) {
      case YouTubePrivacyStatus.public:
        return Icons.public;
      case YouTubePrivacyStatus.private:
        return Icons.lock;
      case YouTubePrivacyStatus.unlisted:
        return Icons.link;
    }
  }
}