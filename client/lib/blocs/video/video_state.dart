part of 'video_bloc.dart';

abstract class VideoState extends Equatable{
  @override
  List<Object?> get props => [];
}

class VideosInitial extends VideoState {}

class VideosLoading extends VideoState {}

class VideosLoaded extends VideoState {
  final List<VideoModel> videos;
  VideosLoaded(this.videos);

  @override
  List<Object?> get props => [videos];
}

class VideoError extends VideoState {
  final String message;
  VideoError(this.message);

  @override
  List<Object?> get props => [message];
}