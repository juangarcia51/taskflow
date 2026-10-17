import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_colors.dart';
import 'nueva_tarea_screen.dart';
import 'task.dart';
import 'tareas_api.dart';
import 'tareas_remotas_provider.dart';

class TareasRemotasScreen extends ConsumerWidget {
  const TareasRemotasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTareas = ref.watch(tareasRemotasProvider);
    final notifier = ref.read(tareasRemotasProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text('Tareas en la nube (REST API)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar tareas',
            onPressed: notifier.recargar,
          ),
        ],
      ),
      body: asyncTareas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _VistaError(
          mensaje: error is ApiException
              ? error.mensaje
              : 'Ocurrió un error inesperado al conectar con el servidor.',
          onReintentar: notifier.recargar,
        ),
        data: (tareas) => RefreshIndicator(
          onRefresh: notifier.recargar,
          child: tareas.isEmpty
              ? ListView(
                  children: const [
                    SizedBox(height: 120),
                    Center(child: Text('El servidor no tiene tareas disponibles.')),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: tareas.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final t = tareas[i];
                    return Card(
                      elevation: 0.5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: Icon(
                          t.isCompleted
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color: t.isCompleted ? AppColors.gold : AppColors.textMuted,
                        ),
                        title: Text(
                          t.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            decoration: t.isCompleted ? TextDecoration.lineThrough : null,
                          ),
                        ),
                        subtitle: Text(
                          t.serverId != null ? 'Servidor ID: ${t.serverId}' : 'Sin ID remoto',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.chipBg,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'JSONPlaceholder',
                            style: TextStyle(fontSize: 10, color: AppColors.primaryMedium),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.cloud_upload),
        label: const Text('Nueva en nube'),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        onPressed: () => _crearTarea(context, ref),
      ),
    );
  }

  Future<void> _crearTarea(BuildContext context, WidgetRef ref) async {
    // Reutilizamos la pantalla de creación
    final nueva = await Navigator.push<Task>(
      context,
      MaterialPageRoute(builder: (_) => const NuevaTareaScreen()),
    );
    if (nueva == null || !context.mounted) return;

    final mensajero = ScaffoldMessenger.of(context);
    mensajero.showSnackBar(
      const SnackBar(
        content: Text('Enviando tarea a la API REST...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      await ref.read(tareasRemotasProvider.notifier).crear(nueva);
      mensajero
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Tarea "${nueva.title}" creada en la nube (ID: ${nueva.serverId ?? 201}).'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } on ApiException catch (e) {
      mensajero
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(e.mensaje),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
        );
    }
  }
}

class _VistaError extends StatelessWidget {
  final String mensaje;
  final Future<void> Function() onReintentar;

  const _VistaError({
    required this.mensaje,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 56, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: AppColors.textDark),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onReintentar,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar conexión'),
            ),
          ],
        ),
      ),
    );
  }
}
