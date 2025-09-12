import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../resources/colors.dart';
import '../../state_management/course_view/course_view_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';

class CourseDrawer extends StatelessWidget {
  const CourseDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.sizeOf(context).width < 900;
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    final content = DrawerContent(isSmallScreen: isSmallScreen);

    return isSmallScreen
        ? Drawer(child: content)
        : Container(
      color: isDark ? dark4 : Colors.grey[100],
      width: 300,
      child: content,
    );
  }
}

class DrawerContent extends StatelessWidget {
  final bool isSmallScreen;

  const DrawerContent({super.key, required this.isSmallScreen});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseViewCubit, CourseViewState>(
      builder: (context, state) {
        if (state.loading || state.courseData == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final modules = state.courseData!['modules'] as Map<String, dynamic>? ?? {};
        if (modules.isEmpty) {
          return const Center(child: Text('No hay contenido disponible.'));
        }

        final progress = state.progressData?['modules'] as Map<String, dynamic>? ?? {};

        final double percentFromStatus = ((state.progressData?['status']?['total_progress'] ?? 0) as num).toDouble().clamp(0, 100) / 100.0;
        final String percentText = '${state.progressData?['status']?['total_progress']}%';

        return ListView(
          padding: EdgeInsets.zero,
          children: [

            Container(
              padding: const EdgeInsets.all(20),
              color: Colors.transparent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Progreso del curso',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        height: 10,
                        width: 200,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: percentFromStatus,
                            backgroundColor: Colors.grey[300],
                            color: secondaryBlue,
                            minHeight: 10,
                          ),
                        ),
                      ),

                      Text(
                        percentText,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),

                ],
              ),
            ),

            ...modules.entries.map((moduleEntry) {
              final moduleId = moduleEntry.key;
              final moduleData = moduleEntry.value as Map<String, dynamic>;
              final subjects =
                  moduleData['subjects'] as Map<String, dynamic>? ?? {};
              final evaluation =
              moduleData['evaluation'] as Map<String, dynamic>?;

              final moduleProgress =
                  progress[moduleId] as Map<String, dynamic>? ?? {};

              return ExpansionTile(
                collapsedTextColor: secondaryBlue,
                collapsedIconColor: secondaryBlue,
                textColor: secondaryBlue,
                iconColor: secondaryBlue,
                shape: Border.all(color: Colors.transparent),
                leading: const Icon(Icons.view_module_rounded),
                title: Text(moduleData['name'] ?? 'Unidad'),
                children: [
                  ...subjects.entries.map((subjectEntry) {
                    final subjectId = subjectEntry.key;
                    final subjectData =
                    subjectEntry.value as Map<String, dynamic>;
                    final subjectProgress = moduleProgress['subjects']?[subjectId]?['completed'] ?? false;

                    return ListTile(
                      leading: getIconByType(subjectData['type']),
                      title: Text(subjectData['name'] ?? 'Tema'),
                      trailing: Icon(
                        Icons.circle,
                        size: 12,
                        color: subjectProgress ? secondaryBlue : Colors.grey,
                      ),
                      onTap: () {
                        final unitIndex =
                        modules.keys.toList().indexOf(moduleId);
                        final subjectIndex =
                        subjects.keys.toList().indexOf(subjectId);
                        context.read<CourseViewCubit>().selectTopic(unitIndex, subjectIndex);
                        if (isSmallScreen) context.pop();
                      },
                    );
                  }),

                  if (evaluation != null)
                    ListTile(
                      leading: Icon(Icons.assignment_rounded, color: mainPurple),
                      title: const Text('Evaluación'),
                      trailing: Icon(
                        Icons.circle,
                        size: 12,
                        color:
                        (moduleProgress['evaluation']?['finished'] ?? false)
                            ? secondaryBlue
                            : Colors.grey,
                      ),
                      onTap: () {
                        final unitIndex =
                        modules.keys.toList().indexOf(moduleId);
                        context.read<CourseViewCubit>().selectEvaluation(unitIndex);
                        if (isSmallScreen) context.pop();
                      },
                    ),
                ],
              );
            }),

            const SizedBox(height: 8),
            const Divider(),

            Padding(
              padding: const EdgeInsets.all(15.0),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: secondaryBlue,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  context.read<CourseViewCubit>().finalizeCourse();
                  if (isSmallScreen) context.pop();
                },
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: const Text(
                  'Finalizar curso',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

}

Widget? getIconByType(type) {
  switch (type) {
    case 'video':
      return Icon(Icons.play_circle, color: mainRed);
    case 'theory':
      return Icon(Icons.book, color: secondaryBlue);
    case 'resources':
      return Icon(Icons.source_rounded, color: thirdGreen);
  }
  return null;
}
