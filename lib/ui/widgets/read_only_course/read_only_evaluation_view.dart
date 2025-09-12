import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../resources/colors.dart';
import '../../state_management/course_teacher_view/course_teacher_view_cubit.dart';


class OnlyReadEvaluationView extends StatefulWidget {
  const OnlyReadEvaluationView({super.key});

  @override
  State<OnlyReadEvaluationView> createState() => _OnlyReadEvaluationViewState();
}

class _OnlyReadEvaluationViewState extends State<OnlyReadEvaluationView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseTeacherViewCubit, CourseTeacherViewState>(
      builder: (context, state) {

        final courseData = state.courseData;
        final modules = courseData?['modules'] as Map<String, dynamic>? ?? {};
        final currentUnitKey = modules.keys.elementAt(state.currentUnit);
        final evalData = modules[currentUnitKey]?['evaluation'] as Map<String, dynamic>?;


        final type = (evalData?['type'] ?? '').toString();

        if (type == 'exam') {

          final questions = List<Map<String, dynamic>>.from(evalData?['questions'] as List<dynamic>);
          if (questions.isEmpty) {
            return const Center(child: Text('La evaluación no tiene preguntas.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Evaluación',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
                const SizedBox(height: 12),
                ...questions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final q = entry.value;

                  final questionText = (q['question'] ?? '').toString();
                  final options = (q['options'] as List?)?.map((e) => e.toString()).toList() ?? const <String>[];
                  final int? correctIndex = q['correct_answer'] is int ? q['correct_answer'] as int : null;
                  final String? correctLabel =
                  (correctIndex != null && correctIndex >= 0 && correctIndex < options.length)
                      ? options[correctIndex]
                      : null;

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: mainPurple),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pregunta ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(questionText),
                        const SizedBox(height: 12),
                        const Text('Opciones:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        ...options.map((opt) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 6),
                              const SizedBox(width: 8),
                              Expanded(child: Text(opt)),
                            ],
                          ),
                        )),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: thirdBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Respuesta correcta: ${correctLabel ?? '—'}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  );
                }),
              ],
            ),
          );
        }
        return ProjectView( projectDescription: evalData?['description']);

      },
    );
  }
}

class ProjectView extends StatelessWidget {
  final String? projectDescription;
  const ProjectView({super.key, this.projectDescription});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Proyecto',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
          const SizedBox(height: 20),
          Text(projectDescription!,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300)),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
