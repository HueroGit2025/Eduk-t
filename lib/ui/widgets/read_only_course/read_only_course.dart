import 'package:eudkt/resources/colors.dart';
import 'package:eudkt/ui/state_management/course_teacher_view/course_teacher_view_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../services/app_snackbar.dart';
import '../../../services/shared_preference.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../../widgets/course_teacher_view/course_t_v_body.dart';
import '../../widgets/course_teacher_view/course_t_v_drawer.dart';

class ReadOnlyCourse extends StatefulWidget {
  final String courseId;

  const ReadOnlyCourse({super.key, required this.courseId});

  @override
  State<ReadOnlyCourse> createState() => _ReadOnlyCourseState();
}

class _ReadOnlyCourseState extends State<ReadOnlyCourse> {

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.sizeOf(context).width < 900;
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return BlocProvider(
      create: (_) => CourseTeacherViewCubit(
        courseId: widget.courseId,
      )..loadCourse(),
      child: BlocListener<CourseTeacherViewCubit, CourseTeacherViewState>(
        listener: (context, state) {

          if (state.error != null) {
            AppSnackBar.showError(state.error!);
            context.read<CourseTeacherViewCubit>().clearError();
          }

          if (state.successMessage != null) {
            AppSnackBar.showSuccess(state.successMessage!);
            context.read<CourseTeacherViewCubit>().clearSuccessMessage();
          }
        },
        child: BlocBuilder<CourseTeacherViewCubit, CourseTeacherViewState>(
          builder: (context, state) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: isDark ? dark4 : Colors.grey[100],
                leading: IconButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    context.pop();
                  },
                  icon: const Icon(Icons.chevron_left_rounded, size: 40),
                ),
                title: (state.loading)
                    ? const Text('Cargando...')
                    : Text(
                  state.courseData?['course_name'] ?? 'Curso',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                actions: [
                  Builder(
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: isTablet
                            ? Row(
                              children: [
                                if(SharedPreferencesService.role == 'admin')IconButton(
                                  tooltip: 'Activar curso',
                                  onPressed: () {
                                    context.read<CourseTeacherViewCubit>().activeCourse();
                                  },
                                  icon: const Icon(Icons.power_settings_new_rounded),
                                ),
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    Scaffold.of(context).openEndDrawer();
                                    },
                                  icon: const Icon(Icons.menu_rounded),
                                ),
                              ],
                            )
                            : Row(
                              children: [
                                if(SharedPreferencesService.role == 'admin')IconButton(
                                  tooltip: 'Activar curso',
                                  onPressed: () {
                                    context.read<CourseTeacherViewCubit>().activeCourse();
                                  },
                                  icon: const Icon(Icons.power_settings_new_rounded),
                                ),

                              ],
                            ),
                      );
                    },
                  ),
                ],
              ),
              endDrawer: const CourseTVDrawer(),
              body: const CourseTVBody(),
            );
          },
        ),
      ),

    );
  }

}
