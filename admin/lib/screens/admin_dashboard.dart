import 'package:ama_meet_admin/blocs/class/classes_bloc.dart';
import 'package:ama_meet_admin/blocs/student/students_bloc.dart';
import 'package:ama_meet_admin/repositories/student_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/classroom.dart';
import '../repositories/admin_repository.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late final StudentRepository _stRepo;
  ClassRoom? _selectedClass;
  StudentsBloc? _studentsBloc;

  @override
  void initState() {
    super.initState();
    _stRepo = StudentRepository();
    context.read<ClassesBloc>().add(LoadClasses());
  }

  @override
  void dispose() {
    _studentsBloc?.close();
    super.dispose();
  }

  void _showAddClassDialog() {
    final _idCtrl = TextEditingController();
    final _nameCtrl = TextEditingController();
    final _yearCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Class'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _idCtrl, decoration: const InputDecoration(labelText: 'Class ID (ex: DSE25.1)')),
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Class Name')),
              TextField(controller: _yearCtrl, decoration: const InputDecoration(labelText: 'Year'), keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final id = _idCtrl.text.trim();
              final name = _nameCtrl.text.trim();
              final year = int.tryParse(_yearCtrl.text.trim()) ?? 0;
              if (id.isEmpty || name.isEmpty || year == 0) return;
              final newClass = ClassRoom(id: id, name: name, year: year, createdAt: DateTime.now().millisecondsSinceEpoch);
              context.read<ClassesBloc>().add(AddClass(newClass));
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog(String classId, StudentsBloc studentsBloc) {
    final _nameCtrl = TextEditingController();
    final _emailCtrl = TextEditingController();
    final _pwCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Student'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Student Name')),
              TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
              TextField(controller: _pwCtrl, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = _nameCtrl.text.trim();
              final email = _emailCtrl.text.trim();
              final pw = _pwCtrl.text;
              if (name.isEmpty || email.isEmpty || pw.isEmpty) return;

              studentsBloc.add(AddStudent(name: name, email: email, password: pw));
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Class',
            onPressed: _showAddClassDialog,
          )
        ],
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
                            _studentsBloc?.close();
                            _studentsBloc = StudentsBloc(_stRepo, c.id)..add(LoadStudents());
                          });
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete Class'),
                                content: Text('Delete class ${c.name} and all its students?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                  ElevatedButton(
                                    onPressed: () {
                                      context.read<ClassesBloc>().add(DeleteClass(c.id));
                                      if (_selectedClass?.id == c.id) {
                                        setState(() {
                                          _selectedClass = null;
                                          _studentsBloc?.close();
                                          _studentsBloc = null;
                                        });
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),

          const VerticalDivider(width: 1),

          // Students list
          Flexible(
            flex: 3,
            child: _selectedClass == null || _studentsBloc == null
                ? const Center(child: Text('Select a class to see students'))
                : BlocProvider.value(
                    value: _studentsBloc!,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Students of ${_selectedClass!.name}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text('Add Student'),
                                onPressed: () => _showAddStudentDialog(_selectedClass!.id, _studentsBloc!),
                              )
                            ],
                          ),
                        ),
                        Expanded(
                          child: BlocBuilder<StudentsBloc, StudentsState>(
                            builder: (context, state) {
                              if (state is StudentsLoading) return const Center(child: CircularProgressIndicator());
                              if (state is StudentsError) return Center(child: Text('Error: ${state.message}'));
                              if (state is StudentsLoaded) {
                                final students = state.students;
                                if (students.isEmpty) return const Center(child: Text('No students'));
                                return ListView.builder(
                                  itemCount: students.length,
                                  itemBuilder: (_, i) {
                                    final entry = students[i];
                                    final docId = entry.key;
                                    final s = entry.value;
                                    return ListTile(
                                      title: Text(s.name),
                                      subtitle: Text('${s.id} - ${s.email}'),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => AlertDialog(
                                              title: const Text('Delete Student'),
                                              content: Text('Delete student ${s.name}?'),
                                              actions: [
                                                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    _studentsBloc!.add(DeleteStudent(docId));
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('Delete'),
                                                )
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        )
                      ],
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
