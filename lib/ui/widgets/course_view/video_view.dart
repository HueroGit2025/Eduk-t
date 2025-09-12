import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoView extends StatefulWidget {
  final String url;
  const VideoView({super.key, required this.url});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {


    if (_videoController == null || _videoController!.dataSource != widget.url) {
      _videoController?.dispose();
      _chewieController?.dispose();

      _videoController = VideoPlayerController.network(widget.url);
      _videoController!.initialize().then((_) {
        _chewieController = ChewieController(
          videoPlayerController: _videoController!,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          allowMuting: true,
          showControls: true,
        );
        setState(() {});
      });
    }

    return _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
        ? Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 70, left: 30, right: 30),
        child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Chewie(controller: _chewieController!)
        ),
      ),
    )
        : const Center(child: CircularProgressIndicator());
  }
}
