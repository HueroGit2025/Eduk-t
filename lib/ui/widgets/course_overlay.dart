import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../resources/colors.dart';
import '../state_management/theme/theme_cubit.dart';

class CourseOverlay extends StatefulWidget {
  final Map<String, dynamic> courseData;
  final VoidCallback onEnroll;

  const CourseOverlay({
    super.key,
    required this.courseData,
    required this.onEnroll,
  });

  @override
  State<CourseOverlay> createState() => _CourseOverlayState();
}

class _CourseOverlayState extends State<CourseOverlay> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    final videoUrl = widget.courseData['intro_video'] as String;
    _videoPlayerController = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _chewieController = ChewieController(
            videoPlayerController: _videoPlayerController,
            autoPlay: false,
            looping: false,
          );
        });
      });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final title = widget.courseData['course_name'] ?? 'Título no disponible';
    final description = widget.courseData['description'] ?? 'Descripción no disponible';
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: Container(
        width: 600,
        decoration: BoxDecoration(
          color: isDark ? dark2 : light2,
          borderRadius: BorderRadius.circular(30),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _chewieController != null
                    ? AspectRatio(
                  aspectRatio: _videoPlayerController.value.aspectRatio,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                      child: SizedBox(
                        height: 300,
                          child: Chewie(controller: _chewieController!)
                      )
                  ),
                )
                    : const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        description,
                        style: const TextStyle(fontSize: 16),
                        textAlign: TextAlign.justify,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: widget.onEnroll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Inscribirse al curso', style: TextStyle(color: Colors.white),),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
