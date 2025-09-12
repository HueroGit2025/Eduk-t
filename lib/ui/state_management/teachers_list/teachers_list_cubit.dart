import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/shared_preference.dart';

class TeachersListCubit extends Cubit<List<Map<String, dynamic>>> {
  TeachersListCubit() : super([]);

  final _firestore = FirebaseFirestore.instance;
  StreamSubscription? _subscription;

  void listenTeachers() async {
    _subscription?.cancel();
    _subscription = _firestore.collection('teacher').snapshots().listen(
      (snapshot) async {
        final futures = snapshot.docs.map((doc) async {
          final teacherData = doc.data();
          final teacherId = doc.id;
          final List<dynamic> courses = teacherData['courses'] ?? [];

          final Map<String, dynamic> courseNames = {};
          final List<String> filteredCourses = [];

          for (final courseId in courses) {
            final courseDoc =
                await _firestore.collection('courses').doc(courseId).get();
            final courseData = courseDoc.data();

            if (courseData != null) {
              final courseCareer = courseData['career'];
              if (courseCareer == SharedPreferencesService.career) {
                courseNames[courseId] =
                    courseData['course_name'] ?? 'Curso sin nombre';
                filteredCourses.add(courseId);
              }
            }
          }

          return {
            'id': teacherId,
            'name': teacherData['name'] ?? '',
            'image': teacherData['image'] ?? '',
            'courses': filteredCourses,
            'courseNames': courseNames,
          };
        });

        final teachers = await Future.wait(futures);
        emit(teachers);
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
