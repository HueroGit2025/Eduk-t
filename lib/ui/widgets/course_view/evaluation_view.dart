import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../resources/colors.dart';
import '../../state_management/course_view/course_view_cubit.dart';
import 'package:file_picker/file_picker.dart';

import '../../state_management/theme/theme_cubit.dart';

class EvaluationView extends StatefulWidget {
  const EvaluationView({super.key});

  @override
  State<EvaluationView> createState() => _EvaluationViewState();
}

class _EvaluationViewState extends State<EvaluationView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseViewCubit, CourseViewState>(
        builder: (context, state) {
          if (!state.isEvaluation) {
            return const Center(child: Text('No hay evaluación disponible.'));
          }

          final courseData = state.courseData;
          if (courseData == null) return const SizedBox();

          final modules = courseData['modules'] as Map<String, dynamic>? ?? {};

          final currentUnitKey = modules.keys.elementAt(state.currentUnit);
          final evalData = modules[currentUnitKey]?['evaluation'] as Map<String, dynamic>?;


          final type = evalData?['type'];
          if (type == 'exam') {
            final questions = List<Map<String, dynamic>>.from(evalData?['questions'] as List<dynamic>);
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  const Text('Evaluación', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500)),
                  ...questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final q = entry.value;
                    final qId = (q['id'] ?? index).toString();
                    final options = List<dynamic>.from(q['options'] ?? []);

                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: mainPurple),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pregunta ${index + 1}: ${q['question'] ?? ''}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ...options.asMap().entries.map((entryOpt) {
                            final optIndex = entryOpt.key;
                            final optText = entryOpt.value.toString();

                            return RadioListTile<int>(
                              value: optIndex,
                              groupValue: state.answers[qId] as int?,
                              onChanged: (value) {
                                if (value != null) {
                                  context.read<CourseViewCubit>().updateAnswer(qId, value);
                                }
                              },
                              title: Text(optText),
                            );
                          })


                        ],
                      ),
                    );
                  }),
                ],
              ),
            );
          }
            return ProjectView( projectDescription: evalData?['description']);

        }
      );
  }
}


class ProjectView extends StatelessWidget {
  final String? projectDescription;
  const ProjectView({super.key, this.projectDescription});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CourseViewCubit, CourseViewState>(
      builder: (context, state) {
        final cubit = context.read<CourseViewCubit>();
        final isDark = context.watch<ThemeCubit>().state.isDarkMode;

        if(state.submissionData != null && state.submissionData?['status'] == 'pending'){
          return Center(
            child:Text('Tu proyecto está siendo revisado.')
          );

        }else if(state.submissionData != null&& state.submissionData?['status'] == 'accepted'){
          return Center(
              child:Text('Tu proyecto ha sido calificado.')
          );
        }

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
              state.selectedFileName == null
                  ? ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: mainPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'docx', 'doc', 'xlsx', 'xls','ppt', 'pptx', 'zip', 'rar'],
                  );
                  if (result != null && result.files.isNotEmpty) {
                    final file = result.files.first;
                    cubit.selectProjectFile(
                      file.name,
                      file,
                    );
                  }
                },
                icon: const Icon(Icons.upload_file),
                label: const Text("Subir archivo"),
              )
                  : Card(
                color: isDark ? dark2 : Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: ListTile(
                  leading: Icon(Icons.insert_drive_file,
                      color: mainPurple),
                  title: Text(state.selectedFileName!),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_rounded, color: Colors.grey),
                    onPressed: () {
                      cubit.removeProjectFile();
                    },
                  ),
                ),
              ),
              Expanded(child: SizedBox.shrink()),
              if(state.submissionData != null && state.submissionData?['status'] == 'rejected')Container(
                decoration: BoxDecoration(
                  color: thirdBlue,
                  borderRadius: BorderRadius.circular(30),
                ),
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                child: Text(state.submissionData!['feedback'] ?? 'Volver a subir el archivo', style: const TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }
}

