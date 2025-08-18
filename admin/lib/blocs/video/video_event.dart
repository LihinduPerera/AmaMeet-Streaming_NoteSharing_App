part of 'video_bloc.dart';

abstract class ClassVideosEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadClassVideos extends ClassVideosEvent {
  final String classId;
  LoadClassVideos(this.classId);
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
}

class DeleteClassVideoEvent extends ClassVideosEvent {
  final String docId;
  final String publicId;
  final String localFilename;
  DeleteClassVideoEvent({
    required this.docId,
    required this.publicId,
    required this.localFilename,
  });
}