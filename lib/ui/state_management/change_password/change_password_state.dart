part of 'change_password_cubit.dart';

abstract class ChangePasswordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class Initial extends ChangePasswordState {}

class Loading extends ChangePasswordState {}

class Success extends ChangePasswordState {
  final String message;
  Success(this.message);

  @override
  List<Object?> get props => [message];
}

class Error extends ChangePasswordState {
  final String error;
  Error(this.error);

  @override
  List<Object?> get props => [error];
}
