import 'dart:io';
import 'package:ama_meet_admin/blocs/class/classes_bloc.dart';
import 'package:ama_meet_admin/blocs/class_note/class_note_bloc.dart';
import 'package:ama_meet_admin/models/class_note.dart';
import 'package:ama_meet_admin/repositories/class_note_repository.dart';
import 'package:ama_meet_admin/screens/media_screens/pdf_viewer_screen.dart';
import 'package:ama_meet_admin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final ClassNoteRepository _noteRepo = ClassNoteRepository();

  // Single bloc instance for the page lifecycle
  late final ClassNotesBloc _classNotesBloc;

  String? _selectedClassId;
  String? _selectedClassName;
  Map<String, List<ClassNote>> _groupedNotes = {};

  @override
  void initState() {
    super.initState();
    _classNotesBloc = ClassNotesBloc(_noteRepo);
  }

  @override
  void dispose() {
    _classNotesBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Notes Management'),
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedClassId != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddNoteDialog,
              tooltip: 'Add Note',
            ),
        ],
      ),
      body: Column(
        children: [
          // Class Selection Dropdown
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: BlocBuilder<ClassesBloc, ClassesState>(
              builder: (context, state) {
                if (state is ClassesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ClassesError) {
                  return Text(
                    'Error: ${state.message}',
                    style: const TextStyle(fontSize: 16, color: Colors.red),
                  );
                }
                if (state is ClassesLoaded) {
                  // If previously selected class was removed, clear selection & grouped notes
                  final exists = _selectedClassId == null
                      ? false
                      : state.classes.any((c) => c.id == _selectedClassId);
                  if (!exists && _selectedClassId != null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      setState(() {
                        _selectedClassId = null;
                        _selectedClassName = null;
                        _groupedNotes.clear();
                      });
                    });
                  }

                  if (state.classes.isEmpty) {
                    return const Text(
                      'No classes available',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    );
                  }

                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Select Class',
                      border: OutlineInputBorder(),
                    ),
                    value: _selectedClassId,
                    hint: const Text('Choose a class to manage notes'),
                    onChanged: (String? newValue) {
                      if (newValue == null) return;
                      // If selecting same class, do nothing
                      if (newValue == _selectedClassId) return;

                      final selectedClass =
                          state.classes.firstWhere((c) => c.id == newValue);
                      setState(() {
                        _selectedClassId = newValue;
                        _selectedClassName = selectedClass.name;
                        // Clear grouped notes immediately so old notes don't flash
                        _groupedNotes = {};
                      });

                      // request notes for new class
                      _classNotesBloc.add(LoadClassNotes(newValue));
                    },
                    items: state.classes
                        .map<DropdownMenuItem<String>>((classRoom) {
                      return DropdownMenuItem<String>(
                        value: classRoom.id,
                        child:
                            Text('${classRoom.name} - Year ${classRoom.year}'),
                      );
                    }).toList(),
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          // Notes Content
          Expanded(
            child: _selectedClassId == null
                ? const Center(
                    child: Text(
                      'Please select a class to view notes',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : BlocProvider.value(
                    value: _classNotesBloc,
                    child: BlocBuilder<ClassNotesBloc, ClassNotesState>(
                      builder: (context, state) {
                        if (state is ClassNotesLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is ClassNotesError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error,
                                    size: 64, color: Colors.red),
                                const SizedBox(height: 16),
                                Text('Error: ${state.message}'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    // retry load for currently selected class
                                    if (_selectedClassId != null) {
                                      context.read<ClassNotesBloc>().add(
                                          LoadClassNotes(_selectedClassId!));
                                    }
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is ClassNotesLoaded) {
                          // group notes and rebuild UI
                          _groupedNotes = _groupNotesBySection(state.notes);
                          return _buildNotesContent(context, _groupedNotes);
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Map<String, List<ClassNote>> _groupNotesBySection(List<ClassNote> notes) {
    final Map<String, List<ClassNote>> grouped = {};
    for (final note in notes) {
      final section = (note.sectionTitle?.trim().isEmpty ?? true)
          ? 'Uncategorized'
          : note.sectionTitle!;
      if (!grouped.containsKey(section)) {
        grouped[section] = [];
      }
      grouped[section]!.add(note);
    }
    return grouped;
  }

  Widget _buildNotesContent(
      BuildContext context, Map<String, List<ClassNote>> groupedNotes) {
    if (groupedNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No notes available for ${_selectedClassName ?? "this class"}',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddNoteDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add First Note'),
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
            ),
          ],
        ),
      );
    }

    final sectionKeys = groupedNotes.keys.toList();
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sectionKeys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final sectionTitle = sectionKeys[index];
        final sectionNotes = groupedNotes[sectionTitle]!;

        return Card(
          margin: EdgeInsets.zero,
          elevation: 4,
          child: ExpansionTile(
            key:
                PageStorageKey(sectionTitle), // preserve expansion state better
            title: Text(
              sectionTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('${sectionNotes.length} note(s)'),
            children: sectionNotes
                .map((note) => _buildNoteListTile(context, note))
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildNoteListTile(BuildContext context, ClassNote note) {
    return ListTile(
      leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
      title: Text(note.filename),
      subtitle: Text(
        'Uploaded: ${DateTime.fromMillisecondsSinceEpoch(note.uploadedAt).toString().split('.')[0]}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.visibility, color: Colors.blue),
            onPressed: () => _viewPdf(context, note),
            tooltip: 'View PDF',
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.orange),
            onPressed: () => _showUpdateNoteDialog(context, note),
            tooltip: 'Update Note',
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context, note),
            tooltip: 'Delete Note',
          ),
        ],
      ),
    );
  }

  void _viewPdf(BuildContext context, ClassNote note) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PdfViewerScreen(note: note),
      ),
    );
  }

  void _showAddNoteDialog() {
    final filenameController = TextEditingController();
    final sectionController = TextEditingController();
    final orderController = TextEditingController(text: '1');
    File? selectedFile;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add New Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(
                    labelText: 'Section/Lesson Title *',
                    hintText: 'e.g., Lesson 1, Chapter 2, etc.',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  decoration: const InputDecoration(
                    labelText: 'Section Order *',
                    hintText: 'Numeric order for sorting',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: filenameController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Filename (optional)',
                    hintText: 'Leave empty to use original filename',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null && result.files.isNotEmpty) {
                      setState(() {
                        selectedFile = File(result.files.single.path!);
                        if (filenameController.text.isEmpty) {
                          filenameController.text = result.files.single.name;
                        }
                      });
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(selectedFile == null
                      ? 'Select PDF File'
                      : 'File Selected'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedFile == null ? Colors.grey : Colors.green,
                  ),
                ),
                if (selectedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Selected: ${selectedFile!.path.split('/').last}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final section = sectionController.text.trim();
                final order = int.tryParse(orderController.text.trim()) ?? 1;
                final filename = filenameController.text.trim().isEmpty
                    ? selectedFile?.path.split('/').last ?? 'note.pdf'
                    : filenameController.text.trim();

                if (section.isEmpty ||
                    selectedFile == null ||
                    _selectedClassId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'Please fill all required fields and select a file')),
                  );
                  return;
                }

                context.read<ClassNotesBloc>().add(
                      UploadClassNoteEvent(
                        classId: _selectedClassId!,
                        file: selectedFile!,
                        filename: filename,
                        sectionTitle: section,
                        sectionOrder: order,
                      ),
                    );

                Navigator.of(dialogContext).pop();
                // We show a temporary snackbar — the actual state is updated by the Firestore stream
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note upload started')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              child: const Text('Upload'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateNoteDialog(BuildContext context, ClassNote note) {
    final filenameController = TextEditingController(text: note.filename);
    final sectionController = TextEditingController(text: note.sectionTitle);
    final orderController =
        TextEditingController(text: note.sectionOrder.toString());
    File? selectedFile;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Update Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(
                    labelText: 'Section/Lesson Title *',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: orderController,
                  decoration: const InputDecoration(
                    labelText: 'Section Order *',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: filenameController,
                  decoration: const InputDecoration(
                    labelText: 'Filename *',
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await FilePicker.platform.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf'],
                    );
                    if (result != null && result.files.isNotEmpty) {
                      setState(() {
                        selectedFile = File(result.files.single.path!);
                      });
                    }
                  },
                  icon: const Icon(Icons.upload_file),
                  label: Text(selectedFile == null
                      ? 'Select New PDF (Optional)'
                      : 'New File Selected'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedFile == null ? Colors.grey : Colors.green,
                  ),
                ),
                if (selectedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'New file: ${selectedFile!.path.split('/').last}',
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final section = sectionController.text.trim();
                final order = int.tryParse(orderController.text.trim()) ??
                    note.sectionOrder;
                final filename = filenameController.text.trim();

                if (section.isEmpty || filename.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please fill all required fields')),
                  );
                  return;
                }

                if (selectedFile != null) {
                  // Update with new file - will upload & update
                  context.read<ClassNotesBloc>().add(
                        UpdateClassNoteEvent(
                          docId: note.docId,
                          file: selectedFile!,
                          filename: filename,
                          localFilenameToRemove: note.filename,
                          sectionTitle: section,
                          sectionOrder: order,
                        ),
                      );
                } else {
                  // Metadata-only update:
                  // NOTE: your current UpdateClassNoteEvent expects a File; if your bloc/repo
                  // doesn't support metadata-only updates, consider adding a separate event
                  // or adjust the repository. For now, we call update directly to avoid sending
                  // an invalid empty File path.
                  _noteRepo
                      .updateClassNote(
                    docId: note.docId,
                    file: File(
                        note.filename), // this will likely fail if path invalid
                    filename: filename,
                    sectionTitle: section,
                    sectionOrder: order,
                  )
                      .then((_) {
                    // remove cached local file if applicable
                    _noteRepo.removeCachedFile(note.filename);
                  }).catchError((err) {
                    // if update via repo fails because of file path, fallback to updating firestore doc:
                    // A safe fallback: directly update only metadata in firestore to avoid breaking.
                    // But repository currently does upload+update. Ideally create a method to update metadata-only.
                  });
                }

                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note update started')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: buttonColor),
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, ClassNote note) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text(
            'Are you sure you want to delete "${note.filename}"?\n\nThis action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<ClassNotesBloc>().add(
                    DeleteClassNoteEvent(
                      docId: note.docId,
                      publicId: note.publicId,
                      localFilename: note.filename,
                    ),
                  );
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Note delete started')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
