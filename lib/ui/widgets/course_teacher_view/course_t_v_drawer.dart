import 'package:eudkt/services/shared_preference.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../resources/colors.dart';
import '../../state_management/course_teacher_view/course_teacher_view_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';

class CourseTVDrawer extends StatelessWidget {
  const CourseTVDrawer({super.key});

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
    return BlocBuilder<CourseTeacherViewCubit, CourseTeacherViewState>(
      builder: (context, state) {
        if (state.loading || state.courseData == null) {
          return Center(child: CircularProgressIndicator(color: secondaryBlue));
        }

        final modules = state.courseData!['modules'] as Map<String, dynamic>? ?? {};
        if (modules.isEmpty) {
          return const Center(child: Text('No hay contenido disponible.'));
        }

        return ListView(
          padding: EdgeInsets.zero,
          children: [

            if(SharedPreferencesService.role == 'teacher')SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: secondaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0)
                      )
                  ),
                  onPressed: (){

                  },
                  icon: Icon(Icons.school_rounded),
                  label: Text('Alumnos graduados'),
              ),
            ),

            ...modules.entries.map((moduleEntry) {
              final moduleId = moduleEntry.key;
              final moduleData = moduleEntry.value as Map<String, dynamic>;
              final subjects = moduleData['subjects'] as Map<String, dynamic>? ?? {};
              final evaluation = moduleData['evaluation'] as Map<String, dynamic>?;


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

                    return ListTile(
                      leading: getIconByType(subjectData['type']),
                      title: Text(subjectData['name'] ?? 'Tema'),
                      onTap: () {
                        final unitIndex =
                        modules.keys.toList().indexOf(moduleId);
                        final subjectIndex =
                        subjects.keys.toList().indexOf(subjectId);
                        context.read<CourseTeacherViewCubit>().selectTopic(unitIndex, subjectIndex);
                        if (isSmallScreen) context.pop();
                      },
                    );
                  }),

                  if (evaluation != null)
                    ListTile(
                      leading: Icon(Icons.assignment_rounded, color: mainPurple),
                      title: const Text('Evaluación'),
                      onTap: () {
                        final unitIndex =
                        modules.keys.toList().indexOf(moduleId);
                        context.read<CourseTeacherViewCubit>().selectEvaluation(unitIndex);
                        if (isSmallScreen) context.pop();
                      },
                    ),
                ],
              );
            }),

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
