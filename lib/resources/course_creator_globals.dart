
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class CourseCreatorGlobals {
  static List<Unity> units = [];
  static Unity? selectedUnity;
}

enum SubjectType { video, theory, resources }

class Unity {
  final String id;
  String name;
  List<Subject> subjects;
  bool isExam;
  String projectDescription;
  List<Question> questions;


  Unity({
    required this.id,
    required this.name,
    required this.subjects,
    this.isExam = false,
    this.projectDescription = '',
    List<Question>? questions,
  }) : questions = questions ?? [];
}


class Subject {
  final String id;
  String name;
  final SubjectType type;

  quill.QuillController? quillController;
  List<PlatformFile> resources;
  PlatformFile? videoFile;
  Subject({
    required this.id,
    required this.name,
    required this.type,
    quill.QuillController? quillController,
    List<PlatformFile>? resources,
    PlatformFile? videoFile,
  })  : quillController = quillController ?? quill.QuillController.basic(),
        resources = resources ?? [];
}

class Question {
  String questionText;
  List<String> options;
  int correctAnswerIndex;

  late TextEditingController questionController;
  late List<TextEditingController> optionControllers;

  Question({
    this.questionText = '',
    List<String>? options,
    this.correctAnswerIndex = 0,
  }) : options = options ?? List.filled(4, '') {
    questionController = TextEditingController(text: questionText);
    optionControllers = List.generate(
      4,
          (i) => TextEditingController(text: this.options[i]),
    );
  }

  void syncValues() {
    questionText = questionController.text;
    for (int i = 0; i < options.length; i++) {
      options[i] = optionControllers[i].text;
    }
  }

  void dispose() {
    questionController.dispose();
    for (var controller in optionControllers) {
      controller.dispose();
    }
  }
}
