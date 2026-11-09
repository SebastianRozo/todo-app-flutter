import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const TodoApp());

class Task {
  Task(this.title, {this.done = false});
  String title;
  bool done;

  Map<String, dynamic> toJson() => {'title': title, 'done': done};
  factory Task.fromJson(Map<String, dynamic> j) =>
      Task(j['title'] as String, done: j['done'] as bool? ?? false);
}

enum Filter { todas, pendientes, completadas }

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'To-Do',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
        darkTheme: ThemeData(
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
            useMaterial3: true),
        home: const TodoPage(),
      );
}

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});
  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  static const _key = 'tasks';
  final List<Task> _tasks = [];
  Filter _filter = Filter.todas;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    try {
      final list = (jsonDecode(raw) as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>));
      setState(() => _tasks.addAll(list));
    } catch (_) {
      // Datos corruptos: se ignoran en lugar de cerrar la app.
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_tasks));
  }

  void _update(VoidCallback change) {
    setState(change);
    _save();
  }

  Future<void> _editTask([Task? task]) async {
    final ctrl = TextEditingController(text: task?.title);
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(task == null ? 'Nueva tarea' : 'Editar tarea'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: '¿Qué hay que hacer?'),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text),
              child: const Text('Guardar')),
        ],
      ),
    );
    final title = text?.trim() ?? '';
    if (title.isEmpty) return;
    _update(() => task == null ? _tasks.insert(0, Task(title)) : task.title = title);
  }

  void _delete(Task task) {
    final index = _tasks.indexOf(task);
    _update(() => _tasks.remove(task));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text('"${task.title}" eliminada'),
        action: SnackBarAction(
            label: 'Deshacer',
            onPressed: () => _update(() => _tasks.insert(index, task))),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final visible = _tasks.where((t) => switch (_filter) {
          Filter.todas => true,
          Filter.pendientes => !t.done,
          Filter.completadas => t.done,
        }).toList();
    final pending = _tasks.where((t) => !t.done).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis tareas'),
        actions: [
          if (_tasks.any((t) => t.done))
            IconButton(
              tooltip: 'Borrar completadas',
              icon: const Icon(Icons.delete_sweep),
              onPressed: () => _update(() => _tasks.removeWhere((t) => t.done)),
            ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<Filter>(
            segments: const [
              ButtonSegment(value: Filter.todas, label: Text('Todas')),
              ButtonSegment(value: Filter.pendientes, label: Text('Pendientes')),
              ButtonSegment(value: Filter.completadas, label: Text('Hechas')),
            ],
            selected: {_filter},
            onSelectionChanged: (s) => setState(() => _filter = s.first),
          ),
        ),
        Text('$pending pendiente(s) de ${_tasks.length}'),
        Expanded(
          child: visible.isEmpty
              ? const Center(child: Text('No hay tareas aquí'))
              : ListView.builder(
                  itemCount: visible.length,
                  itemBuilder: (_, i) {
                    final t = visible[i];
                    return Dismissible(
                      key: ObjectKey(t),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _delete(t),
                      child: CheckboxListTile(
                        value: t.done,
                        controlAffinity: ListTileControlAffinity.leading,
                        onChanged: (v) => _update(() => t.done = v ?? false),
                        title: Text(t.title,
                            style: TextStyle(
                                decoration:
                                    t.done ? TextDecoration.lineThrough : null)),
                        secondary: IconButton(
                          tooltip: 'Editar',
                          icon: const Icon(Icons.edit),
                          onPressed: () => _editTask(t),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _editTask(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }
}
