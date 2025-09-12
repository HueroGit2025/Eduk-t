import 'package:eudkt/resources/routes.dart';
import 'package:eudkt/services/shared_preference.dart';
import 'package:eudkt/ui/state_management/add_user/add_user_cubit.dart';
import 'package:eudkt/ui/state_management/auth/auth_cubit.dart';
import 'package:eudkt/ui/state_management/community/community_cubit.dart';
import 'package:eudkt/ui/state_management/completed_courses/completed_courses_cubit.dart';
import 'package:eudkt/ui/state_management/course_upload/course_upload_cubit.dart';
import 'package:eudkt/ui/state_management/courses/courses_cubit.dart';
import 'package:eudkt/ui/state_management/theme/theme_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:url_strategy/url_strategy.dart';
import 'core/keys/scaffold_messenger_key.dart';
import 'firebase_options.dart';

void main() async{
  setPathUrlStrategy();  await SharedPreferencesService.init();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authCubit = AuthCubit();
  await authCubit.checkSession();
  runApp(
      MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ThemeCubit(),
        ),
        BlocProvider(
          create: (_) => AuthCubit(),
        ),
        BlocProvider(
          create: (_) => CoursesCubit(),
        ),
        BlocProvider(
          create: (_) => CommunityCubit(),
        ),
        BlocProvider(
          create: (_) => AddUserCubit(),
        ),
        BlocProvider(
          create: (_) => CourseUploadCubit(),
        ),
        BlocProvider(
          create: (_) => CompletedCoursesCubit(),
        ),
      ],
      child: const MyApp(),)

  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return MaterialApp.router(
            scaffoldMessengerKey: scaffoldMessengerKey,
            title: 'Eduk-T',
            debugShowCheckedModeBanner: false,
            routerConfig: routes,
            theme: state.themeData,
            localizationsDelegates: const [
              quill.FlutterQuillLocalizations.delegate,
            ]
        );
      },
    );
  }
}


