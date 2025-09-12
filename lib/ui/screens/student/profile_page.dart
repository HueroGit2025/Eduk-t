import 'package:eudkt/services/shared_preference.dart';
import 'package:eudkt/ui/widgets/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import '../../../resources/colors.dart';
import '../../../services/app_snackbar.dart';
import '../../state_management/completed_courses/completed_courses_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:html' as html;

import '../../widgets/help_view.dart';


class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  @override
  void initState() {
    super.initState();
    context.read<CompletedCoursesCubit>().loadCompletedCourses(
      SharedPreferencesService.enrollment!,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.sizeOf(context).width < 900;
    bool isMobile = MediaQuery.sizeOf(context).width < 600;
    double width = MediaQuery.sizeOf(context).width;
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    return ListView(
      children: [
        Stack(
            children: [
              SvgPicture.asset(
                'assets/banner-tics.svg',
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
                width: width,
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40,vertical: 130),
                child: Container(
                  padding: const EdgeInsets.only(top: 80, bottom: 30),
                  decoration: BoxDecoration(
                    color: isDark ? dark2 : Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 30,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        SharedPreferencesService.name!,
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Carrera: ${SharedPreferencesService.career!}",
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Matricula: ${SharedPreferencesService.enrollment!}",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 25),
                       Text(
                        "Cursos completados",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: BlocListener<CompletedCoursesCubit, CompletedCoursesState>(
                          listener: (context, state) {
                            if (state is Error) {
                              AppSnackBar.showError(state.message);
                            }
                          },
                          child: BlocBuilder<CompletedCoursesCubit, CompletedCoursesState>(
                          builder: (context, state) {
                            if (state is Loading) {
                              return const Center(child: CircularProgressIndicator());
                            } else if (state is Empty) {
                              return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Image(
                                        height: 100,
                                        image: AssetImage('assets/empty-box.png'),
                                      ),
                                      const Text(
                                        "Aún no has completado ningún curso.",
                                        style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: Colors.grey),

                                      ),
                                    ],
                                  ));
                            } else if (state is CoursesLoaded) {
                              final courses = state.courses;
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 30),
                                child: GridView.count(
                                  crossAxisCount: isMobile ? 2 : isTablet ? 4 : 6,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 15,
                                  mainAxisSpacing: 15,
                                  childAspectRatio: 1,
                                  children: courses.map((c) => _courseCard(c.name, c.imageUrl,c.certificateUrl)).toList(),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                        ),

                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        icon: Icon(Icons.output_rounded,color: Colors.white,),
                        onPressed: () {
                          SharedPreferencesService.logout();
                          context.go('/');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryBlue,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        label: Text(
                          "Cerrar sesión",
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                    ],
                  ),
                ),
              ),

              Positioned(
                top: 90,
                left: MediaQuery.of(context).size.width / 2 - 40,
                child: ProfileAvatar(imageUrl: SharedPreferencesService.image!,
                  onImageUpdated: () => setState(() {}),),
              ),

              Positioned(
                  top: 140,
                  right: 50,
                  child: IconButton(
                      onPressed: (){
                        showHelpOverlay(context);
                      },
                      icon: Icon(Icons.help_rounded, color: secondaryBlue,))
              )
            ],
        ),
      ],
    );
  }

  Widget _courseCard(String title, String imageUrl, downloadUrl) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: (){
          html.AnchorElement anchorElement = html.AnchorElement(href: downloadUrl)
            ..download = "certificado.pdf"
            ..target = "_blank";
          anchorElement.click();
        },
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(
                  imageUrl,
                ),),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 5),
                  ),
                ],
              ),

            ),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.black26,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis
                    ),


                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


