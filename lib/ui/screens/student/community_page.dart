import 'package:eudkt/services/app_snackbar.dart';
import 'package:eudkt/services/shared_preference.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eudkt/ui/state_management/community/community_cubit.dart';
import 'package:go_router/go_router.dart';


import '../../../resources/colors.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../../widgets/post_card.dart';

class Community extends StatefulWidget {
  const Community({super.key});

  @override
  State<Community> createState() => _CommunityState();
}

class _CommunityState extends State<Community> {
  String? selectedCareer;

  @override
  void initState() {
    super.initState();
    context.read<CommunityCubit>().loadPosts();
  }
  void _showAddPostDialog() {
    final textController = TextEditingController();
    PlatformFile? selectedVideo;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Nuevo Aporte'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 400,
                  child: TextField(
                    maxLines: 8,
                    maxLength: 500,
                    textAlign: TextAlign.justify,
                    controller: textController,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      labelText: 'Texto',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('* La selección de un video es opcional'),
                const SizedBox(height: 8),

                if (selectedVideo == null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryBlue,
                      foregroundColor: light,
                    ),
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles(
                        type: FileType.video,
                      );
                      if (result != null && result.files.isNotEmpty) {
                        setState(() {
                          selectedVideo = result.files.first;
                        });
                      }
                    },
                    icon: const Icon(Icons.video_library),
                    label: const Text("Seleccionar video"),
                  )
                else
                  Column(
                    children: [

                      Row(
                        children: [
                          Icon(Icons.videocam, color: thirdGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              selectedVideo!.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                selectedVideo = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: secondaryBlue),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryBlue,
                  foregroundColor: light,
                ),
                onPressed: () async {
                  if (textController.text.isEmpty) {
                    AppSnackBar.showError('El texto no puede estar vacío.');
                    return;
                  }

                    var postId = '${SharedPreferencesService.enrollment}${context.read<CommunityCubit>().generateCourseId()}';
                    String videoUrl = '';
                    if(selectedVideo != null){
                      videoUrl = await context.read<CommunityCubit>().uploadFile(selectedVideo!, 'publications/$postId');
                    }
                    final post = {
                      'student_id': SharedPreferencesService.enrollment,
                      'text': textController.text,
                      'video': videoUrl,
                      'career': SharedPreferencesService.career,
                      'name': SharedPreferencesService.name,
                    };
                    bool result = await context.read<CommunityCubit>().addPost(post, SharedPreferencesService.enrollment!, postId);
                    if (!result) {
                      AppSnackBar.showError('Error al subir el aporte');
                    }
                    AppSnackBar.showSuccess('Aporte publicado con éxito.');
                    context.pop();

                },
                child: const Text('Publicar'),
              ),
            ],
          ),
        );
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;
    return Stack(
      children: [
        BlocBuilder<CommunityCubit, CommunityState>(
          builder: (context, state) {
            if (state is CommunityLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is CommunityEmpty) {
              return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image(
                        height: 100,
                        image: AssetImage('assets/empty-box.png'),
                      ),
                      Text(
                        'No hay aportes disponibles.',
                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    ],
                  ));
            } else if (state is CommunityError) {
              return Center(child: Text(state.message));
            } else if (state is CommunityLoaded) {

              final posts = state.posts;

              return ListView.builder(
                itemCount: posts.length + 2,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return SizedBox(
                      height: 80,
                    );
                  }
                  if (index == posts.length + 1) return SizedBox(height: 100);
                  final post = posts[index - 1];
                  return PostCard(
                    text: post['text'] ?? '',
                    videoUrl: post['video']!,
                    user: post['name'],
                    avatar: post['image'],
                    career: post['career'],
                    createdAt: post['created_at'],
                  );
                },
              );
            }

            return SizedBox.shrink();
          },
        ),

        Container(
          height: 75,
          color: isDark ? dark3 : light2,
          child: Padding(
            padding: const EdgeInsets.only(left: 30, top: 20, right: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Aportes de la Comunidad', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                PopupMenuButton<String>(
                  color: isDark ? dark2 : light ,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  icon: const Icon(Icons.filter_list),
                  tooltip: 'Filtrar por carrera',
                  onSelected: (value) {
                    setState(() {
                      selectedCareer = value == 'Todos' ? null : value;
                    });
                    context.read<CommunityCubit>().loadPosts(career: selectedCareer);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem<String>(
                      value: 'Todos',
                      child: Text('Mostrar todos'),
                    ),
                    const PopupMenuDivider(),
                    ...[
                      'Lic. en Contaduría Pública',
                      'Lic. en Gastronomía',
                      'Ing. Ambiental',
                      'Ing. en Administración',
                      'Ing. en Sistemas Computacionales',
                      'Ing. en TICs',
                      'Ing. en Energías Renovables',
                      'Ing. Industrial',
                      'Ing. en Sistemas Automotrices'
                    ].map((career) => PopupMenuItem<String>(
                      value: career,
                      child: Text(career),
                    )),
                  ],
                )
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: 20,
          child: FloatingActionButton.extended(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            backgroundColor: secondaryBlue,
            foregroundColor: light,
            onPressed: _showAddPostDialog,
            icon: Icon(Icons.queue),
            label: Text('Añadir aporte'),
          ),
        ),
      ],
    );

  }
}
