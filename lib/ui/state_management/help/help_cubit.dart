import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
part 'help_state.dart';

class HelpCubit extends Cubit<HelpState> {
  final FirebaseFirestore firestore;
  HelpCubit(this.firestore) : super(Loading());

  Future<void> loadVideos() async {
    emit(Loading());
    try {
      final snapshot = await firestore.collection('help').get();
      final videos = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'name': data['name'] ?? 'Sin título',
          'url': data['url'] ?? '',
        };
      }).toList();

      emit(Loaded(videos));
    } catch (e) {
      emit(Error('Error al cargar videos: $e'));
    }
  }
}
