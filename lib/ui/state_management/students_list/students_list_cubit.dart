import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eudkt/services/shared_preference.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StudentsListCubit extends Cubit<List<Map<String, dynamic>>> {
  StudentsListCubit() : super([]);

  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  void listenStudents() {
    _subscription?.cancel();
    _subscription = _firestore.collection('students')
        .where('career', isEqualTo: SharedPreferencesService.career)
        .snapshots().listen((snapshot) async {
      final futures = snapshot.docs.map((doc) async {
        final studentData = doc.data();
        final studentId = doc.id;
        final List<dynamic> courses = studentData['courses'] ?? [];

        final Map<String, dynamic> progressMap = {};
        final Map<String, dynamic> courseNames = {};

        for (final courseId in courses) {
          final progressDoc = await _firestore
              .collection('progress')
              .doc(courseId)
              .collection('students')
              .doc(studentId)
              .get();

          final progressData = progressDoc.data();
          if (progressData != null && progressData.containsKey('status')) {
            progressMap[courseId] = progressData['status']['total_progress'] ?? 0;
          } else {
            progressMap[courseId] = 0;
          }
          final courseDoc = await _firestore.collection('courses').doc(courseId).get();
          courseNames[courseId] = courseDoc.data()?['course_name'] ?? 'Curso sin nombre';
        }

        return {
          'id': studentId,
          'name': studentData['name'] ?? '',
          'career': studentData['career'] ?? '',
          'image': studentData['image'] ?? '',
          'courses': courses,
          'progress': progressMap,
          'courseNames': courseNames,
        };
      });

      final students = await Future.wait(futures);
      emit(students);
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
