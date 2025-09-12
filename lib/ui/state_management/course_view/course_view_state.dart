part of 'course_view_cubit.dart';

class CourseViewState {
  final bool loading;
  final String? error;
  final Map<String, dynamic>? courseData;
  final Map<String, dynamic>? progressData;
  final int currentUnit;
  final int currentSubject;
  final bool isEvaluation;
  final Map<String, dynamic> answers;
  final bool evaluationCompleted;
  final String? info;
  final String? successInfo;
  final PlatformFile? selectedFile;
  final String? selectedFileName;
  final Map<String, dynamic>? submissionData;


  const CourseViewState({
    this.loading = false,
    this.error,
    this.courseData,
    this.progressData,
    this.currentUnit = 0,
    this.currentSubject = 0,
    this.isEvaluation = false,
    this.answers = const {},
    this.evaluationCompleted  = false,
    this.info,
    this.successInfo,
    this.selectedFile,
    this.selectedFileName,
    this.submissionData,

  });

  CourseViewState copyWith({
    bool? loading,
    String? error,
    Map<String, dynamic>? courseData,
    Map<String, dynamic>? progressData,
    int? currentUnit,
    int? currentSubject,
    bool? isEvaluation,
    Map<String, dynamic>? answers,
    bool? evaluationCompleted,
    String? info,
    String? successInfo,
    PlatformFile? selectedFile,
    String? selectedFileName,
    Map<String, dynamic>? submissionData,

  }) {
    return CourseViewState(
      loading: loading ?? this.loading,
      error: error,
      courseData: courseData ?? this.courseData,
      progressData: progressData ?? this.progressData,
      currentUnit: currentUnit ?? this.currentUnit,
      currentSubject: currentSubject ?? this.currentSubject,
      isEvaluation: isEvaluation ?? this.isEvaluation,
      answers: answers ?? this.answers,
      evaluationCompleted : evaluationCompleted  ?? this.evaluationCompleted,
      info: info,
      successInfo: successInfo,
      selectedFile: selectedFile,
      selectedFileName: selectedFileName,
      submissionData: submissionData ?? this.submissionData,

    );
  }
}
