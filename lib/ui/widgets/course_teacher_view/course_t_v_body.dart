
import 'package:eudkt/services/shared_preference.dart';
import 'package:eudkt/ui/widgets/course_teacher_view/course_t_v_evaluation.dart';
import 'package:eudkt/ui/widgets/course_view/resources_view.dart';
import 'package:eudkt/ui/widgets/course_view/theory_view.dart';
import 'package:eudkt/ui/widgets/course_view/video_view.dart';
import 'package:eudkt/ui/widgets/read_only_course/read_only_evaluation_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state_management/course_teacher_view/course_teacher_view_cubit.dart';
import 'course_t_v_drawer.dart';

class CourseTVBody extends StatefulWidget {
  const CourseTVBody({super.key});

  @override
  State<CourseTVBody> createState() => _CourseTVBodyState();
}

class _CourseTVBodyState extends State<CourseTVBody> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.sizeOf(context).width < 900;

    return Row(
      children: [
        Expanded(
          child: BlocBuilder<CourseTeacherViewCubit, CourseTeacherViewState>(
            builder: (context, state) {
              if (state.loading || state.courseData == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final modules = state.courseData!['modules'] as Map<String, dynamic>?;

              final currentUnitKey = modules?.keys.elementAt(state.currentUnit);
              final currentUnit = modules?[currentUnitKey] as Map<String, dynamic>;

              if (state.isEvaluation) {
                return Column(
                  children: [
                    if(SharedPreferencesService.role == 'teacher')Expanded(child: TeacherEvaluationView()),
                    if(SharedPreferencesService.role == 'admin' || SharedPreferencesService.role == 'supervisor')Expanded(child: OnlyReadEvaluationView()),

                  ],
                );
              }

              final subjects = currentUnit['subjects'] as Map<String, dynamic>?;
              final currentSubjectKey = subjects?.keys.elementAt(state.currentSubject);
              final currentSubject = subjects?[currentSubjectKey] as Map<String, dynamic>;

              return Column(
                children: [
                  Expanded(child: _buildSubjectContent(currentSubject)),
                ],
              );
            },
          ),
        ),
        if (!isTablet) CourseTVDrawer(),
      ],
    );
  }


  Widget _buildSubjectContent(Map<String, dynamic> subject) {
    final type = subject['type'];
    if (type == 'video') {
      return VideoView(url: subject['file_url']);
    } else if (type == 'theory') {
      return TheoryView(contentJson: subject['file_url']);
    } else if (type == 'resources') {
      return ResourcesView(files: subject['file_url']);
    }
    return const Center(child: Text('Contenido no disponible'));
  }
}
