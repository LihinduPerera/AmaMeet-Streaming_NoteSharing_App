import 'dart:io';
import 'package:ama_meet_admin/blocs/class/classes_bloc.dart';
import 'package:ama_meet_admin/blocs/class_note/class_note_bloc.dart';
import 'package:ama_meet_admin/models/class_note.dart';
import 'package:ama_meet_admin/repositories/class_note_repository.dart';
import 'package:ama_meet_admin/screens/pdf_viewer_screen.dart';
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
  String? _selectedClassId;
  String? _selectedClassName;
  Map<String, List<ClassNote>> _groupedNotes = {};

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
                      setState(() {
                        _selectedClassId = newValue;
                        _selectedClassName = state.classes
                            .firstWhere((c) => c.id == newValue)
                            .name;
                      });
                    },
                    items: state.classes.map<DropdownMenuItem<String>>((classRoom) {
                      return DropdownMenuItem<String>(
                        value: classRoom.id,
                        child: Text('${classRoom.name} - Year ${classRoom.year}'),
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
                : BlocProvider(
                    create: (context) => ClassNotesBloc(_noteRepo)
                      ..add(LoadClassNotes(_selectedClassId!)),
                    child: BlocBuilder<ClassNotesBloc, ClassNotesState>(
                      builder: (context, state) {
                        if (state is ClassNotesLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (state is ClassNotesError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error, size: 64, color: Colors.red),
                                const SizedBox(height: 16),
                                Text('Error: ${state.message}'),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<ClassNotesBloc>()
                                        .add(LoadClassNotes(_selectedClassId!));
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is ClassNotesLoaded) {
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
      final section = note.sectionTitle;
      if (!grouped.containsKey(section)) {
        grouped[section] = [];
      }
      grouped[section]!.add(note);
    }
    return grouped;
  }

  Widget _buildNotesContent(BuildContext context, Map<String, List<ClassNote>> groupedNotes) {
    if (groupedNotes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_alt_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              'No notes available for $_selectedClassName',
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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedNotes.keys.length,
      itemBuilder: (context, index) {
        final sectionTitle = groupedNotes.keys.elementAt(index);
        final sectionNotes = groupedNotes[sectionTitle]!;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 4,
          child: ExpansionTile(
            title: Text(
              sectionTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text('${sectionNotes.length} note(s)'),
            children: sectionNotes.map((note) => _buildNoteListTile(context, note)).toList(),
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
                  label: Text(selectedFile == null ? 'Select PDF File' : 'File Selected'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedFile == null ? Colors.grey : Colors.green,
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

                if (section.isEmpty || selectedFile == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields and select a file')),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note uploaded successfully!')),
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
    final orderController = TextEditingController(text: note.sectionOrder.toString());
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
                  label: Text(selectedFile == null ? 'Select New PDF (Optional)' : 'New File Selected'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedFile == null ? Colors.grey : Colors.green,
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
                final order = int.tryParse(orderController.text.trim()) ?? note.sectionOrder;
                final filename = filenameController.text.trim();

                if (section.isEmpty || filename.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please fill all required fields')),
                  );
                  return;
                }

                if (selectedFile != null) {
                  // Update with new file
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
                  // Update metadata only
                  context.read<ClassNotesBloc>().add(
                        UpdateClassNoteEvent(
                          docId: note.docId,
                          file: File(''), // Empty file for metadata-only update
                          filename: filename,
                          localFilenameToRemove: note.filename,
                          sectionTitle: section,
                          sectionOrder: order,
                        ),
                      );
                }
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Note updated successfully!')),
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
        content: Text('Are you sure you want to delete "${note.filename}"?\n\nThis action cannot be undone.'),
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
                const SnackBar(content: Text('Note deleted successfully!')),
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