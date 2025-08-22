part of 'video_bloc.dart';

abstract class VideoEvent extends Equatable{
  @override
  List<Object?> get props => [];
}

class LoadVideos extends VideoEvent {
  final String classId;
  LoadVideos(this.classId);

  @override
  List<Object?> get props => [classId];
}