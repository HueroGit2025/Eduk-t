part of 'course_teacher_view_cubit.dart';


class CourseTeacherViewState {
  final bool loading;
  final String? error;
  final Map<String, dynamic>? courseData;
  final int currentUnit;
  final int currentSubject;
  final bool isEvaluation;
  final Map<String, dynamic>? submissionsData;
  final String? successMessage;
  final bool isGraduates;


  const CourseTeacherViewState({
    this.loading = false,
    this.error,
    this.courseData,
    this.currentUnit = 0,
    this.currentSubject = 0,
    this.isEvaluation = false,
    this.submissionsData,
    this.successMessage,
    this.isGraduates = false,

  });

  CourseTeacherViewState copyWith({
    bool? loading,
    String? error,
    Map<String, dynamic>? courseData,
    int? currentUnit,
    int? currentSubject,
    bool? isEvaluation,
    Map<String, dynamic>? submissionsData,
    String? successMessage,
    bool? isGraduates,
  }) {
    return CourseTeacherViewState(
      loading: loading ?? this.loading,
      error: error,
      courseData: courseData ?? this.courseData,
      currentUnit: currentUnit ?? this.currentUnit,
      currentSubject: currentSubject ?? this.currentSubject,
      isEvaluation: isEvaluation ?? this.isEvaluation,
      submissionsData: submissionsData ?? this.submissionsData,
      successMessage: successMessage,
      isGraduates: isGraduates ?? this.isGraduates
    );
  }
}

