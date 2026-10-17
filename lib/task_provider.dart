import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'task.dart';
import 'validadores_tarea.dart';

class TaskListNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    final now = DateTime.now();
    return [
      Task(
        id: '1',
        title: 'Completar wireframes de UI',
        description: 'Diseñar pantallas en Figma para el módulo de tareas',
        dueDate: now.add(const Duration(days: 1)),
        category: 'Diseño UX',
        priority: Priority.alta,
        isCompleted: true,
      ),
      Task(
        id: '2',
        title: 'Revisión de arquitectura móvil',
        description: 'Validar separación de capas y gestión de estado con Riverpod',
        dueDate: now.add(const Duration(days: 3)),
        category: 'Desarrollo',
        priority: Priority.media,
        isCompleted: false,
      ),
      Task(
        id: '3',
        title: 'Actualizar documentación técnica',
        description: 'Redactar bitácora y casos de prueba unitaria',
        dueDate: now.add(const Duration(days: 5)),
        category: 'Gestión',
        priority: Priority.baja,
        isCompleted: false,
      ),
    ];
  }

  void addTaskObject(Task task) {
    if (ValidadoresTarea.titulo(task.title) != null) return;
    state = [...state, task];
  }

  void addTask(String title, String category, Priority priority, {String description = '', DateTime? dueDate}) {
    if (ValidadoresTarea.titulo(title) != null) return;
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      dueDate: dueDate,
      category: category,
      priority: priority,
    );
    state = [...state, newTask];
  }

  void toggleTask(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
  }

  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }
}

final taskListProvider = NotifierProvider<TaskListNotifier, List<Task>>(
  TaskListNotifier.new,
);

final taskProgressProvider = Provider<double>((ref) {
  final tasks = ref.watch(taskListProvider);
  if (tasks.isEmpty) return 0.0;
  final completed = tasks.where((t) => t.isCompleted).length;
  return completed / tasks.length;
});
