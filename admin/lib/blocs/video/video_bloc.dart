import 'dart:io';

import 'package:ama_meet_admin/models/class_video.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'video_event.dart';
part 'video_state.dart';

class ClassVideosBloc extends Bloc<ClassVideosEvent, ClassVideosState> {
  final ClassVideoRepository repository;

  ClassVideosBloc(this.repository) : super(ClassVideosInitial()) {
    on<LoadClassVideos>((event, emit) async {
      emit(ClassVideosLoading());
      try {
        final videos = await repository.getVideos(event.classId);
        emit(ClassVideosLoaded(videos));
      } catch (e) {
        emit(ClassVideosError(e.toString()));
      }
    });

    on<UploadClassVideoEvent>((event, emit) async {
      try {
        await repository.uploadVideo(
          event.classId,
          event.file,
          event.filename,
          event.sectionTitle,
          event.sectionOrder,
        );
      } catch (e) {
        emit(ClassVideosError(e.toString()));
      }
    });

    on<DeleteClassVideoEvent>((event, emit) async {
      try {
        await repository.deleteVideo(event.docId, event.publicId, event.localFilename);
      } catch (e) {
        emit(ClassVideosError(e.toString()));
      }
    });
  }
}