part of 'community_cubit.dart';

class CommunityState {}

class CommunityInitial extends CommunityState {}

class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final List<Map<String, dynamic>> posts;
  CommunityLoaded(this.posts);
}

class CommunityEmpty extends CommunityState {}

class CommunityError extends CommunityState {
  final String message;
  CommunityError(this.message);
}
