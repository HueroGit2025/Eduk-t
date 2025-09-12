import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'supervisor_dashboard_state.dart';

class SupervisorDashboardCubit extends Cubit<SupervisorDashboardState> {
  StreamSubscription? _studentsSubscription;
  StreamSubscription? _teachersSubscription;
  //StreamSubscription? _coursesSubscription;
  StreamSubscription? _postsSubscription;
  final _firestore = FirebaseFirestore.instance;


  SupervisorDashboardCubit() : super (SupervisorDashboardState()){
    _loadAllData();
  }


  void _loadAllData() {
    subscribeStudents();
    subscribeTeachers();
    subscribePosts();

  }

  Future<void> subscribeStudents({String? career}) async {
    _studentsSubscription?.cancel();
    emit(state.copyWith(isLoadingStudents: true));

    try {
      _studentsSubscription = _firestore.collection('students')
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
        emit(state.copyWith(students: students, isLoadingStudents: false));
      });

    } catch (e) {
      emit(state.copyWith(
        isLoadingStudents: false,
        errorMessage: 'Error cargando estudiantes: $e',
      ));
    }


  }

  Future<void> subscribeTeachers({String? career}) async {
    _teachersSubscription?.cancel();
    emit(state.copyWith(isLoadingTeachers: true));

    try {

      _teachersSubscription = _firestore.collection('teacher').snapshots().listen(
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
                    courseNames[courseId] = courseData['course_name'] ?? 'Curso sin nombre';
                    filteredCourses.add(courseId);
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

        emit(state.copyWith(teachers: teachers, isLoadingTeachers: false));
      });
    } catch (e) {
      emit(state.copyWith(
        isLoadingTeachers: false,
        errorMessage: 'Error cargando docentes: $e',
      ));
    }
  }

  Future<void> subscribePosts({String? career}) async {
    emit(state.copyWith(isLoadingPosts: true));

    _postsSubscription?.cancel();

    final query = FirebaseFirestore.instance.collection('publications');
    final stream = (career != null && career.isNotEmpty)
        ? query.where('career', isEqualTo: career).snapshots()
        : query.snapshots();

    _postsSubscription = stream.listen((snapshot) {
      final posts = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      emit(state.copyWith(posts: posts, isLoadingPosts: false));

    }, onError: (e) {
      emit(state.copyWith(
        isLoadingTeachers: false,
        errorMessage: 'Error al cargar aportes: $e',
      ));
    });
  }



}