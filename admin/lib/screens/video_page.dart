import 'dart:io';
import 'package:ama_meet_admin/blocs/class/classes_bloc.dart';
import 'package:ama_meet_admin/blocs/video/video_bloc.dart';
import 'package:ama_meet_admin/models/class_video.dart';
import 'package:ama_meet_admin/repositories/class_video_repository.dart';
import 'package:ama_meet_admin/utils/colors.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({super.key});

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final ClassVideoRepository _videoRepo = ClassVideoRepository();
  late final ClassVideosBloc _classVideosBloc;

  String? _selectedClassId;
  String? _selectedClassName;

  @override
  void initState() {
    super.initState();
    _classVideosBloc = ClassVideosBloc(_videoRepo);
  }

  @override
  void dispose() {
    _classVideosBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Class Videos"),
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
        actions: [
          if (_selectedClassId != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddVideoDialog,
              tooltip: "Upload Video",
            ),
        ],
      ),
      body: Column(
        children: [
          // Class dropdown
          Container(
            padding: const EdgeInsets.all(16),
            child: BlocBuilder<ClassesBloc, ClassesState>(
              builder: (context, state) {
                if (state is ClassesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ClassesError) {
                  return Text('Error: ${state.message}',
                      style: const TextStyle(color: Colors.red));
                }
                if (state is ClassesLoaded) {
                  return DropdownButtonFormField<String>(
                    value: _selectedClassId,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Select Class",
                    ),
                    onChanged: (val) {
                      if (val == null) return;
                      final cls = state.classes.firstWhere((c) => c.id == val);
                      setState(() {
                        _selectedClassId = val;
                        _selectedClassName = cls.name;
                      });
                      _classVideosBloc.add(LoadClassVideos(val));
                    },
                    items: state.classes
                        .map((c) => DropdownMenuItem(
                              value: c.id,
                              child: Text("${c.name} - Year ${c.year}"),
                            ))
                        .toList(),
                  );
                }
                return const Center(child: Text("No classes available"));
              },
            ),
          ),

          // Video list
          Expanded(
            child: _selectedClassId == null
                ? const Center(child: Text("Select a class to view videos"))
                : BlocProvider.value(
                    value: _classVideosBloc,
                    child: BlocConsumer<ClassVideosBloc, ClassVideosState>(
                      listener: (context, state) {
                        if (state is ClassVideosError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        if (state is ClassVideosUploadProgress && state.progress == 100) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Video uploaded successfully'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is ClassVideosLoading) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (state is ClassVideosLoaded) {
                          if (state.videos.isEmpty) {
                            return const Center(
                                child: Text("No videos uploaded yet"));
                          }
                          return ListView.builder(
                            itemCount: state.videos.length,
                            itemBuilder: (ctx, i) {
                              final video = state.videos[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      video.thumbnailUrl.replaceAll(
                                          '<your-cloud-name>', 'your_cloud_name_here'),
                                      width: 120,
                                      height: 68,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 120,
                                        height: 68,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.videocam),
                                      ),
                                    ),
                                  ),
                                  title: Text(video.filename),
                                  subtitle: Text(
                                    "Uploaded: ${DateTime.fromMillisecondsSinceEpoch(video.uploadedAt).toString().split('.')[0]}",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                    onPressed: () async {
                                      final confirmed = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Delete video?'),
                                          content: Text(
                                              'Delete "${video.filename}" from ${_selectedClassName ?? "this class"}?'),
                                          actions: [
                                            TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(context, false),
                                                child: const Text('Cancel')),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.red),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true &&
                                          _selectedClassId != null) {
                                        _classVideosBloc.add(
                                          DeleteClassVideoEvent(
                                            classId: _selectedClassId!,
                                            docId: video.docId,
                                            publicId: video.publicId,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              VideoPlayerScreen(video: video)),
                                    );
                                  },
                                ),
                              );
                            },
                          );
                        }
                        if (state is ClassVideosUploadProgress) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Uploading video..."),
                                const SizedBox(height: 16),
                                LinearProgressIndicator(
                                  value: state.progress / 100,
                                  minHeight: 10,
                                ),
                                const SizedBox(height: 8),
                                Text("${state.progress.toInt()}%"),
                              ],
                            ),
                          );
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

  void _showAddVideoDialog() {
    final sectionController = TextEditingController();
    final orderController = TextEditingController(text: "1");
    final filenameController = TextEditingController();
    File? selectedFile;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text("Upload Video"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                    controller: sectionController,
                    decoration:
                        const InputDecoration(labelText: "Section Title")),
                const SizedBox(height: 8),
                TextField(
                    controller: orderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: "Order")),
                const SizedBox(height: 8),
                TextField(
                    controller: filenameController,
                    decoration: const InputDecoration(labelText: "Filename (optional)")),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: Text(selectedFile == null
                      ? "Select Video"
                      : "File Selected"),
                  onPressed: () async {
                    final result = await FilePicker.platform
                        .pickFiles(type: FileType.video);
                    if (result != null && result.files.isNotEmpty) {
                      setState(() {
                        selectedFile = File(result.files.single.path!);
                        if (filenameController.text.isEmpty) {
                          filenameController.text = result.files.single.name;
                        }
                      });
                    }
                  },
                ),
                if (selectedFile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Selected: ${selectedFile!.path.split('/').last}",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                if (selectedFile == null || _selectedClassId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Select a file and a class first')));
                  return;
                }
                _classVideosBloc.add(UploadClassVideoEvent(
                  classId: _selectedClassId!,
                  file: selectedFile!,
                  filename: filenameController.text.isEmpty
                      ? selectedFile!.path.split('/').last
                      : filenameController.text,
                  sectionTitle: sectionController.text,
                  sectionOrder: int.tryParse(orderController.text) ?? 1,
                ));
                Navigator.pop(dialogContext);
              },
              child: const Text("Upload"),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final ClassVideo video;
  const VideoPlayerScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    super.initState();

    final dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      widget.video.hlsUrl,
      useAsmsTracks: true,
      useAsmsSubtitles: true,
    );

    _betterPlayerController = BetterPlayerController(
      const BetterPlayerConfiguration(
        autoPlay: true,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          enableQualities: true,
          enableFullscreen: true,
          enablePlaybackSpeed: true,
        ),
      ),
      betterPlayerDataSource: dataSource,
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.video.filename),
        backgroundColor: buttonColor,
      ),
      body: Center(
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: BetterPlayer(controller: _betterPlayerController),
        ),
      ),
    );
  }
}