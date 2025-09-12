import 'package:eudkt/services/shared_preference.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StatsCubit extends Cubit<void> {

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  int totalStudents = 0;
  int totalTeachers = 0;
  int activeCourses = 0;
  int contributions = 0;
  int _version = 0;

  StatsCubit() : super(0) {
    _initListeners();
  }

  void _initListeners() {
    if(SharedPreferencesService.career != ''){
      firestore.collection('students')
          .where('career', isEqualTo: '${SharedPreferencesService.career}')
          .snapshots().listen(
              (snapshot) {
            totalStudents = snapshot.docs.length;
            _emitChange();
          }
      );

      firestore.collection('teacher').snapshots().listen((snapshot) {
        totalTeachers = snapshot.docs.length;
        _emitChange();
      });

      firestore.collection('courses').where('is_active', isEqualTo: true)
          .where('career', isEqualTo: '${SharedPreferencesService.career}')
          .snapshots().listen((snapshot) {
        activeCourses = snapshot.docs.length;
        _emitChange();
      });

      firestore.collection('publications')
          .where('career', isEqualTo: '${SharedPreferencesService.career}')
          .snapshots().listen((snapshot) {
        contributions = snapshot.docs.length;
        _emitChange();
      });
    }else{
      firestore.collection('students')
          .snapshots().listen(
              (snapshot) {
            totalStudents = snapshot.docs.length;
            _emitChange();
          }
      );

      firestore.collection('teacher').snapshots().listen((snapshot) {
        totalTeachers = snapshot.docs.length;
        _emitChange();
      });

      firestore.collection('courses').where('is_active', isEqualTo: true)
          .snapshots().listen((snapshot) {
        activeCourses = snapshot.docs.length;
        _emitChange();
      });

      firestore.collection('publications')
          .snapshots().listen((snapshot) {
        contributions = snapshot.docs.length;
        _emitChange();
      });
    }
  }


  void _emitChange() {
    _version++;
    emit(_version);
  }
}
