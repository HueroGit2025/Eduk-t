
import 'package:eudkt/resources/colors.dart';
import 'package:eudkt/ui/state_management/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../../services/app_snackbar.dart';
import '../../state_management/auth/auth_cubit.dart';
import '../../state_management/theme/theme_cubit.dart';
import '../../widgets/theme_toggle_button.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  AdminLoginState createState() => AdminLoginState();
}

class AdminLoginState extends State<AdminLogin> with SingleTickerProviderStateMixin {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  bool isVisible = true;
  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state.isDarkMode;

    bool isMobile = MediaQuery.sizeOf(context).width < 600;
    final width = MediaQuery.sizeOf(context).width;

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {

            context.go('/admin/home');

        } else if (state is AuthError) {
          AppSnackBar.showError(state.message);
        }
      },
      child: Scaffold(
      backgroundColor: mainBlue,
      body: Stack(
        children: [
          Positioned(
            top: 20,
              width: width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                      height: 40,
                      color: light,
                      'assets/LOGO.svg'
                  ),
                  SizedBox(width: 20,),
                  ThemeToggleButton(),
                ],
              )
          ),
          Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 40,
                    horizontal: 60,
                  ),
                  width: 400,
                  height: 450,
                  decoration: BoxDecoration(

                    color: isDark ? dark2 : light,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      !isMobile ?
                      BoxShadow(
                        color: Colors.black26,
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
                  child:Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [

                      Text(
                        "Bienvenid@ Admin",
                        style: TextStyle(
                          fontSize: isMobile ? 24 : 30,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 16),

                      Text(
                        "Inicia sesión para continuar",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 16 : 18,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 32),

                      TextField(
                        controller: userController,
                        decoration: InputDecoration(
                          labelText: 'Matricula',
                          labelStyle: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30)
                          ),
                          prefixIcon: Icon(Icons.person_sharp),
                        ),
                      ),
                      SizedBox(height: 16),

                      TextField(
                        obscureText: isVisible,
                        controller: passController,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: TextStyle(fontSize: isMobile ? 14 : 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          prefixIcon: Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(isVisible ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => isVisible = !isVisible),
                          ),
                        ),
                      ),

                      SizedBox(height: 50,),
                      ElevatedButton(
                        onPressed: () {
                          final user = userController.text.trim();
                          final pass = passController.text.trim();

                          if (user.isEmpty || pass.isEmpty) {
                            AppSnackBar.showError("Completa todos los campos");
                            return;
                          }

                          final role = 'admin';
                          context.read<AuthCubit>().login(role, user, pass);

                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: secondaryBlue,
                          padding: EdgeInsets.symmetric(
                            horizontal: 64,
                            vertical: 16,
                          ),
                        ),
                        child: Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.white
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    ),
    );
  }
}
