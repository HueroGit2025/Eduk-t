
import 'package:eudkt/resources/colors.dart';
import 'package:eudkt/ui/widgets/course_view/resources_view.dart';
import 'package:eudkt/ui/widgets/course_view/theory_view.dart';
import 'package:eudkt/ui/widgets/course_view/video_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../state_management/course_view/course_view_cubit.dart';
import 'evaluation_view.dart';

class CourseBody extends StatefulWidget {
  const CourseBody({super.key});

  @override
  State<CourseBody> createState() => _CourseBodyState();
}

class _CourseBodyState extends State<CourseBody> {
  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.sizeOf(context).width < 900;

    return Row(
      children: [
        Expanded(
          child: BlocBuilder<CourseViewCubit, CourseViewState>(
            builder: (context, state) {
              if (state.loading || state.courseData == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final modules = state.courseData!['modules'] as Map<String, dynamic>?;

              if (modules == null || modules.isEmpty) {
                return const Center(child: Text('Este curso no tiene unidades.'));
              }

              if (state.currentUnit >= modules.length) {
                return const Center(child: Text('Unidad no disponible.'));
              }

              final currentUnitKey = modules.keys.elementAt(state.currentUnit);
              final currentUnit = modules[currentUnitKey] as Map<String, dynamic>;

              if (state.isEvaluation) {
                return Column(
                  children: [
                    Expanded(child: EvaluationView()),
                    _buildNavigationButtons(context, currentUnitKey),
                  ],
                );
              }

              final subjects = currentUnit['subjects'] as Map<String, dynamic>?;
              final currentSubjectKey = subjects?.keys.elementAt(state.currentSubject);
              final currentSubject = subjects?[currentSubjectKey] as Map<String, dynamic>;

              return Column(
                children: [
                  Expanded(child: _buildSubjectContent(currentSubject)),
                  _buildNavigationButtons(context, ''),
                ],
              );
            },
          ),
        ),
        if (!isTablet) SizedBox(width: 300),
      ],
    );
  }

  Widget _buildNavigationButtons(BuildContext context, String currentUnitKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryBlue,
              foregroundColor: Colors.white
            ),
            onPressed: () => context.read<CourseViewCubit>().goToPrevious(),
            child: const Text('Anterior'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: secondaryBlue,
                foregroundColor: Colors.white
            ),
            onPressed: () => context.read<CourseViewCubit>().goToNext(),
            child: const Text('Siguiente'),
          ),
        ],
      ),
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
