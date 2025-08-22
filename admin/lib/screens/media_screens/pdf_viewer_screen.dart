import 'dart:io';
import 'package:ama_meet_admin/models/note_model.dart';
import 'package:ama_meet_admin/repositories/note_repository.dart';
import 'package:ama_meet_admin/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerScreen extends StatefulWidget {
  final NoteModel note;

  const PdfViewerScreen({super.key, required this.note});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  late PdfViewerController _pdfViewerController;
  bool _isLoading = true;
  String? _error;
  File? _localFile;

  final NoteRepository _repo = NoteRepository();

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadLocalPdf();
  }

  Future<void> _loadLocalPdf() async {
    try {
      final file = await _repo.getOrDownloadFile(
        url: widget.note.url,
        localFilename: widget.note.filename,
      );
      if (mounted) {
        setState(() {
          _localFile = file;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.filename),
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel + 0.25;
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              _pdfViewerController.zoomLevel = _pdfViewerController.zoomLevel - 0.25;
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_localFile != null)
            SfPdfViewer.file(
              _localFile!,
              controller: _pdfViewerController,
              onDocumentLoaded: (_) {},
              onDocumentLoadFailed: (details) {
                setState(() {
                  _error = details.error;
                });
              },
            ),
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Downloading PDF...'),
                ],
              ),
            ),
          if (_error != null && !_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Failed to load PDF:\n$_error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }
}
