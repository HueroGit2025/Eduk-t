import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'course_teacher_view_state.dart';

class CourseTeacherViewCubit extends Cubit<CourseTeacherViewState> {
  final String courseId;
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  StreamSubscription? _submissionsSubscription;

  CourseTeacherViewCubit({required this.courseId}) : super(CourseTeacherViewState());

  /// Cargar curso
  Future<void> loadCourse() async {
    emit(state.copyWith(loading: true));
    try {
      final courseDoc = await firestore
          .collection('courses')
          .doc(courseId)
          .get();
      final Map<String, dynamic> courseData = Map<String, dynamic>.from(
          courseDoc.data() ?? {});


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
        final subjectsSnapshot = await moduleDoc.reference.collection('subjects').get();
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

      int initialUnit = 0;
      int initialSubject = 0;
      bool initialIsEval = false;

      emit(state.copyWith(
        courseData: courseData,
        currentUnit: initialUnit,
        currentSubject: initialSubject,
        isEvaluation: initialIsEval,
        loading: false,
      ));

    } catch (e) {
      emit(state.copyWith(error: e.toString(), loading: false));
    }
  }

  /// Selección de tema
  void selectTopic(int unitIndex, int subjectIndex) {
    emit(state.copyWith(currentUnit: unitIndex, currentSubject: subjectIndex));
    _exitEvaluation(fromDrawer: true);
  }

  /// Selección de Evaluación
  void selectEvaluation(int unitIndex) {
    emit(state.copyWith(currentUnit: unitIndex, isEvaluation: true));
    _getSubmissions();
  }

  /// Salida de Evaluación
  void _exitEvaluation({bool fromDrawer = false}) {
    emit(state.copyWith(isEvaluation: false, submissionsData: null));
  }

  /// Obtener submissiones
  Future<void> _getSubmissions() async {
    await _submissionsSubscription?.cancel();

    final modules = state.courseData?['modules'] as Map<String, dynamic>? ?? {};
    final currentUnitKey = modules.keys.elementAt(state.currentUnit);

    _submissionsSubscription = firestore
        .collection('course_projects')
        .doc(courseId)
        .collection('submissions')
        .where('unity_id', isEqualTo: currentUnitKey)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((query) async {
      final Map<String, dynamic> submissions = {};

      for (var doc in query.docs) {
        final data = doc.data();
        final studentId = data['student_id'];

        final studentSnap =
        await firestore.collection('students').doc(studentId).get();
        final studentName = studentSnap.data()?['name'] ?? "Sin nombre";

        submissions[doc.id] = {
          ...data,
          'id': doc.id,
          'student_name': studentName,
        };
      }

      emit(state.copyWith(submissionsData: submissions));
    });
  }

  /// Aprobación de proyecto
  Future<void> approveProject(String submissionId, Map<String, dynamic> submission, String score)async {
    try{
      final doubleScore = double.tryParse(score) ?? 0.0;
      await firestore
          .collection('course_projects')
          .doc(courseId)
          .collection('submissions')
          .doc(submissionId).update({
        'status': 'approved',
      });

      await firestore
          .collection('progress')
          .doc(courseId)
          .collection('students')
          .doc('${submission['student_id']}')
          .collection('modules')
          .doc('${submission['unity_id']}')
          .collection('evaluation')
          .doc('data')
          .update({
        'score': doubleScore,
      });
      emit(state.copyWith(successMessage: 'Curso aprobado correctamente'));

    }catch(e){
      emit(state.copyWith(error: 'Error al aprobar el proyecto'));
    }




  }

  /// Desaprobación de proyecto
  Future<void> reproveProject(String submissionId, Map<String, dynamic> submission, String feedback)async {
    try{

      await firestore
          .collection('course_projects')
          .doc(courseId)
          .collection('submissions')
          .doc(submissionId).update({
        'status': 'rejected',
        'feedback': feedback,
      });

      await firestore
          .collection('progress')
          .doc(courseId)
          .collection('students')
          .doc('${submission['student_id']}')
          .collection('modules')
          .doc('${submission['unity_id']}')
          .collection('evaluation')
          .doc('data')
          .update({
        'finished': false,
      });
      emit(state.copyWith(successMessage: 'Curso desaprobado con exito'));

    }catch(e){
      emit(state.copyWith(error: 'Error al actualizar el reporte'));
    }
  }

  /// Activar curso
  Future<void> activeCourse() async {
    try {
      await firestore
          .collection('courses')
          .doc(courseId)
          .update({
        'is_active': true,
      });
      emit(state.copyWith(successMessage: 'Curso activado correctamente'));
    } catch (e) {
      emit(state.copyWith(error: 'Error al activar el curso'));
    }

  }

  /// Limpiar mensaje de error
  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Limpiar mensaje de éxito
  void clearSuccessMessage() {
    emit(state.copyWith(successMessage: null));
  }

}
