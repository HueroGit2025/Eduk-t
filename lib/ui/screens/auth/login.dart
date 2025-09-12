
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rive/rive.dart';

import '../../../resources/colors.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../../widgets/form.dart';
import '../../widgets/theme_toggle_button.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  LoginState createState() => LoginState();
}

class LoginState extends State<Login> with SingleTickerProviderStateMixin {
  bool isTeacher = false;
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleForm(bool teacherSelected) {
    setState(() {
      isTeacher = teacherSelected;
    });

    if (isTeacher) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    bool isMobile = MediaQuery.sizeOf(context).width < 600;
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: Stack(
        children: [

          if(!isMobile) SizedBox(
            height: height,
            child: RiveAnimation.asset(
                isDark ? 'assets/dark.riv': 'assets/light.riv',
              fit: BoxFit.cover,
            ),
          ),
          if(!isMobile) Positioned(
            left: 0,
            bottom: 0,
            child: SizedBox(
              height: height*.9,
              width: width*.9,
              child: RiveAnimation.asset(
                'assets/girl.riv',
                fit: BoxFit.contain,
              ),
            ),
          ),

          Container(
              padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 0 : 40,
                  vertical: 20
              ),
              width: width,
              child: Row(
                mainAxisAlignment: isMobile ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  SvgPicture.asset(
                      height: 40,
                      color: mainBlue,
                      'assets/LOGO.svg'
                  ),
                  SizedBox(width: 20,),
                  ThemeToggleButton(),
                ],
              )
          ),


          SizedBox(
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

                Expanded(
                    flex: isMobile ? 0 : 1,
                    child: SizedBox.shrink()
                ),

                AnimatedBuilder(
                  animation: _rotationAnimation,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_rotationAnimation.value * 3.14),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isMobile ? Colors.transparent : isDark ? dark2 : light,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            !isMobile ?
                            BoxShadow(
                              color: Colors.black12,
                              spreadRadius: .5,
                              blurRadius: 2,
                              offset: Offset(0, 1),
                            ) : BoxShadow(
                              color: Colors.transparent,
                              spreadRadius: 0,
                              blurRadius: 0,
                              offset: Offset(0, 0),
                            )
                          ],
                        ),
                        margin: EdgeInsets.all(isMobile ? 0 : 40),
                        padding: EdgeInsets.symmetric(
                          vertical: 60,
                          horizontal: 60,
                        ),
                        width: 400,
                        height: 500,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [

                            Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateY(
                                      _rotationAnimation.value > 0.5 ? 3.14 : 0),
                                child:Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => toggleForm(false),
                                      icon: Icon(
                                        Icons.person,
                                        color: isTeacher ? Colors.grey : secondaryBlue,
                                      ),
                                      label: Text(
                                        "Alumno",
                                        style: TextStyle(
                                          color: isTeacher ? Colors.grey : secondaryBlue,
                                          fontSize: isMobile ? 14 : 16,
                                        ),
                                      ),
                                    ),

                                    TextButton.icon(
                                      onPressed: () => toggleForm(true),
                                      icon: Icon(
                                        Icons.supervisor_account_rounded,
                                        color: isTeacher ? secondaryBlue : Colors.grey,
                                      ),
                                      label: Text(
                                        "Docente",
                                        style: TextStyle(
                                          color: isTeacher ? secondaryBlue : Colors.grey,
                                          fontSize: isMobile ? 14 : 16,

                                        ),
                                      ),
                                    ),
                                  ],
                                )
                            ),
                            Expanded(
                              child: Transform(
                                alignment: Alignment.center,
                                transform: Matrix4.identity()
                                  ..rotateY(
                                      _rotationAnimation.value > 0.5 ? 3.14 : 0),
                                child: LoginForm(isMobile: isMobile, isTeacher: isTeacher,),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
