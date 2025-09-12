part of 'course_upload_cubit.dart';

abstract class CourseUploadState {}

class Initial extends CourseUploadState {}

class Validating extends CourseUploadState {}

class Error extends CourseUploadState {
  final String message;
  Error(this.message);
}

class Success extends CourseUploadState {}
