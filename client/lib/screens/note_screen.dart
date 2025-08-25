import 'dart:ui';

import 'package:ama_meet/blocs/note/note_bloc.dart';
import 'package:ama_meet/models/note_model.dart';
import 'package:ama_meet/screens/media_screens/pdf_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ama_meet/blocs/auth/auth_bloc.dart';
import 'package:rive/rive.dart' as rive;

class NoteScreen extends StatefulWidget {
  const NoteScreen({super.key});

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  @override
  void initState() {
    super.initState();

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<NoteBloc>().add(LoadNotes(authState.student.classId));
    }
  }

  Map<String, List<NoteModel>> _groupNotesBySection(List<NoteModel> notes) {
    final Map<String, List<NoteModel>> grouped = {};
    for (final note in notes) {
      final section = (note.sectionTitle.trim().isEmpty)
          ? 'Uncategorized'
          : note.sectionTitle;
      grouped.putIfAbsent(section, () => []);
      grouped[section]!.add(note);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Class Notes"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: BlocBuilder<NoteBloc, NoteState>(
        builder: (context, state) {
          if (state is NotesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotesError) {
            return Center(
              child: Text(
                "Error: ${state.message}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is NotesLoaded) {
            if (state.notes.isEmpty) {
              return const Center(
                child: Text("No notes available for this class."),
              );
            }

            final grouped = _groupNotesBySection(state.notes);

            return RepaintBoundary(
              child: Stack(
                children: [
                  RepaintBoundary(
                    child: rive.RiveAnimation.asset(
                      "assets/rive/note_page.riv",
                      fit: BoxFit.cover, // Ensure proper fitting
                    ),
                  ),
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                      child: const SizedBox(),
                    ),
                  ),
                  SafeArea(
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: grouped.entries.map((entry) {
                        final section = entry.key;
                        final notes = entry.value;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              section,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            children: notes.map((note) {
                              return ListTile(
                                leading: const Icon(Icons.picture_as_pdf,
                                    color: Colors.red),
                                title: Text(note.filename),
                                subtitle: Text(
                                  "Uploaded at: ${DateTime.fromMillisecondsSinceEpoch(note.uploadedAt).toLocal()}",
                                  style: const TextStyle(fontSize: 12),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          PdfViewerScreen(note: note),
                                    ),
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
