import 'dart:io';

import 'package:ama_meet_admin/models/class_note.dart';
import 'package:ama_meet_admin/repositories/class_note_repository.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatefulWidget {
  final ClassNoteRepository repo;
  final ClassNote note;
  final String localFilename;

  const PdfViewerPage({
    Key? key,
    required this.repo,
    required this.note,
    required this.localFilename,
  }) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  File? _file;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ensureFile();
  }

  Future<void> _ensureFile() async {
    try {
      final f = await widget.repo.downloadFileToCache(
        url: widget.note.url,
        localFilename: widget.localFilename,
      );
      setState(() {
        _file = f;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.note.filename)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.note.filename)),
        body: Center(child: Text('Error: $_error')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.note.filename)),
      body: SfPdfViewer.file(_file!),
    );
  }
}
