import 'dart:io';

import 'package:ama_meet_admin/blocs/class/classes_bloc.dart';
import 'package:ama_meet_admin/blocs/class_note/class_note_bloc.dart';
import 'package:ama_meet_admin/models/class_note.dart';
import 'package:ama_meet_admin/models/classroom.dart';
import 'package:ama_meet_admin/repositories/class_note_repository.dart';
import 'package:ama_meet_admin/screens/pdf_viewer_page.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  late final ClassNoteRepository _repo;
  ClassRoom? _selectedClass;
  ClassNotesBloc? _notesBloc;

  @override
  void initState() {
    super.initState();
    _repo = ClassNoteRepository();
    context.read<ClassesBloc>().add(LoadClasses());
  }

  @override
  void dispose() {
    _notesBloc?.close();
    super.dispose();
  }

  Future<void> _addNote() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    final PlatformFile pf = result.files.first;
    if (pf.path == null) return;
    final File file = File(pf.path!);
    final String filename = pf.name;
    _notesBloc!.add(UploadClassNoteEvent(
      classId: _selectedClass!.id,
      file: file,
      filename: filename,
    ));
  }

  Future<void> _updateNote(ClassNote note) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null) return;
    final PlatformFile pf = result.files.first;
    if (pf.path == null) return;
    final File file = File(pf.path!);
    final String filename = pf.name;
    _notesBloc!.add(UpdateClassNoteEvent(
      docId: note.docId,
      file: file,
      filename: filename,
      localFilenameToRemove: note.filename,
    ));
  }

  void _deleteNote(ClassNote note) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Delete note ${note.filename}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _notesBloc!.add(DeleteClassNoteEvent(
                docId: note.docId,
                publicId: note.publicId,
                localFilename: note.filename,
              ));
              Navigator.pop(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Notes'),
      ),
      body: Row(
        children: [
          // Classes list
          Flexible(
            flex: 2,
            child: BlocBuilder<ClassesBloc, ClassesState>(
              builder: (context, state) {
                if (state is ClassesLoading) return const Center(child: CircularProgressIndicator());
                if (state is ClassesError) return Center(child: Text('Error: ${state.message}'));
                if (state is ClassesLoaded) {
                  final classes = state.classes;
                  return ListView.builder(
                    itemCount: classes.length,
                    itemBuilder: (_, i) {
                      final c = classes[i];
                      return ListTile(
                        title: Text(c.name),
                        subtitle: Text('${c.id} - Year ${c.year}'),
                        selected: _selectedClass?.id == c.id,
                        onTap: () {
                          setState(() {
                            _selectedClass = c;
                            _notesBloc?.close();
                            _notesBloc = ClassNotesBloc(_repo)..add(LoadClassNotes(c.id));
                          });
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          const VerticalDivider(width: 1),
          // Notes list
          Flexible(
            flex: 3,
            child: _selectedClass == null || _notesBloc == null
                ? const Center(child: Text('Select a class to see notes'))
                : BlocProvider.value(
                    value: _notesBloc!,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Notes for ${_selectedClass!.name}',
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add Note'),
                                onPressed: _addNote,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: BlocBuilder<ClassNotesBloc, ClassNotesState>(
                            builder: (context, state) {
                              if (state is ClassNotesLoading) return const Center(child: CircularProgressIndicator());
                              if (state is ClassNotesError) return Center(child: Text('Error: ${state.message}'));
                              if (state is ClassNotesLoaded) {
                                final notes = state.notes;
                                if (notes.isEmpty) return const Center(child: Text('No notes'));
                                return ListView.builder(
                                  itemCount: notes.length,
                                  itemBuilder: (_, i) {
                                    final note = notes[i];
                                    return ListTile(
                                      title: Text(note.filename),
                                      subtitle: Text(
                                        DateTime.fromMillisecondsSinceEpoch(note.uploadedAt).toString(),
                                      ),
                                      trailing: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.visibility),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => PdfViewerPage(
                                                    repo: _repo,
                                                    note: note,
                                                    localFilename: note.filename,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () => _updateNote(note),
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete),
                                            onPressed: () => _deleteNote(note),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}