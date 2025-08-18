part of 'video_bloc.dart';

abstract class ClassVideosEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadClassVideos extends ClassVideosEvent {
  final String classId;
  LoadClassVideos(this.classId);

  @override
  List<Object?> get props => [classId];
}

class UploadClassVideoEvent extends ClassVideosEvent {
  final String classId;
  final File file;
  final String filename;
  final String sectionTitle;
  final int sectionOrder;
  UploadClassVideoEvent({
    required this.classId,
    required this.file,
    required this.filename,
    required this.sectionTitle,
    required this.sectionOrder,
  });

  @override
  List<Object?> get props => [classId, filename, sectionTitle, sectionOrder];
}

class DeleteClassVideoEvent extends ClassVideosEvent {
  final String classId;
  final String docId;
  final String publicId;
  DeleteClassVideoEvent({
    required this.classId,
    required this.docId,
    required this.publicId,
  });

  @override
  List<Object?> get props => [classId, docId, publicId];
}