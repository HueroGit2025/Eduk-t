import 'package:dotted_border/dotted_border.dart';
import 'package:eudkt/services/app_snackbar.dart';
import 'package:eudkt/ui/state_management/course_upload/course_upload_cubit.dart';
import 'package:eudkt/ui/widgets/course_creator/evaluation_card.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';

import '../../../resources/colors.dart';
import '../../../resources/course_creator_globals.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../../widgets/course_creator/resource_manager.dart';

class CourseCreator extends StatefulWidget {
  const CourseCreator({super.key});

  @override
  CourseCreatorState createState() => CourseCreatorState();
}

class CourseCreatorState extends State<CourseCreator>
    with TickerProviderStateMixin {
  int unitCount = 0;
  final TextEditingController titleController =
      TextEditingController(text: "Nuevo Curso");
  final TextEditingController _courseDescriptionController =
      TextEditingController();
  PlatformFile? introVideo;
  PlatformFile? imageFile;

  @override
  void dispose() {
    titleController.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'wmv', 'avi', 'webm'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        introVideo = file;
      });
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        imageFile = file;
      });
    }
  }

  Widget _buildPickerCard({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          color: isSelected ? thirdGreen : Colors.grey[400]!,
          radius: const Radius.circular(30),
          strokeWidth: 3,
        ),
        child: Container(
          height: 140,
          width: 180,
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSelected ? Icons.check_circle_rounded : icon,
                size: 50,
                color: isSelected ? thirdGreen : Colors.grey[300],
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? thirdGreen : Colors.grey[300],
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCourseHeader(bool isMobile) {
    final description = TextField(
      controller: _courseDescriptionController,
      maxLines: 5,
      textAlign: TextAlign.justify,
      decoration: InputDecoration(
        alignLabelWithHint: true,
        labelText: 'Descripción del curso',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );

    final imageCard = _buildPickerCard(
      label: 'Imagen del curso',
      icon: Icons.image_rounded,
      isSelected: imageFile != null,
      onTap: _pickImage,
    );

    final videoCard = _buildPickerCard(
      label: 'Video Introductorio',
      icon: Icons.ondemand_video_rounded,
      isSelected: introVideo != null,
      onTap: _pickVideo,
    );

    if (isMobile) {
      return Column(
        children: [
          description,
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              imageCard,
              const SizedBox(width: 20),
              videoCard,
            ],
          ),
        ],
      );
    } else {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: description),
          const SizedBox(width: 20),
          imageCard,
          const SizedBox(width: 20),
          videoCard,
        ],
      );
    }
  }

  void addUnity() {
    unitCount++;
    setState(() {
      final newUnity = Unity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: "Unidad $unitCount",
        subjects: [],
        isExam: false,
      );
      CourseCreatorGlobals.units.add(newUnity);
      CourseCreatorGlobals.selectedUnity = newUnity;
    });
  }

  void deleteUnity(String id) {
    setState(() {
      CourseCreatorGlobals.units.removeWhere((unity) => unity.id == id);
      if (CourseCreatorGlobals.selectedUnity?.id == id) {
        CourseCreatorGlobals.selectedUnity =
            CourseCreatorGlobals.units.isNotEmpty
                ? CourseCreatorGlobals.units.last
                : null;
      }
    });
  }

  void selectUnity(Unity unity) {
    setState(() {
      CourseCreatorGlobals.selectedUnity =
          unity.id == CourseCreatorGlobals.selectedUnity?.id ? null : unity;
    });
  }

  void addSubject(SubjectType subjectType) {
    if (CourseCreatorGlobals.selectedUnity == null) return;

    setState(() {
      final newSubject = Subject(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: getTitleSubject(subjectType),
        type: subjectType,
      );

      final unityIndex = CourseCreatorGlobals.units
          .indexWhere((u) => u.id == CourseCreatorGlobals.selectedUnity!.id);
      if (unityIndex != -1) {
        CourseCreatorGlobals.units[unityIndex].subjects.add(newSubject);
      }
    });
  }

  String getTitleSubject(SubjectType type) {
    switch (type) {
      case SubjectType.video:
        return "Video ${CourseCreatorGlobals.selectedUnity!.subjects.where((t) => t.type == SubjectType.video).length + 1}";
      case SubjectType.theory:
        return "Teoría ${CourseCreatorGlobals.selectedUnity!.subjects.where((t) => t.type == SubjectType.theory).length + 1}";
      case SubjectType.resources:
        return "Recursos ${CourseCreatorGlobals.selectedUnity!.subjects.where((t) => t.type == SubjectType.resources).length + 1}";
    }
  }

  void deleteSubject(String unityId, String subjectId) {
    setState(() {
      final unityIndex =
          CourseCreatorGlobals.units.indexWhere((u) => u.id == unityId);
      if (unityIndex != -1) {
        CourseCreatorGlobals.units[unityIndex].subjects
            .removeWhere((tema) => tema.id == subjectId);
      }
    });
  }

  void renameUnity(String unityId, String newName) {
    setState(() {
      final unityIndex =
          CourseCreatorGlobals.units.indexWhere((u) => u.id == unityId);
      if (unityIndex != -1) {
        CourseCreatorGlobals.units[unityIndex].name = newName;
      }
    });
  }

  void renameSubject(String unityId, String subjectId, String newName) {
    setState(() {
      final unityIndex =
          CourseCreatorGlobals.units.indexWhere((u) => u.id == unityId);
      if (unityIndex != -1) {
        final subjectIndex = CourseCreatorGlobals.units[unityIndex].subjects
            .indexWhere((t) => t.id == subjectId);
        if (subjectIndex != -1) {
          CourseCreatorGlobals.units[unityIndex].subjects[subjectIndex].name =
              newName;
        }
      }
    });
  }

  Future<void> _showDialogTypeTopic(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecciona el tipo de tema'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading:
                    Icon(Icons.play_circle_rounded, color: Colors.redAccent),
                title: Text('Video'),
                onTap: () {
                  Navigator.of(context).pop();
                  addSubject(SubjectType.video);
                },
              ),
              ListTile(
                leading: Icon(Icons.book, color: Colors.indigoAccent),
                title: Text('Teoría'),
                onTap: () {
                  Navigator.of(context).pop();
                  addSubject(SubjectType.theory);
                },
              ),
              ListTile(
                leading: Icon(Icons.source_rounded, color: Colors.green),
                title: Text('Recursos'),
                onTap: () {
                  Navigator.of(context).pop();
                  addSubject(SubjectType.resources);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<String?> _showDialogName(
      BuildContext context, String actualName) async {
    final controller = TextEditingController(text: actualName);
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cambiar nombre'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Nombre',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<Map<String, dynamic>?> showCreditsAndCareerDialog(
    BuildContext context,
    bool isDark,
  ) async {
    String? selectedCareer;
    int selectedCredits = 0;

    return await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Asignar Créditos y Carrera",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Selecciona los créditos:"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: isDark ? dark2 : light,
                    borderRadius: BorderRadius.circular(20),
                    initialValue: selectedCredits,
                    items: const [
                      DropdownMenuItem(
                        value: 0,
                        child: Text("Ninguno"),
                      ),
                      DropdownMenuItem(
                        value: 1,
                        child: Text("1 crédito + 20 hrs"),
                      ),
                      DropdownMenuItem(
                        value: 2,
                        child: Text("2 créditos + 40 hrs"),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCredits = value ?? 0;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text("Selecciona la carrera:"),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    dropdownColor: isDark ? dark2 : light,
                    borderRadius: BorderRadius.circular(20),
                    initialValue: selectedCareer,
                    items: [
                      'Todas',
                      'Lic. en Contaduría Pública',
                      'Lic. en Gastronomía',
                      'Ing. Ambiental',
                      'Ing. en Administración',
                      'Ing. en Sistemas Computacionales',
                      'Ing. en TICs',
                      'Ing. en Energías Renovables',
                      'Ing. Industrial',
                      'Ing. en Sistemas Automotrices'
                    ]
                        .map((career) => DropdownMenuItem(
                              value: career,
                              child: Text(career),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCareer = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: Text("Cancelar", style: TextStyle(color: secondaryBlue)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: () {
                if (selectedCareer == null) {
                  AppSnackBar.showError('Debes seleccionar una carrera');
                  return;
                }
                Navigator.of(context).pop({
                  'credits': selectedCredits,
                  'career': selectedCareer,
                });
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
    bool isMobile = MediaQuery.sizeOf(context).width < 700;
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return Scaffold(
      key: scaffoldKey,
      endDrawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text('Unidades del curso',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                child: CourseCreatorGlobals.units.isEmpty
                    ? Center(child: Text('Añade unidades para comenzar'))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 15),
                        itemCount: CourseCreatorGlobals.units.length,
                        itemBuilder: (context, index) {
                          final unity = CourseCreatorGlobals.units[index];
                          final isSelected =
                              CourseCreatorGlobals.selectedUnity?.id ==
                                  unity.id;

                          return UnityCard(
                            unity: unity,
                            isSelected: isSelected,
                            onTap: () {
                              selectUnity(unity);
                              Navigator.pop(context);
                            },
                            onDelete: () => deleteUnity(unity.id),
                            onRename: (newName) =>
                                renameUnity(unity.id, newName),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
            padding: EdgeInsets.all(0),
            onPressed: () {
              context.pop();
            },
            icon: Icon(
              Icons.chevron_left_rounded,
              size: 40,
            )),
        title: InkWell(
          onTap: () async {
            final result = await _showDialogName(context, titleController.text);
            if (result != null) {
              setState(() {
                titleController.text = result;
              });
            }
          },
          child: Text(titleController.text),
        ),
        actions: [
          BlocListener<CourseUploadCubit, CourseUploadState>(
            listener: (context, state) {
              if (state is Error) {
                AppSnackBar.showError(state.message);
              } else if (state is Success) {
                AppSnackBar.showSuccess('Curso subido con éxito');
                context.pop();
              }
            },
            child: IconButton(
              tooltip: 'Subir curso',
              icon: Icon(Icons.upload_rounded),
              onPressed: () async {
                final result =
                    await showCreditsAndCareerDialog(context, isDark);

                if (result == null) return;
                context.read<CourseUploadCubit>().uploadCourse(
                      titleController.text,
                      _courseDescriptionController.text,
                      result['career'],
                      result['credits'],
                      imageFile,
                      introVideo,
                    );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.menu_rounded),
              onPressed: () => scaffoldKey.currentState!.openEndDrawer(),
              tooltip: 'Abrir unidades',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCourseHeader(isMobile),
              const SizedBox(height: 30),
              if (CourseCreatorGlobals.selectedUnity == null)
                const Center(
                    child: Text(
                  'Selecciona una unidad para añadir temas',
                  style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey),
                ))
              else ...[
                Text(
                  'Contenido de ${CourseCreatorGlobals.selectedUnity!.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),
                EvaluationCard(
                  unity: CourseCreatorGlobals.selectedUnity!,
                ),
                const SizedBox(height: 10),
                if (CourseCreatorGlobals.selectedUnity!.subjects.isEmpty)
                  const Center(
                      child: Text(
                    'Añade temas a esta unidad',
                    style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey),
                  ))
                else
                  ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        CourseCreatorGlobals.selectedUnity!.subjects.length,
                    itemBuilder: (context, index) {
                      final subject =
                          CourseCreatorGlobals.selectedUnity!.subjects[index];
                      return SubjectCard(
                        subject: subject,
                        onDelete: () => deleteSubject(
                            CourseCreatorGlobals.selectedUnity!.id, subject.id),
                        onRename: (newName) => renameSubject(
                            CourseCreatorGlobals.selectedUnity!.id,
                            subject.id,
                            newName),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (CourseCreatorGlobals.selectedUnity != null) ...[
            FloatingActionButton.small(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              backgroundColor: thirdBlue,
              foregroundColor: Colors.white,
              heroTag: "btnAddSubject",
              onPressed: () => _showDialogTypeTopic(context),
              tooltip: 'Añadir Tema',
              child: Icon(Icons.playlist_add),
            ),
            SizedBox(height: 16),
          ],
          FloatingActionButton(
            backgroundColor: secondaryBlue,
            foregroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
            heroTag: "btnAddUnity",
            onPressed: addUnity,
            tooltip: 'Añadir unidad',
            child: Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

class UnityCard extends StatefulWidget {
  final Unity unity;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final Function(String) onRename;

  const UnityCard({
    super.key,
    required this.unity,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  UnityCardState createState() => UnityCardState();
}

class UnityCardState extends State<UnityCard>
    with SingleTickerProviderStateMixin {
  Future<void> _showDialogRename(BuildContext context) async {
    final controller = TextEditingController(text: widget.unity.name);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Renombrar unidad'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Nombre de la unidad',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  widget.onRename(controller.text);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      elevation: widget.isSelected ? 8 : 1,
      color: widget.isSelected ? secondaryBlue : null,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 200,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.unity.name,
                          style: TextStyle(
                            color:
                                widget.isSelected ? Colors.white : Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        color:
                            widget.isSelected ? Colors.white : Colors.grey[700],
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                        onPressed: () => _showDialogRename(context),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${widget.unity.subjects.length} temas',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isSelected
                          ? Colors.grey[300]
                          : Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete,
                        color: widget.isSelected
                            ? Colors.grey[300]
                            : Colors.grey[700]),
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar unidad'),
          content: Text(
              '¿Estás seguro de que deseas eliminar "${widget.unity.name}"?'),
          actions: [
            TextButton(
              child: Text('Cancelar',
                  style: TextStyle(color: Colors.indigoAccent)),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text('Eliminar', style: TextStyle(color: Colors.red[400])),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
            ),
          ],
        );
      },
    );
  }
}

class SubjectCard extends StatefulWidget {
  final Subject subject;
  final VoidCallback onDelete;
  final Function(String) onRename;

  const SubjectCard({
    super.key,
    required this.subject,
    required this.onDelete,
    required this.onRename,
  });

  @override
  State<SubjectCard> createState() => _SubjectCardState();
}

class _SubjectCardState extends State<SubjectCard>
    with AutomaticKeepAliveClientMixin {
  bool isExpanded = false;
  String? savedContent;

  IconData _getIconByType() {
    switch (widget.subject.type) {
      case SubjectType.video:
        return Icons.play_circle;
      case SubjectType.theory:
        return Icons.book;
      case SubjectType.resources:
        return Icons.source_rounded;
    }
  }

  Color _getCardColor() {
    switch (widget.subject.type) {
      case SubjectType.video:
        return mainRed;
      case SubjectType.theory:
        return secondaryBlue;
      case SubjectType.resources:
        return thirdGreen;
    }
  }

  Future<void> _showRenameDialog(BuildContext context) async {
    final controller = TextEditingController(text: widget.subject.name);
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Renombrar tema'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Nombre del tema',
              border: OutlineInputBorder(),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  widget.onRename(controller.text);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar tema'),
          content: Text(
              '¿Estás seguro de que deseas eliminar "${widget.subject.name}"?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Eliminar',
                  style: TextStyle(color: Colors.red.shade300)),
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete();
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleExpand() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  Future<void> _pickVideo(Subject subject) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4'],
    );
    if (result != null && result.files.isNotEmpty) {
      final file = result.files.single;
      setState(() {
        subject.videoFile = file;
      });
    }
  }

  Widget _buildExpandedContent(isDark) {
    switch (widget.subject.type) {
      case SubjectType.video:
        return Column(
          children: [
            if (widget.subject.videoFile != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: secondaryRed,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Video: ${widget.subject.videoFile!.name}',
                        style: const TextStyle(color: Colors.white),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          widget.subject.videoFile = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryRed,
                foregroundColor: Colors.white,
              ),
              onPressed: () => _pickVideo(widget.subject),
              icon: const Icon(Icons.upload_file),
              label: Text(
                widget.subject.videoFile == null
                    ? 'Seleccionar video'
                    : 'Reemplazar video',
              ),
            ),
          ],
        );

      case SubjectType.theory:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: isDark ? dark2 : Colors.white,
                  borderRadius: BorderRadius.circular(30)),
              child: quill.QuillSimpleToolbar(
                controller: widget.subject.quillController!,
                config: const quill.QuillSimpleToolbarConfig(
                  showAlignmentButtons: true,
                  showStrikeThrough: false,
                  showInlineCode: false,
                  showColorButton: false,
                  showClearFormat: false,
                  showListCheck: false,
                  showCodeBlock: false,
                  showQuote: false,
                  showIndent: false,
                  showSearchButton: false,
                  showBackgroundColorButton: false,
                  showFontFamily: false,
                  showLink: false,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 500,
              decoration: BoxDecoration(
                  color: isDark ? dark2 : Colors.white,
                  borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.all(20),
              child: quill.QuillEditor.basic(
                controller: widget.subject.quillController!,
                config: const quill.QuillEditorConfig(),
              ),
            ),
          ],
        );

      case SubjectType.resources:
        return Column(
          children: [
            ResourceManager(
              resources: widget.subject.resources,
            )
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    super.build(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: _getCardColor(),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: IconButton(
              icon: Icon(
                isExpanded
                    ? Icons.expand_less_rounded
                    : Icons.expand_more_rounded,
                color: Colors.white,
              ),
              onPressed: _toggleExpand,
            ),
            title: Row(
              children: [
                Icon(
                  _getIconByType(),
                  color: Colors.white,
                ),
                SizedBox(
                  width: 20,
                ),
                InkWell(
                  onTap: () => _showRenameDialog(context),
                  child: Text(
                    widget.subject.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
              ),
              onPressed: () => _confirmDelete(context),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildExpandedContent(isDark),
            ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
