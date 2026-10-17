import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'task.dart';
import 'tareas_api.dart';

/// Cliente HTTP global liberado automáticamente con ref.onDispose
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final tareasApiProvider = Provider<TareasApi>((ref) {
  return TareasApi(ref.watch(httpClientProvider));
});

class TareasRemotasNotifier extends AsyncNotifier<List<Task>> {
  @override
  Future<List<Task>> build() {
    return ref.watch(tareasApiProvider).obtenerTareas();
  }

  /// Recarga manual con AsyncLoading
  Future<void> recargar() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(tareasApiProvider).obtenerTareas(),
    );
  }

  /// Envía la tarea por POST y la agrega a la lista sin romper el estado en caso de error
  Future<void> crear(Task tarea) async {
    final creada = await ref.read(tareasApiProvider).crearTarea(tarea);
    state = AsyncData([...state.value ?? [], creada]);
  }
}

final tareasRemotasProvider =
    AsyncNotifierProvider<TareasRemotasNotifier, List<Task>>(
  TareasRemotasNotifier.new,
);
