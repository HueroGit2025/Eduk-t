import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../services/shared_preference.dart';
part 'courses_state.dart';

class CoursesCubit extends Cubit<CoursesState> {

  CoursesCubit() : super(CourseInitial());
  StreamSubscription? _courseSubscription;


  void loadCourses({String? career}) {
    emit(CourseLoading());

    _courseSubscription?.cancel();

    final query = FirebaseFirestore.instance.collection('courses');
    Stream<QuerySnapshot> stream;

    if (career != null && career.isNotEmpty) {
      stream = query.where('career', isEqualTo: career)
          .where('is_active', isEqualTo: true).snapshots();
    } else {
      stream = query.where('is_active', isEqualTo: true).snapshots();
    }

    _courseSubscription = stream.listen((snapshot) {
      final courses = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      if (courses.isEmpty) {
        emit(CourseEmpty());
      } else {
        emit(CourseLoaded(courses));
      }
    }, onError: (error) {
      emit(CourseError('Error al cargar cursos: $error'));
    });
  }

  void loadAdminCourses() {
    String? career = SharedPreferencesService.career;
    emit(CourseLoading());

    _courseSubscription?.cancel();

    final query = FirebaseFirestore.instance.collection('courses');
    Stream<QuerySnapshot> stream;
    stream = query.where('career', isEqualTo: career)
        .where('is_active', isEqualTo: false).snapshots();

    _courseSubscription = stream.listen((snapshot) {
      final courses = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      if (courses.isEmpty) {
        emit(CourseEmpty());
      } else {
        emit(CourseLoaded(courses));
      }
    }, onError: (error) {
      emit(CourseError('Error al cargar cursos: $error'));
    });
  }


  @override
  Future<void> close() {
    _courseSubscription?.cancel();
    return super.close();
  }
}
