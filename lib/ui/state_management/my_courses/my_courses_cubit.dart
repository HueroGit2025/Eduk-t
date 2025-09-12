import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/shared_preference.dart';

part 'my_courses_state.dart';

class MyCoursesCubit extends Cubit<MyCoursesState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final String id = SharedPreferencesService.enrollment!;
  StreamSubscription? _subscription;

  MyCoursesCubit() : super(MyCoursesLoading());

  void startListeningStudents() {
    _subscription = firestore.collection('students').doc(id).snapshots().listen((snapshot) async {
      final data = snapshot.data();
      final List<dynamic> courseIds = data?['courses'] ?? [];

      if (courseIds.isEmpty) {
        emit(MyCoursesEmpty());
        return;
      }

      final List<Map<String, dynamic>> courses = [];

      for (final id in courseIds) {
        final doc = await firestore.collection('courses').doc(id).get();
        if (doc.exists) {
          final courseData = doc.data()!..['id'] = doc.id;
          courses.add(courseData);
        }
      }

      emit(MyCoursesLoaded(courses));
    }, onError: (e) {
      emit(MyCoursesError(e.toString()));
    });
  }

  void startListeningTeachers() {
    _subscription = firestore.collection('teacher').doc(id).snapshots().listen((snapshot) async {
      final data = snapshot.data();

      final List<dynamic> courseIds = data?['courses'] ?? [];

      if (courseIds.isEmpty) {
        emit(MyCoursesEmpty());
        return;
      }

      final List<Map<String, dynamic>> courses = [];

      for (final id in courseIds) {
        final doc = await firestore.collection('courses').doc(id).get();
        if (doc.exists) {
          final courseData = doc.data()!..['id'] = doc.id;
          courses.add(courseData);
        }
      }

      emit(MyCoursesLoaded(courses));
    }, onError: (e) {
      emit(MyCoursesError(e.toString()));
    });
  }


  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
