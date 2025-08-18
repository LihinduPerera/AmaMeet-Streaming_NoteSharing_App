part of 'video_bloc.dart';

abstract class ClassVideosState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClassVideosInitial extends ClassVideosState {}

class ClassVideosLoading extends ClassVideosState {}

class ClassVideosLoaded extends ClassVideosState {
  final List<ClassVideo> videos;
  ClassVideosLoaded(this.videos);

  @override
  List<Object?> get props => [videos];
}

class ClassVideosError extends ClassVideosState {
  final String message;
  ClassVideosError(this.message);

  @override
  List<Object?> get props => [message];
}