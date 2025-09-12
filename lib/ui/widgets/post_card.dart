import 'package:chewie/chewie.dart';
import 'package:eudkt/resources/colors.dart';
import 'package:eudkt/ui/widgets/profile_avatar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../state_management/theme/theme_cubit.dart';

class PostCard extends StatefulWidget {
  final String text;
  final String? videoUrl;
  final String user;
  final String avatar;
  final String career;
  final String createdAt;

  const PostCard({
    super.key,
    required this.text,
    this.videoUrl,
    required this.user,
    required this.avatar,
    required this.career,
    required this.createdAt,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl != null || widget.videoUrl != '') {
      _controller = VideoPlayerController.network(widget.videoUrl!)
        ..initialize().then((_) {
          setState(() {
            _chewieController = ChewieController(
              videoPlayerController: _controller!,
              autoPlay: false,
              looping: false,
            );
          });
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    final textSpans = widget.text.split(' ').map((word) {
      final isUrl = Uri.tryParse(word)?.hasAbsolutePath ?? false;
      return isUrl
          ? TextSpan(
        text: '$word ',
        style: TextStyle(color: Colors.blue),
        recognizer: TapGestureRecognizer()
          ..onTap = () async {
            final url = Uri.parse(word);
            if (await canLaunchUrl(url)) {
              await launchUrl(url, mode: LaunchMode.externalApplication);
            }
          },
      )
          : TextSpan(text: '$word ');
    }).toList();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      margin: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ProfileAvatarBasic(imageUrl: widget.avatar, size: 40),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        widget.user,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          color: isDark ? light : dark
                        )),
                    Text(
                        '${widget.career} | ${widget.createdAt}',
                        style: TextStyle(
                            fontSize: 14,
                            color: isDark ? light : dark
                        )),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            RichText(
                text: TextSpan(
                    style: TextStyle(color:isDark ? light : dark,),
                    children: textSpans
                )
            ),
            if (widget.videoUrl != null && _chewieController != null && _controller!.value.isInitialized)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Chewie(controller: _chewieController!),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
