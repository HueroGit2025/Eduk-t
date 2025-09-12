import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../services/auth_services.dart';
import '../../../services/shared_preference.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {

  AuthCubit() : super(AuthInitial());

  Future<void> checkSession() async {

    final role = SharedPreferencesService.role;


    if (role != null) {
      emit(AuthAuthenticated(rol: role));
    } else {
      emit(AuthInitial());
    }
  }

  Future<void> login(String role, String enrollment, String password) async {
    emit(AuthLoading());
    try {
      final user = await AuthService().login(
        role: role,
        password: password,
        enrollment: enrollment,
      );

      if (user == null) {
        emit(AuthError("Usuario o contraseña incorrectos..."));
      } else {
        await SharedPreferencesService.setUserData(
            enrollment: user['enrollment'],
            role: user['rol'],
            name: user['name'],
            career: user['career'],
            image: user['image']
        );
        emit(AuthAuthenticated(rol: user['rol'],));
      }
    } catch (e) {
      emit(AuthError("Error al iniciar sesión $e"));
    }
  }

  void logout() {
    emit(AuthLoggedOut());
  }
}

