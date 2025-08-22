import 'package:ama_meet/models/video_model.dart';
import 'package:ama_meet/repositories/video_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'video_event.dart';
part 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState>{
  final VideoRepository repository;

  VideoBloc(this.repository) : super(VideosInitial()) {
    on<LoadVideos>((event, emit) async {
      emit(VideosLoading());
      try {
        final videos = await repository.getVideos(event.classId);
        emit(VideosLoaded(videos));
      } catch (e, st) {
        emit(VideoError('Failed to load videos: ${e.toString()}'));
      }
    });
  }
}