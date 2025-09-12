import 'package:eudkt/services/shared_preference.dart';
import 'package:eudkt/ui/screens/auth/supervisor_login.dart';
import 'package:eudkt/ui/screens/supervisor/supervisor_home.dart';
import 'package:eudkt/ui/screens/teacher/course_teacher_page.dart';
import 'package:eudkt/ui/widgets/read_only_course/read_only_course.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/screens/admin/admin_home.dart';
import '../ui/screens/auth/admin_login.dart';
import '../ui/screens/auth/login.dart';
import '../ui/screens/student/course_page.dart';
import '../ui/screens/student/students_main.dart';
import '../ui/screens/teacher/course_creator.dart';
import '../ui/screens/teacher/teacher_main.dart';

final routes =  GoRouter(
  debugLogDiagnostics: true,
  initialLocation: '/',
  redirect: (context, state) {

    final role = SharedPreferencesService.role;

    final isAuth = (role != null) ? true : false;
    final location = state.matchedLocation;

    returnRoutes(){
      if(role == 'admin' || role == 'supervisor'){
        return '/$role/home';
      }else{
        return '/$role';
      }
    }


    if (!isAuth && location != '/admin' && location != '/' && location != '/supervisor') {
      return '/';
    }

    if (isAuth) {
      if (location.startsWith('/students') && role != 'students') return returnRoutes();

      if (location.startsWith('/teacher') && role != 'teacher') return returnRoutes();

      if (location.startsWith('/admin/home') && role != 'admin') return returnRoutes();

      if (location.startsWith('/supervisor/home') && role != 'supervisor') return returnRoutes();

      if (location.endsWith('/')) return returnRoutes();

    }

    return null;
  },
  routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const Login(),
        routes: [
          GoRoute(
              path: 'supervisor',
              builder: (context, state) => const SupervisorLogin(),
              routes: [
                GoRoute(
                  path: 'home',
                  builder: (context, state) => const SupervisorHome(),
                  routes: [
                    GoRoute(
                      path: '/course/:courseId',
                      builder: (context, state) {
                        final courseId = state.pathParameters['courseId']!;
                        return ReadOnlyCourse(courseId: courseId);
                      },
                    ),
                  ]
                ),

              ]
          ),
          GoRoute(
              path: 'admin',
              builder: (context, state) => const AdminLogin(),
              routes: [
                GoRoute(
                  path: 'home',
                  builder: (context, state) => const AdminHome(),
                  routes: [
                    GoRoute(
                      path: '/course/:courseId',
                      builder: (context, state) {
                        final courseId = state.pathParameters['courseId']!;
                        return ReadOnlyCourse(courseId: courseId);
                      },
                    ),
                  ]

                ),


              ]
          ),
          GoRoute(
            path: 'students',
            builder: (context, state) => const StudentsMain(),

            routes: [
              GoRoute(
                path: '/course/:courseId',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  return CoursePage(courseId: courseId);
                },
              ),
            ],
          ),
          GoRoute(
            path: 'teacher',
            builder: (context, state) => const TeacherMain(),
            routes: [
              GoRoute(
                path: 'coursecreator',
                builder: (context, state) => const CourseCreator(),

              ),
              GoRoute(
                path: '/course/:courseId',
                builder: (context, state) {
                  final courseId = state.pathParameters['courseId']!;
                  return CourseTeacherPage(courseId: courseId);
                },
              ),
            ],
          ),
        ]
    ),
  ],
  errorBuilder: (context, state) => const Scaffold(
    body: Center(child: Text('Página no encontrada - Error 404')),
  ),
);

