import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

class StorageHelper {
  static Future<String> uploadFile(PlatformFile file, String path) async {
    final ref = FirebaseStorage.instance.ref('$path/${file.name}');
    final uploadTask = await ref.putFile(File(file.path!));
    return await uploadTask.ref.getDownloadURL();
  }
}