import 'package:eudkt/ui/state_management/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../resources/colors.dart';
import '../../services/app_snackbar.dart';
import '../state_management/auth/auth_cubit.dart';

class LoginForm extends StatefulWidget {
  final bool isMobile;
  final bool isTeacher;

  const LoginForm({
    super.key,
    required this.isMobile,
    required this.isTeacher,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  bool isVisible = true;
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          switch (state.rol) {
            case 'teacher':
              context.go('/teacher');
              break;
            case 'students':
              context.go('/students');
              break;
          }
        } else if (state is AuthError) {
          AppSnackBar.showError(state.message);
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Bienvenid@",
            style: TextStyle(
              fontSize: widget.isMobile ? 24 : 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Text(
            "Inicia sesión para continuar",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: widget.isMobile ? 16 : 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 32),
          TextField(
            controller: userController,
            decoration: InputDecoration(
              labelText: 'Matricula',
              labelStyle: TextStyle(fontSize: widget.isMobile ? 14 : 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
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
              labelStyle: TextStyle(fontSize: widget.isMobile ? 14 : 16),
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
          SizedBox(height: 50),
          ElevatedButton(
            onPressed: () {
              final user = userController.text.trim();
              final pass = passController.text.trim();

              if (user.isEmpty || pass.isEmpty) {
                AppSnackBar.showError("Completa todos los campos");
                return;
              }

              final role = widget.isTeacher ? 'teacher' : 'students';
              context.read<AuthCubit>().login(role, user, pass);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: secondaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 64, vertical: 16),
            ),
            child: Text(
              "Iniciar Sesión",
              style: TextStyle(
                fontSize: widget.isMobile ? 14 : 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
