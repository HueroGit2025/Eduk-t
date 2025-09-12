import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eudkt/services/pdf_maker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../../services/shared_preference.dart';
part 'course_view_state.dart';

class CourseViewCubit extends Cubit<CourseViewState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  final String courseId;
  final String studentId = SharedPreferencesService.enrollment!;

  StreamSubscription? _modulesSubscription;
  final Map<String, StreamSubscription> _subjectSubscriptions = {};
  final Map<String, StreamSubscription> _evaluationSubscriptions = {};

  CourseViewCubit({
    required this.courseId,
  }) : super(CourseViewState());

  /// Cargar curso + progreso inicial
  Future<void> loadCourse() async {
    emit(state.copyWith(loading: true));
    try {
      final courseDoc = await firestore
          .collection('courses')
          .doc(courseId)
          .get();
      final Map<String, dynamic> courseData = Map<String, dynamic>.from(
          courseDoc.data() ?? {});

      final progressDoc = await firestore
          .collection('progress')
          .doc(courseId)
          .collection('students')
          .doc(studentId)
          .get();
      final Map<String, dynamic> progressData = Map<String, dynamic>.from(
          progressDoc.data() ?? {});

      final modulesSnapshot = await firestore
          .collection('courses')
          .doc(courseId)
          .collection('modules')
          .get();

      final Map<String, dynamic> modulesData = {};
      for (var moduleDoc in modulesSnapshot.docs) {
        final moduleId = moduleDoc.id;
        final moduleMap = Map<String, dynamic>.from(moduleDoc.data());

        /// Subjects
        final subjectsSnapshot = await moduleDoc.reference.collection(
            'subjects').get();
        final Map<String, dynamic> subjectsData = {
          for (var s in subjectsSnapshot.docs) s.id: Map<String, dynamic>.from(
              s.data())
        };

        /// Evaluación
        final evalSnapshot = await moduleDoc.reference
            .collection('evaluation')
            .doc('data')
            .get();
        final Map<String, dynamic>? evalData = evalSnapshot.exists
            ? Map<String, dynamic>.from(evalSnapshot.data()!)
            : null;

        moduleMap['subjects'] = subjectsData;
        moduleMap['evaluation'] = evalData;

        modulesData[moduleId] = moduleMap;
      }
      courseData['modules'] = modulesData;

      /// Restaurar posición desde `status` si existe
      int initialUnit = 0;
      int initialSubject = 0;
      bool initialIsEval = false;

      final status = Map<String, dynamic>.from(progressData['status'] ?? {});
      if (status.isNotEmpty) {
        final int su = (status['unity'] is int) ? status['unity'] : 0;
        final int ss = (status['subject'] is int) ? status['subject'] : 0;
        final bool se = status['evaluation'] == true;

        final modulesKeys = modulesData.keys.toList();
        if (modulesKeys.isNotEmpty) {
          initialUnit = su.clamp(0, modulesKeys.length - 1);
          final currentSubjects = (modulesData[modulesKeys[initialUnit]]['subjects'] as Map<String, dynamic>? ?? {});
          final maxSubjectIndex = currentSubjects.isEmpty ? 0 : currentSubjects.length - 1;
          initialSubject = ss.clamp(0, maxSubjectIndex);
          initialIsEval = se;
        }
      }

      emit(state.copyWith(
        courseData: courseData,
        progressData: progressData,
        currentUnit: initialUnit,
        currentSubject: initialSubject,
        isEvaluation: initialIsEval,
        loading: false,
      ));

      if(initialIsEval){
        _getSubmission();
      }

      /// Escucha activa de módulos, subjects y evaluaciones
      _listenModulesProgress();
    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  /// Escucha activa por módulo, subject y evaluación
  void _listenModulesProgress() {
    _modulesSubscription?.cancel();

    final modulesStream = firestore
        .collection('progress')
        .doc(courseId)
        .collection('students')
        .doc(studentId)
        .collection('modules')
        .snapshots();

    _modulesSubscription = modulesStream.listen((moduleSnapshots) async {
      final Map<String, dynamic> newProgressData = {};

      for (var moduleDoc in moduleSnapshots.docs) {
        final moduleId = moduleDoc.id;
        final moduleData = Map<String, dynamic>.from(moduleDoc.data());

        /// Subjects
        _subjectSubscriptions[moduleId]?.cancel();
        final subjectsStream = moduleDoc.reference
            .collection('subjects')
            .snapshots();
        _subjectSubscriptions[moduleId] =
            subjectsStream.listen((subjectSnapshots) {
              final Map<String, dynamic> subjectsData = {
                for (var s in subjectSnapshots.docs) s.id: Map<String,
                    dynamic>.from(s.data())
              };

              final currentProgress = Map<String, dynamic>.from(
                  state.progressData?['modules'] ?? {});
              currentProgress[moduleId] =
              Map<String, dynamic>.from(currentProgress[moduleId] ?? {});
              currentProgress[moduleId]['subjects'] =
              Map<String, dynamic>.from(subjectsData);

              /// mantener el resto del progressData y status
              final merged = Map<String, dynamic>.from(
                  state.progressData ?? {});
              merged['modules'] = currentProgress;
              emit(state.copyWith(progressData: merged));
            });

        /// Evaluación
        _evaluationSubscriptions[moduleId]?.cancel();
        final evalStream = moduleDoc.reference.collection('evaluation').doc(
            'data').snapshots();
        _evaluationSubscriptions[moduleId] = evalStream.listen((evalSnapshot) {
          final evalData = evalSnapshot.exists ? Map<String, dynamic>.from(
              evalSnapshot.data()!) : null;

          final currentProgress = Map<String, dynamic>.from(
              state.progressData?['modules'] ?? {});
          currentProgress[moduleId] = currentProgress[moduleId] ?? {};
          currentProgress[moduleId]['evaluation'] =
          evalData != null ? Map<String, dynamic>.from(evalData) : null;

          /// mantener el resto del progressData y status
          final merged = Map<String, dynamic>.from(state.progressData ?? {});
          merged['modules'] = currentProgress;
          emit(state.copyWith(progressData: merged));
        });

        /// Guardar módulo temporal
        newProgressData[moduleId] = moduleData;
      }
    });
  }

  /// Selección de tema
  void selectTopic(int unitIndex, int subjectIndex) {
    emit(state.copyWith(currentUnit: unitIndex, currentSubject: subjectIndex));
    _exitEvaluation(fromDrawer: true);

    _updateStatusFields(
        unity: unitIndex, subject: subjectIndex, evaluation: false);
  }

  /// Selección de Evaluación
  void selectEvaluation(int unitIndex) {
    emit(state.copyWith(currentUnit: unitIndex, isEvaluation: true));
    _updateStatusFields(unity: unitIndex, evaluation: true);
    _getSubmission();
  }

  /// Salida de Evaluación
  void _exitEvaluation({bool fromDrawer = false}) {
    emit(state.copyWith(isEvaluation: false));
  }

  /// Retroceder (tema o evaluación)
  void goToPrevious() {
    final modules = state.courseData?['modules'] as Map<String, dynamic>? ?? {};
    if (modules.isEmpty) return;

    int currentUnit = state.currentUnit;
    int currentSubject = state.currentSubject;

    if (state.isEvaluation) {
      final lastIndex = (modules.values.elementAt(
          currentUnit)['subjects'] as Map<String, dynamic>).length - 1;
      emit(state.copyWith(isEvaluation: false, currentSubject: lastIndex));
      _updateStatusFields(
          unity: currentUnit, subject: lastIndex, evaluation: false);
      return;
    }

    if (currentSubject > 0) {
      emit(state.copyWith(currentSubject: currentSubject - 1));
      _updateStatusFields(
          unity: currentUnit, subject: currentSubject - 1, evaluation: false);
    } else if (currentUnit > 0) {
      /// Ir al examen de la unidad anterior si existe
      final prevUnitSubjects = modules.values.elementAt(
          currentUnit - 1)['subjects'] as Map<String, dynamic>? ?? {};
      final hasEvaluation = (modules.values.elementAt(
          currentUnit - 1)['evaluation'] != null);
      final newSubject = hasEvaluation ? -1 : prevUnitSubjects.length - 1;
      emit(state.copyWith(
        currentUnit: currentUnit - 1,
        currentSubject: newSubject,
        isEvaluation: hasEvaluation,
      ));
      _updateStatusFields(unity: currentUnit - 1,
          subject: newSubject < 0 ? 0 : newSubject,
          evaluation: hasEvaluation);
    }

    /// Si es la primera unidad y primer tema, no hacer nada
  }

  /// Avanzar (tema o evaluación)
  Future<void> goToNext() async {
    final modules = state.courseData?['modules'] as Map<String, dynamic>? ?? {};

    int currentUnit = state.currentUnit;
    int currentSubject = state.currentSubject;

    final currentUnitKey = modules.keys.elementAt(currentUnit);
    final currentUnitData = modules[currentUnitKey] as Map<String, dynamic>;
    final subjects = currentUnitData['subjects'] as Map<String, dynamic>? ?? {};

    if (state.isEvaluation) {
      final evalFinished = (state.progressData?['modules'][currentUnitKey]['evaluation']['finished']) == true;
      if (!evalFinished) {
        await _processEvaluation(currentUnitKey, currentUnitData['evaluation']);
      }else{
        if (currentUnit + 1 < modules.length) {
          emit(state.copyWith(currentUnit: currentUnit + 1, currentSubject: 0, isEvaluation: false));
          _updateStatusFields(unity: currentUnit + 1, subject: 0, evaluation: false);
        }
        emit(state.copyWith(info: 'Fin del curso.'));
      }
      return;
    }

    /// Avanzar al siguiente tema
    final subjectKeys = subjects.keys.toList();

    final currentSubjectKey = (currentSubject >= 0 && currentSubject < subjectKeys.length)
        ? subjectKeys[currentSubject]
        : subjectKeys.first;

    final subjectProgress = (state.progressData?['modules']?[currentUnitKey]?['subjects']?[currentSubjectKey]?['completed']) ?? false;

    if (!subjectProgress) {
      await _markSubjectCompleted(currentUnitKey, currentSubjectKey);
    }

    if (currentSubject + 1 < subjects.length) {
      emit(state.copyWith(currentSubject: currentSubject + 1));
      _updateStatusFields(unity: currentUnit, subject: currentSubject + 1, evaluation: false);

    } else if (currentUnitData['evaluation'] != null) {
      emit(state.copyWith(isEvaluation: true));
      _updateStatusFields(unity: currentUnit, evaluation: true);
      _getSubmission();
    } else if (currentUnit + 1 < modules.length) {
      emit(state.copyWith(currentUnit: currentUnit + 1, currentSubject: 0));
      _updateStatusFields(unity: currentUnit + 1, subject: 0, evaluation: false);
    }
  }

  /// Obtener la información de la submission
  Future<void> _getSubmission() async {
    final modules = state.courseData?['modules'] as Map<String, dynamic>? ?? {};
    final currentUnitKey = modules.keys.elementAt(state.currentUnit);

    final query = await firestore
        .collection('course_projects')
        .doc(courseId)
        .collection('submissions')
        .where('student_id', isEqualTo: studentId)
        .where('unity_id', isEqualTo: currentUnitKey)
        .get();

    final submission = query.docs.isNotEmpty ? query.docs.first.data() : null;
    submission?.addEntries(<String, dynamic>{'id': query.docs.first.id}.entries);
    emit(state.copyWith(submissionData: submission));

  }

  /// Actualiza una respuesta en el state
  void updateAnswer(String qId, int selectedIndex) {
    final newAnswers = Map<String, int>.from(state.answers);
    newAnswers[qId] = selectedIndex;
    emit(state.copyWith(answers: newAnswers));
  }

  /// Seleccionar un archivo
  void selectProjectFile(fileName, file) {
    emit(state.copyWith(
      selectedFileName: fileName,
      selectedFile: file,
    ));
  }

  /// Limpiar archivo seleccionado
  void removeProjectFile() {
    emit(state.copyWith(
      selectedFileName: null,
      selectedFile: null,
    ));
  }

  /// Proceso de evaluación
  Future<void> _processEvaluation(String unitId, Map<String, dynamic>? evaluation) async {
    final modules = state.courseData?['modules'] as Map<String, dynamic>? ?? {};
    int currentUnit = state.currentUnit;

    if(evaluation?['type'] == 'project' ){
      if(state.selectedFile == null){
        emit(state.copyWith(error: 'Debes subir un archivo.'));
        return;
      }
      String projectUrl = await _uploadFile(state.selectedFile!, 'proyects/$courseId/$unitId/$studentId');

      /// Guardar proyecto en Firestore
      await FirebaseFirestore.instance.collection('course_projects')
          .doc(courseId)
          .collection('submissions')
          .add({
        'unity_id': unitId,
        'student_id': studentId,
        'url': projectUrl,
        'status': 'pending',
      });

      /// Marcar evaluación como completada en Firestore
      await _markEvaluationCompleted(unitId, 0);

      if (currentUnit + 1 < modules.length) {
        emit(state.copyWith(currentUnit: currentUnit + 1, currentSubject: 0, isEvaluation: false));
        _updateStatusFields(unity: currentUnit + 1, subject: 0, evaluation: false);
      }

      return;
    }

    final questions = evaluation?["questions"] as List<dynamic>? ?? [];

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i] as Map<String, dynamic>;
      final qId = (q['id'] ?? i).toString();
      if (!state.answers.containsKey(qId) || state.answers[qId] == null) {
        emit(state.copyWith(
            error: "Debes responder todas las preguntas antes de continuar."));
        return;
      }
    }

    int correct = 0;

    for (int i = 0; i < questions.length; i++) {
      final q = questions[i] as Map<String, dynamic>;
      final qId = (q['id'] ?? i).toString();

      final int? correctAnswer = q['correct_answer'] as int?;
      final int? studentAnswer = state.answers[qId] as int?;

      if (studentAnswer != null && correctAnswer != null && studentAnswer == correctAnswer) {
        correct++;
      }
    }

    final score = ((correct / questions.length) * 100).round();

    if (score < 70) {
      emit(state.copyWith(
          error: "No alcanzaste la calificación mínima (70). Tu calificación fue $score."));
      return;
    }

    /// Marcar evaluación como completada en Firestore
    await _markEvaluationCompleted(unitId, score);

    /// Limpiar respuestas y salir de evaluación
    if (currentUnit + 1 < modules.length) {

      emit(state.copyWith(currentUnit: currentUnit + 1, currentSubject: 0, isEvaluation: false, answers: {}));
      _updateStatusFields(unity: currentUnit + 1, subject: 0, evaluation: false);
    }
    emit(state.copyWith(answers: {},));
  }

  Future<String> _uploadFile(PlatformFile file, String route) async {
    final fileBytes = file.bytes;
    final fileName = 'project_$studentId.${file.extension}';
    final mType = mimeType(fileName);

    final ref = _storage.ref('$route/$fileName');
    final metadata = SettableMetadata(contentType: mType);

    await ref.putData(fileBytes!, metadata);

    return await ref.getDownloadURL();
  }

  String mimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();

    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'mp4':
        return 'video/mp4';
      case 'webm':
        return 'video/webm';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'ppt':
        return 'application/vnd.ms-powerpoint';
      case 'pptx':
        return 'application/vnd.openxmlformats-officedocument.presentationml.presentation';
      case 'zip':
        return 'application/zip';
      case 'txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  /// Marcar tema completado
  Future<void> _markSubjectCompleted(String unitId, String subjectId) async {
    await firestore.collection('progress')
        .doc(courseId)
        .collection('students')
        .doc(studentId)
        .collection('modules')
        .doc(unitId)
        .collection('subjects')
        .doc(subjectId).set({
      'completed': true,
    }, SetOptions(merge: true));

    await _updateProgress(unitId, isEvaluation: false);
  }

  /// Resetear la evaluacion cuando se completa
  void resetEvaluationCompletedFlag() {
    emit(state.copyWith(evaluationCompleted: false));
  }

  /// Marcar evaluación completada
  Future<void> _markEvaluationCompleted(String unitId, int score) async {
    await firestore.collection('progress')
        .doc(courseId)
        .collection('students')
        .doc(studentId)
        .collection('modules')
        .doc(unitId)
        .collection('evaluation')
        .doc('data').set({
      'finished': true,
      'score': score,
    }, SetOptions(merge: true));

    await _updateProgress(unitId, isEvaluation: true);
  }

  /// Actualizar el progreso del curso
  Future<void> _updateProgress(String unitId, {bool isEvaluation = false}) async {
    final courseModules = state.courseData?['modules'] as Map<String,
        dynamic>? ?? {};

    /// Progreso por unidad
    final unitData = courseModules[unitId] as Map<String, dynamic>? ?? {};
    final subjectsCount = (unitData['subjects'] as Map<String, dynamic>? ?? {})
        .length;
    final totalItemsUnit = subjectsCount + 1;
    if (totalItemsUnit == 0) return;

    final unitProgressDoc = firestore.collection('progress')
        .doc(courseId)
        .collection('students')
        .doc(studentId)
        .collection('modules')
        .doc(unitId)
    ;

    final unitSnapshot = await unitProgressDoc.get();
    final unitProgressData = Map<String, dynamic>.from(
        unitSnapshot.data() ?? {});

    double unitProgress = (unitProgressData['unit_progress'] ?? 0).toDouble();
    final unitIncrement = (100 / totalItemsUnit);

    unitProgress += unitIncrement;
    if (unitProgress > 100) unitProgress = 100;

    await unitProgressDoc.set({
      'unit_progress': unitProgress,
    }, SetOptions(merge: true));

    /// Progreso global
    int totalItemsCourse = 0;
    for (var module in courseModules.values) {
      final subjCount = (module['subjects'] as Map<String, dynamic>? ?? {})
          .length;
      totalItemsCourse += subjCount + 1;
    }
    if (totalItemsCourse == 0) return;

    final globalDoc = firestore
        .collection('progress')
        .doc(courseId)
        .collection('students')
        .doc(studentId);

    final globalSnapshot = await globalDoc.get();
    final globalData = Map<String, dynamic>.from(globalSnapshot.data() ?? {});
    final status = Map<String, dynamic>.from(globalData['status'] ?? {});

    double totalProgress = (status['total_progress'] ?? 0).toDouble();
    final globalIncrement = (100 / totalItemsCourse);
    totalProgress += globalIncrement;
    if (totalProgress > 100) totalProgress = 100;

    status['total_progress'] = totalProgress;

    await globalDoc.set({
      'status': status,
    }, SetOptions(merge: true));

    final newProgressData = Map<String, dynamic>.from(state.progressData ?? {});
    final localStatus = Map<String, dynamic>.from(
        newProgressData['status'] ?? {});
    localStatus['total_progress'] = totalProgress;
    newProgressData['status'] = localStatus;
    emit(state.copyWith(progressData: newProgressData, evaluationCompleted: true));
  }

  /// Actualizar el estado del curso
  Future<void> _updateStatusFields({int? unity, int? subject, bool? evaluation}) async {
    final globalDoc = firestore
        .collection('progress')
        .doc(courseId)
        .collection('students')
        .doc(studentId);

    final snap = await globalDoc.get();
    final data = Map<String, dynamic>.from(snap.data() ?? {});
    final status = Map<String, dynamic>.from(data['status'] ?? {});

    if (unity != null) status['unity'] = unity;
    if (subject != null) status['subject'] = subject;
    if (evaluation != null) status['evaluation'] = evaluation;

    await globalDoc.set({'status': status}, SetOptions(merge: true));

    final newProgressData = Map<String, dynamic>.from(state.progressData ?? {});
    final localStatus = Map<String, dynamic>.from(newProgressData['status'] ?? {});
    if (unity != null) localStatus['unity'] = unity;
    if (subject != null) localStatus['subject'] = subject;
    if (evaluation != null) localStatus['evaluation'] = evaluation;
    newProgressData['status'] = localStatus;
    emit(state.copyWith(progressData: newProgressData));
  }

  /// Actualizar el estado del curso
  Future<void> finalizeCourse() async {
    try {
      final studentData = await firestore.collection('students').doc(studentId).get();

      final completedCourses = Map<String, dynamic>.from(studentData['completed_courses']);

      if(completedCourses[courseId] != null){
        emit(state.copyWith(info: 'Ya has finalizado este curso.'));
        return;
      }

      final progressData = state.progressData;

      final allOk = _allEvaluationsHaveScore(
        progressModules: (progressData?['modules'] as Map<String, dynamic>? ?? {}),
      );

      if (!allOk) {
        emit(state.copyWith(error: 'Aún hay evaluaciones sin calificación.'));
        return;
      }
      final courseModules = state.progressData?['modules'] as Map<String,
          dynamic>? ?? {};
      var score = 0.0;

      for (var module in courseModules.values) {
        score = score + (module['evaluation']?['score']);
      }
      score = score / courseModules.length;

      final globalDoc = firestore
          .collection('progress')
          .doc(courseId)
          .collection('students')
          .doc(studentId);

      final snap = await globalDoc.get();
      final data = Map<String, dynamic>.from(snap.data() ?? {});
      final status = Map<String, dynamic>.from(data['status'] ?? {});

      status['calification'] = score;
      await globalDoc.set({'status': status}, SetOptions(merge: true));

      firestore.collection('courses').doc(courseId).collection('graduates').doc(studentId).set({
        'student_id': studentId,
        'name': studentData['name'],
        'career': studentData['career'],
        'semester': studentData['semester'],
        'score': score,
      });

      final courseName = (state.courseData?['course_name'] ?? 'Curso');
      final Uint8List pdfBytes = await PDFMaker.generateCertificatePdfBytes(score, courseName);
      await _uploadCertificateAndSaveCompletedCourse(pdfBytes);

    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Verifica que las evaluaciones tengan calificación
  bool _allEvaluationsHaveScore({
    required Map<String, dynamic> progressModules,
  }) {
    for (final entry in progressModules.entries) {

      final unitData = entry.value as Map<String, dynamic>;
      final hasEval = unitData['evaluation'] != null;

      if (!hasEval) continue;

      final finished = unitData['evaluation']['finished'];
      final score = unitData['evaluation']['score'];

      if (!finished || score == 0) {
        return false;
      }
    }
    return true;
  }

  /// Sube el PDF a Storage
  Future<void> _uploadCertificateAndSaveCompletedCourse(Uint8List pdfBytes) async {
    final storage = FirebaseStorage.instance;

    final fileName = '${courseId}_$studentId.pdf';
    final ref = storage.ref().child('certificates/$courseId/$fileName');

    await ref.putData(
      pdfBytes,
      SettableMetadata(contentType: 'application/pdf'),
    );

    final url = await ref.getDownloadURL();

    /// Guardar en el alumno el mapa de cursos completados
    await firestore.collection('students').doc(studentId).set({
      'completed_courses': {courseId: url},
    }, SetOptions(merge: true));
  }


  void clearError() {
    emit(state.copyWith(error: null));
  }

  void clearInfo() {
    emit(state.copyWith(info: null));
  }

  void clearSuccessInfo() {
    emit(state.copyWith(successInfo: null));
  }

  @override
  Future<void> close() {
    _modulesSubscription?.cancel();
    _subjectSubscriptions.forEach((_, sub) => sub.cancel());
    _evaluationSubscriptions.forEach((_, sub) => sub.cancel());
    return super.close();
  }
}
