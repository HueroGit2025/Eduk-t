
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'completed_courses_state.dart';

class CompletedCoursesCubit extends Cubit<CompletedCoursesState> {
  CompletedCoursesCubit() : super(Loading());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> loadCompletedCourses(String studentId) async {
    emit(Loading());

    try {
      final studentDoc = await _firestore.collection('students').doc(studentId).get();

      if (!studentDoc.exists || studentDoc.data()?['completed_courses'] == null) {
        emit(Empty());
        return;
      }

      final completed = Map<String, dynamic>.from(studentDoc['completed_courses']);
      List<CourseCompleted> courses = [];

      for (final entry in completed.entries) {
        final courseId = entry.key;
        final certificateUrl = entry.value;

        final courseDoc = await _firestore.collection('courses').doc(courseId).get();
        if (courseDoc.exists) {
          final data = courseDoc.data()!;
          courses.add(
            CourseCompleted(
              id: courseId,
              name: data['course_name'] ?? 'Curso sin nombre',
              imageUrl: data['image'] ?? '',
              certificateUrl: certificateUrl,
            ),
          );
        }
      }

      if (courses.isEmpty) {
        emit(Empty());
      } else {
        emit(CoursesLoaded(courses));
      }
    } catch (e) {
      emit(Error("Error al cargar cursos: $e"));
    }
  }
}

class CourseCompleted extends Equatable {
  final String id;
  final String name;
  final String imageUrl;
  final String certificateUrl;

  const CourseCompleted({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.certificateUrl,
  });

  @override
  List<Object?> get props => [id, name, imageUrl, certificateUrl];
}

