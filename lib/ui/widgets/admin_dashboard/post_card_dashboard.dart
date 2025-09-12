import 'package:chewie/chewie.dart';
import 'package:eudkt/resources/colors.dart';
import 'package:eudkt/ui/widgets/profile_avatar.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../state_management/community/community_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';

class PostCardDashboard extends StatefulWidget {
  final Map<String, dynamic> post;

  const PostCardDashboard({
    super.key,
    required this.post,

  });

  @override
  State<PostCardDashboard> createState() => _PostCardDashboardState();
}

class _PostCardDashboardState extends State<PostCardDashboard> {
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.post['video'] != null && widget.post['video']!.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.post['video']!)
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

    final List<InlineSpan> textSpans =
    widget.post['text'].split(' ').map<InlineSpan>((word) {
      final isUrl = Uri.tryParse(word)?.hasAbsolutePath ?? false;
      return isUrl
          ? TextSpan(
        text: '$word ',
        style: const TextStyle(color: Colors.blue),
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

    return Stack(
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ProfileAvatarBasic(imageUrl: widget.post['image'], size: 40),
                    const SizedBox(width: 10),
                    Text(
                      widget.post['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? light : dark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    style: TextStyle(
                      color: isDark ? light : dark,
                      fontSize: 16,
                    ),
                    children: textSpans,
                  ),
                ),
                if (widget.post['video'] != null &&
                    _chewieController != null &&
                    _controller!.value.isInitialized)
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
        ),
        Positioned(
          top: 15,
          right: 30,
          child: IconButton(
            icon: const Icon(Icons.delete_rounded, color: Colors.grey),
            onPressed: (){
              context.read<CommunityCubit>().deletePost(widget.post['id'], widget.post['student_id']);
            },
          ),
        ),
      ],
    );
  }
}
