import 'dart:io';
import 'package:ama_meet_admin/blocs/class/classes_bloc.dart';
import 'package:ama_meet_admin/blocs/video/video_bloc.dart';
import 'package:ama_meet_admin/repositories/class_video_repository.dart';
import 'package:ama_meet_admin/screens/media_screens/vlc_player_screen.dart';
import 'package:ama_meet_admin/screens/media_screens/youtube_player_screen.dart';
import 'package:ama_meet_admin/utils/colors.dart';
import 'package:ama_meet_admin/models/video_model.dart';
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
                        if (state is ClassVideosUploadProgress &&
                            state.progress == 100) {
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
                                  leading: Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.network(
                                          video.thumbnailUrl,
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
                                      // Provider indicator
                                      Positioned(
                                        bottom: 4,
                                        right: 4,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: video.isYouTubeVideo 
                                                ? Colors.red 
                                                : Colors.blue,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            video.isYouTubeVideo 
                                                ? Icons.play_arrow 
                                                : Icons.cloud,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  title: Text(video.filename),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Uploaded: ${DateTime.fromMillisecondsSinceEpoch(video.uploadedAt).toString().split('.')[0]}",
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        "Provider: ${video.isYouTubeVideo ? 'YouTube' : 'Cloudinary'}",
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: video.isYouTubeVideo 
                                              ? Colors.red 
                                              : Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (video.isYouTubeVideo && video.youtubePrivacyStatus != null)
                                        Text(
                                          "Privacy: ${video.youtubePrivacyStatus!.name.toUpperCase()}",
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.orange,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                    ],
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
                                                onPressed: () => Navigator.pop(
                                                    context, false),
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
                                    if (video.isYouTubeVideo) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => YouTubePlayerScreen(video: video),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => VlcPlayerScreen(video: video),
                                        ),
                                      );
                                    }
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
    VideoProvider selectedProvider = VideoProvider.cloudinary;
    YouTubePrivacyStatus youtubePrivacyStatus = YouTubePrivacyStatus.unlisted;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text("Upload Video"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: sectionController,
                  decoration: const InputDecoration(labelText: "Section Title"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: orderController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Order"),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: filenameController,
                  decoration: const InputDecoration(labelText: "Filename (optional)"),
                ),
                const SizedBox(height: 16),
                
                // Provider selection
                const Text("Select Upload Provider:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile<VideoProvider>(
                        title: const Text("Cloudinary"),
                        value: VideoProvider.cloudinary,
                        groupValue: selectedProvider,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedProvider = value!;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: RadioListTile<VideoProvider>(
                        title: const Text("YouTube"),
                        value: VideoProvider.youtube,
                        groupValue: selectedProvider,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedProvider = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                
                // YouTube privacy settings (only show when YouTube is selected)
                if (selectedProvider == VideoProvider.youtube) ...[
                  const SizedBox(height: 16),
                  const Text("YouTube Privacy Status:", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<YouTubePrivacyStatus>(
                    value: youtubePrivacyStatus,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: "Privacy Status",
                    ),
                    onChanged: (value) {
                      setDialogState(() {
                        youtubePrivacyStatus = value!;
                      });
                    },
                    items: YouTubePrivacyStatus.values.map((status) {
                      return DropdownMenuItem(
                        value: status,
                        child: Text(status.name.toUpperCase()),
                      );
                    }).toList(),
                  ),
                ],
                
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: Text(
                      selectedFile == null ? "Select Video" : "File Selected"),
                  onPressed: () async {
                    final result = await FilePicker.platform
                        .pickFiles(type: FileType.video);
                    if (result != null && result.files.isNotEmpty) {
                      setDialogState(() {
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
                      style: const TextStyle(fontSize: 12, color: Colors.green),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedFile == null || _selectedClassId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Select a file and a class first')));
                  return;
                }
                
                final filename = filenameController.text.isEmpty
                    ? selectedFile!.path.split('/').last
                    : filenameController.text;
                
                if (selectedProvider == VideoProvider.youtube) {
                  _classVideosBloc.add(UploadClassVideoToYouTubeEvent(
                    classId: _selectedClassId!,
                    file: selectedFile!,
                    filename: filename,
                    sectionTitle: sectionController.text,
                    sectionOrder: int.tryParse(orderController.text) ?? 1,
                    privacyStatus: youtubePrivacyStatus,
                  ));
                } else {
                  _classVideosBloc.add(UploadClassVideoToCloudinaryEvent(
                    classId: _selectedClassId!,
                    file: selectedFile!,
                    filename: filename,
                    sectionTitle: sectionController.text,
                    sectionOrder: int.tryParse(orderController.text) ?? 1,
                  ));
                }
                
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