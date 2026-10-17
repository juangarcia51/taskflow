import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'task.dart';

// Notifier que gestiona la lista inmutable de tareas
class TaskListNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() {
    return [
      const Task(
        id: '1',
        title: 'Completar wireframes de UI',
        category: 'Diseño UX',
        priority: Priority.alta,
        isCompleted: true,
      ),
      const Task(
        id: '2',
        title: 'Revisión de arquitectura móvil',
        category: 'Desarrollo',
        priority: Priority.media,
        isCompleted: false,
      ),
      const Task(
        id: '3',
        title: 'Actualizar documentación técnica',
        category: 'Gestión',
        priority: Priority.baja,
        isCompleted: false,
      ),
    ];
  }

  // Operación: Agregar tarea
  void addTask(String title, String category, Priority priority) {
    final newTask = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      category: category,
      priority: priority,
    );
    state = [...state, newTask];
  }

  // Operación: Completar o alternar estado
  void toggleTask(String id) {
    state = [
      for (final task in state)
        if (task.id == id)
          task.copyWith(isCompleted: !task.isCompleted)
        else
          task,
    ];
  }

  // Operación: Eliminar tarea
  void deleteTask(String id) {
    state = state.where((task) => task.id != id).toList();
  }
}

// Provider global accesible en cualquier parte del árbol
final taskListProvider = NotifierProvider<TaskListNotifier, List<Task>>(
  TaskListNotifier.new,
);

// Provider computado para calcular el progreso de tareas completadas
final taskProgressProvider = Provider<double>((ref) {
  final tasks = ref.watch(taskListProvider);
  if (tasks.isEmpty) return 0.0;
  final completed = tasks.where((t) => t.isCompleted).length;
  return completed / tasks.length;
});