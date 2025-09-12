part of 'add_user_cubit.dart';

@immutable
sealed class AddUserState {}

final class AddUserInitial extends AddUserState {}

final class Success extends AddUserState {}

final class Error extends AddUserState {}
