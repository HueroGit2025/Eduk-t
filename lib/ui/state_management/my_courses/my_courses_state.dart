part of 'my_courses_cubit.dart';

abstract class MyCoursesState {}

class MyCoursesLoading extends MyCoursesState {}

class MyCoursesEmpty extends MyCoursesState {}

class MyCoursesLoaded extends MyCoursesState {
  final List<Map<String, dynamic>> courses;
  MyCoursesLoaded(this.courses);
}

class MyCoursesError extends MyCoursesState {
  final String message;
  MyCoursesError(this.message);
}

