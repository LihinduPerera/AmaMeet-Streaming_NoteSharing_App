import 'dart:io';

import 'package:ama_meet_admin/blocs/class_note/class_note_bloc.dart';
import 'package:ama_meet_admin/models/class_note.dart';
import 'package:ama_meet_admin/models/classroom.dart';
import 'package:ama_meet_admin/repositories/class_note_repository.dart';
import 'package:ama_meet_admin/screens/pdf_viewer_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesPage extends StatefulWidget {
  final ClassRoom classRoom;
  final ClassNoteRepository repo;
  const NotesPage({Key? key, required this.classRoom, required this.repo}) : super(key : key);

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final ClassNotesBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ClassNotesBloc(widget.repo);
    _bloc.add(LoadClassNotes(widget.classRoom.id));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    final file = File(picked.path!);
    final filename = picked.name;
    _bloc.add(UploadClassNoteEvent(classId: widget.classRoom.id, file: file, filename: filename));
  }

  Future<void> _pickAndUpdate(ClassNote note) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result == null || result.files.isEmpty) return;
    final picked = result.files.single;
    final file = File(picked.path!);
    final filename = picked.name;
    _bloc.add(UpdateClassNoteEvent(
      docId: note.docId,
      file: file,
      filename: filename,
      localFilenameToRemove: '${note.docId}.pdf',
    ));
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Scaffold(
        appBar: AppBar(title: Text('Class notes — ${widget.classRoom.name}')),
        floatingActionButton: FloatingActionButton(
          onPressed: _pickAndUpload,
          child: const Icon(Icons.upload_file),
          tooltip: 'Upload PDF',
        ),
        body: BlocBuilder<ClassNotesBloc, ClassNotesState>(
          builder: (context, state) {
            if (state is ClassNotesLoading || state is ClassNotesInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ClassNotesError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            if (state is ClassNotesLoaded) {
              final notes = state.notes;
              if (notes.isEmpty) return const Center(child: Text('No notes yet'));
              return ListView.builder(
                itemCount: notes.length,
                itemBuilder: (_, i) {
                  final n = notes[i];
                  final localFilename = '${n.docId}.pdf';
                  return ListTile(
                    title: Text(n.filename),
                    subtitle: Text('Uploaded: ${DateTime.fromMillisecondsSinceEpoch(n.uploadedAt)}'),
                    leading: const Icon(Icons.picture_as_pdf),
                    onTap: () async {
                      // open viewer (it will download & cache if needed)
                      Navigator.push(context, MaterialPageRoute(builder: (_) => PdfViewerPage(
                        repo: widget.repo,
                        note: n,
                        localFilename: localFilename,
                      )));
                    },
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _pickAndUpdate(n),
                        tooltip: 'Replace PDF',
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final ok = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                    title: const Text('Delete note'),
                                    content: Text('Delete ${n.filename}?'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                    ],
                                  ));
                          if (ok == true) {
                            _bloc.add(DeleteClassNoteEvent(docId: n.docId, publicId: n.publicId, localFilename: localFilename));
                          }
                        },
                      )
                    ]),
                  );
                },
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }
}