import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';

import '../../../services/encryption_helper.dart';

part 'add_user_state.dart';

class AddUserCubit extends Cubit<AddUserState> {
  AddUserCubit() : super(AddUserInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future addUser({
    required String name,
    required String enrollment,
    required String password,
    required String career,
    int? semester,
    required bool isStudent,
  }) async {
    try {
      if (isStudent){
        await _firestore.collection('students').doc(enrollment).set({
          'name': name,
          'password': EncryptionHelper.hashPassword(password),
          'semester': semester,
          'image': '',
          'career': career,
          'createdAt': FieldValue.serverTimestamp(),

        });
        emit(Success());

      }else{
        await _firestore.collection('teacher').doc(enrollment).set({
          'name': name,
          'password': EncryptionHelper.hashPassword(password),
          'image': '',
          'createdAt': FieldValue.serverTimestamp(),
        });
        emit(Success());
      }

    } catch (e) {
      emit(Error());
    }
  }
}
