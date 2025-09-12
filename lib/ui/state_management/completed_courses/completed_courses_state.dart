part of 'completed_courses_cubit.dart';

abstract class CompletedCoursesState extends Equatable {
  const CompletedCoursesState();

  @override
  List<Object?> get props => [];
}

class Loading extends CompletedCoursesState {}

class Empty extends CompletedCoursesState {}

class CoursesLoaded extends CompletedCoursesState {
  final List<CourseCompleted> courses;

  const CoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class Error extends CompletedCoursesState {
  final String message;

  const Error(this.message);

  @override
  List<Object?> get props => [message];
}
