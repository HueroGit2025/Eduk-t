import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../services/app_snackbar.dart';
import '../../state_management/course_view/course_view_cubit.dart';
import '../../widgets/course_view/course_body.dart';
import '../../widgets/course_view/course_drawer.dart';

class CoursePage extends StatefulWidget {
  final String courseId;
  const CoursePage({super.key, required this.courseId});

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.sizeOf(context).width < 900;
    return BlocProvider(
      create: (_) => CourseViewCubit(
        courseId: widget.courseId,
      )..loadCourse(),
      child: BlocListener<CourseViewCubit, CourseViewState>(
        listener: (context, state) {

          if (state.info != null) {
            AppSnackBar.showInfo(state.info!);
            context.read<CourseViewCubit>().clearInfo();
          }

          if (state.successInfo != null) {
            AppSnackBar.showSuccess(state.successInfo!);
            context.read<CourseViewCubit>().clearSuccessInfo();
          }

          if (state.error != null) {
            AppSnackBar.showError(state.error!);
            context.read<CourseViewCubit>().clearError();
          }

            if (state.evaluationCompleted) {
              AppSnackBar.showSuccess('¡Evaluación completada con éxito!');
              context.read<CourseViewCubit>().resetEvaluationCompletedFlag();
            }

        },
        child: BlocBuilder<CourseViewCubit, CourseViewState>(
          builder: (context, state) {
            return Stack(
              children: [
                Scaffold(
                  appBar: AppBar(
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
                                ? IconButton(
                              onPressed: () {
                                Scaffold.of(context).openEndDrawer();
                              },
                              icon: const Icon(Icons.menu_rounded),
                            )
                                : const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ),
                  endDrawer: const CourseDrawer(),
                  body: const CourseBody(),
                ),
                Row(
                  children: [
                    const Expanded(child: SizedBox.shrink()),
                    if (!isTablet)
                      Material(
                        elevation: 2,
                        child: SizedBox(
                          child: const CourseDrawer(),
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),

    );
  }
}
