import 'package:eudkt/resources/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../state_management/help/help_cubit.dart';
import '../state_management/theme/theme_cubit.dart';


OverlayEntry? _activeOverlay;

void showHelpOverlay(BuildContext context) {
  _activeOverlay?.remove();
  _activeOverlay = null;

  final overlay = OverlayEntry(
    builder: (ctx) {
      return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) =>
            HelpCubit(FirebaseFirestore.instance)..loadVideos(),
          ),
          BlocProvider.value(
            value: context.read<ThemeCubit>(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, ThemeState>(
          builder: (ctx, themeState) {
            final isDark = themeState.isDarkMode;

            return Material(
              color: isDark ? Colors.white24 : Colors.black12 ,
              child: Center(
                child: Container(
                  width: MediaQuery.of(ctx).size.width * 0.85,
                  height: MediaQuery.of(ctx).size.height * 0.75,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? dark2 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 15,
                        color: Colors.black26,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text(
                            "Videos de ayuda",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Spacer(),
                          IconButton(
                            icon: Icon(Icons.close,
                                color: isDark ? Colors.white : Colors.black),
                            onPressed: () {
                              _activeOverlay?.remove();
                              _activeOverlay = null;
                            },
                          )
                        ],
                      ),
                      SizedBox(height: 10),

                      Expanded(
                        child: BlocBuilder<HelpCubit, HelpState>(
                          builder: (context, state) {
                            if (state is Loading) {
                              return Center(
                                  child: CircularProgressIndicator());
                            } else if (state is Loaded) {
                              return ListView.builder(
                                itemCount: state.videos.length,
                                itemBuilder: (ctx, index) {
                                  final video = state.videos[index];
                                  return VideoPlayerCard(
                                    url: video['url'],
                                    name: video['name'],
                                  );
                                },
                              );
                            } else if (state is Error) {
                              return Center(child: Text(state.message));
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      );
    },
  );

  Overlay.of(context).insert(overlay);
  _activeOverlay = overlay;
}


class VideoPlayerCard extends StatefulWidget {
  final String url;
  final String name;

  const VideoPlayerCard({
    super.key,
    required this.url,
    required this.name,
  });

  @override
  State<VideoPlayerCard> createState() => _VideoPlayerCardState();
}

class _VideoPlayerCardState extends State<VideoPlayerCard> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.network(widget.url);
    _videoController.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController.value.aspectRatio > 0
            ? _videoController.value.aspectRatio
            : 16 / 9,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _chewieController != null &&
                _chewieController!.videoPlayerController.value.isInitialized
                ? AspectRatio(
              aspectRatio:
              _chewieController!.videoPlayerController.value.aspectRatio,
              child: Chewie(controller: _chewieController!),
            )
                : Container(
              height: 200,
              color: Colors.black12,
              child: Center(child: CircularProgressIndicator()),
            ),
            SizedBox(height: 8),
            Text(
              widget.name,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

