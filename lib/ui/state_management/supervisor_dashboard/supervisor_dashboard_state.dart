part of 'supervisor_dashboard_cubit.dart';

class SupervisorDashboardState {
  final List<Map<String, dynamic>> students;
  final List<Map<String, dynamic>> teachers;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> posts;

  final bool isLoadingStudents;
  final bool isLoadingTeachers;
  final bool isLoadingCourses;
  final bool isLoadingPosts;

  final String? errorMessage;

  SupervisorDashboardState({
    this.students = const [],
    this.teachers = const [],
    this.courses = const [],
    this.posts = const [],
    this.isLoadingStudents = false,
    this.isLoadingTeachers = false,
    this.isLoadingCourses = false,
    this.isLoadingPosts = false,
    this.errorMessage,
  });

  SupervisorDashboardState copyWith({
    List<Map<String, dynamic>>? students,
    List<Map<String, dynamic>>? teachers,
    List<Map<String, dynamic>>? courses,
    List<Map<String, dynamic>>? posts,
    bool? isLoadingStudents,
    bool? isLoadingTeachers,
    bool? isLoadingCourses,
    bool? isLoadingPosts,
    String? errorMessage,
  }) {
    return SupervisorDashboardState(
      students: students ?? this.students,
      teachers: teachers ?? this.teachers,
      courses: courses ?? this.courses,
      posts: posts ?? this.posts,
      isLoadingStudents: isLoadingStudents ?? this.isLoadingStudents,
      isLoadingTeachers: isLoadingTeachers ?? this.isLoadingTeachers,
      isLoadingCourses: isLoadingCourses ?? this.isLoadingCourses,
      isLoadingPosts: isLoadingPosts ?? this.isLoadingPosts,
      errorMessage: errorMessage,
    );
  }
}
