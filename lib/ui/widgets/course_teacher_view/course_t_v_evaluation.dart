import 'package:eudkt/services/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../resources/colors.dart';
import '../../state_management/course_teacher_view/course_teacher_view_cubit.dart';
import 'dart:html' as html;

class TeacherEvaluationView extends StatefulWidget {
  const TeacherEvaluationView({super.key});

  @override
  State<TeacherEvaluationView> createState() => _TeacherEvaluationViewState();
}

class _TeacherEvaluationViewState extends State<TeacherEvaluationView> {
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
        } return ProjectSubmissionsList(submissionsData: state.submissionsData);
      },
    );
  }
}

class ProjectSubmissionsList extends StatefulWidget {
  final Map<String, dynamic>? submissionsData;

  const ProjectSubmissionsList({super.key, this.submissionsData});

  @override
  State<ProjectSubmissionsList> createState() => _ProjectSubmissionsListState();
}

class _ProjectSubmissionsListState extends State<ProjectSubmissionsList> {
  TextEditingController feedbackController = TextEditingController();
  TextEditingController scoreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (widget.submissionsData == null || widget.submissionsData!.isEmpty) {
      return const Center(
        child: Text(
          "Aún no hay proyectos para revisar",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      );
    }

    final submissions = widget.submissionsData!.entries.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: submissions.length,
      itemBuilder: (context, index) {
        final submissionId = submissions[index].key;
        final submission = submissions[index].value as Map<String, dynamic>? ?? {};

        final studentName = submission['student_name'] ?? 'Sin nombre';
        final fileUrl = submission['url'] ?? '';

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Alumno: $studentName",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),

                TextField(
                  controller: scoreController,
                  decoration: const InputDecoration(
                    labelText: "Calificación(70-100)",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 8),

                TextField(
                  controller: feedbackController,
                  decoration: const InputDecoration(
                    labelText: "Feedback",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),


                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: thirdBlue,
                      foregroundColor: Colors.white
                  ),
                  onPressed: () {
                    html.AnchorElement anchorElement = html.AnchorElement(href: fileUrl)
                      ..target = "_blank";
                    anchorElement.click();
                  },
                  icon: const Icon(Icons.download),
                  label: const Text("Descargar proyecto"),
                ),
                const SizedBox(height: 8),


                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(

                        onPressed: () {
                          if (scoreController.text.isNotEmpty) {
                            context.read<CourseTeacherViewCubit>().approveProject(submissionId, submission, scoreController.text.trim());
                          return;
                          }

                          AppSnackBar.showError('Debes colocar una calificación para el alumno');

                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: thirdGreen,
                            foregroundColor: Colors.white
                        ),
                        child: const Text("Aprobar"),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (feedbackController.text.isNotEmpty) {
                            context.read<CourseTeacherViewCubit>().reproveProject(submissionId, submission, feedbackController.text.trim());
                          return;
                          }
                          AppSnackBar.showError('Debes escribir una retroalimentación para el alumno');

                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: mainRed,
                            foregroundColor: Colors.white
                        ),
                        child: const Text("Reprobar"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
