import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../services/encryption_helper.dart';
import '../../../services/shared_preference.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  ChangePasswordCubit() : super(Initial());

  Future<void> changePassword({
    required String newPassword,
  }) async {
    emit(Loading());
    try {
      String? userId = SharedPreferencesService.enrollment;
      String? collection = '';
      if(SharedPreferencesService.role == 'teacher'){
        collection = 'teacher';
      }else if(SharedPreferencesService.role == 'admin'){
        collection = 'admin';
      }else if(SharedPreferencesService.role == 'supervisor'){
        collection = 'supervisor';
      }

      final userDoc = await firestore.collection(collection).doc(userId).get();

      if (!userDoc.exists) {
        emit(Error("Usuario no encontrado"));
        return;
      }

      await firestore.collection(collection).doc(userId).update({
        'password': EncryptionHelper.hashPassword(newPassword),
      });

      emit(Success("Contraseña actualizada correctamente"));
    } catch (e) {
      emit(Error("Error al actualizar: $e"));
    }
  }

  Future<void> changeStudentPassword({
    required String studentId,
    required String newPassword,
  }) async {
    emit(Loading());
    try {


      final userDoc = await firestore.collection('students').doc(studentId).get();

      if (!userDoc.exists) {
        emit(Error("Usuario no encontrado"));
        return;
      }

      await firestore.collection('students').doc(studentId).update({
        'password': EncryptionHelper.hashPassword(newPassword),
      });

      emit(Success("Contraseña actualizada correctamente"));
    } catch (e) {
      emit(Error("Error al actualizar: $e"));
    }
  }
}
