part of 'help_cubit.dart';

abstract class HelpState {}

class Loading extends HelpState {}

class Loaded extends HelpState {
  final List<Map<String, dynamic>> videos;
  Loaded(this.videos);
}

class Error extends HelpState {
  final String message;
  Error(this.message);
}
