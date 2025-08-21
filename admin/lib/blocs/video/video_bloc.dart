import 'dart:io';
import 'package:ama_meet_admin/models/video_model.dart';
import 'package:ama_meet_admin/repositories/class_video_repository.dart';
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
      } catch (e, st) {
        emit(ClassVideosError('Failed to load videos: ${e.toString()}'));
      }
    });

    on<UploadClassVideoToCloudinaryEvent>((event, emit) async {
      emit(ClassVideosUploadProgress(0));
      try {
        await repository.uploadVideoToCloudinary(
          event.classId,
          event.file,
          event.filename,
          event.sectionTitle,
          event.sectionOrder,
          onUploadProgress: (sent, total) {
            final progress = (sent / total * 100).clamp(0, 100).toInt();
            emit(ClassVideosUploadProgress(progress));
          },
        );
        final videos = await repository.getVideos(event.classId);
        emit(ClassVideosLoaded(videos));
      } catch (e) {
        emit(ClassVideosError('Cloudinary upload failed: ${e.toString()}'));
      }
    });

    on<UploadClassVideoToYouTubeEvent>((event, emit) async {
      emit(ClassVideosUploadProgress(0));
      try {
        await repository.uploadVideoToYouTube(
          event.classId,
          event.file,
          event.filename,
          event.sectionTitle,
          event.sectionOrder,
          event.privacyStatus,
          onUploadProgress: (sent, total) {
            final progress = (sent / total * 100).clamp(0, 100).toInt();
            emit(ClassVideosUploadProgress(progress));
          },
        );
        final videos = await repository.getVideos(event.classId);
        emit(ClassVideosLoaded(videos));
      } catch (e) {
        emit(ClassVideosError('YouTube upload failed: ${e.toString()}'));
      }
    });

    on<DeleteClassVideoEvent>((event, emit) async {
      emit(ClassVideosLoading());
      try {
        await repository.deleteVideo(event.classId, event.docId, event.publicId);
        final videos = await repository.getVideos(event.classId);
        emit(ClassVideosLoaded(videos));
      } catch (e) {
        emit(ClassVideosError('Delete failed: ${e.toString()}'));
      }
    });
  }

  @override
  Future<void> close() {
    repository.dispose();
    return super.close();
  }
}