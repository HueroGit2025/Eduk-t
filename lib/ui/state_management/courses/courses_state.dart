part of 'courses_cubit.dart';

sealed class CoursesState  {}

final class CourseInitial extends CoursesState {}

class CourseLoading extends CoursesState {}

class CourseLoaded extends CoursesState {
  final List<Map<String, dynamic>> courses;

  CourseLoaded(this.courses);
}

class CourseEmpty extends CoursesState {}

class CourseError extends CoursesState {
  final String message;

  CourseError(this.message);
}

