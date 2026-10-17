import 'package:flutter/material.dart';

import 'task.dart';
import 'validadores_tarea.dart';

class NuevaTareaScreen extends StatefulWidget {
  final Task? tareaInicial;

  const NuevaTareaScreen({super.key, this.tareaInicial});

  @override
  State<NuevaTareaScreen> createState() => _NuevaTareaScreenState();
}

class _NuevaTareaScreenState extends State<NuevaTareaScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloCtrl;
  late final TextEditingController _descripcionCtrl;
  late final TextEditingController _fechaCtrl;
  final _descripcionFocus = FocusNode();

  DateTime? _fechaLimite;
  Priority _prioridad = Priority.media;
  String _categoria = 'General';

  static const _categorias = ['General', 'Diseño UX', 'Desarrollo', 'Gestión', 'Estudio', 'Personal'];

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.tareaInicial?.title ?? '');
    _descripcionCtrl = TextEditingController(text: widget.tareaInicial?.descText ?? '');
    _fechaCtrl = TextEditingController();

    if (widget.tareaInicial != null) {
      _prioridad = widget.tareaInicial!.priority;
      _categoria = widget.tareaInicial!.category;
      _fechaLimite = widget.tareaInicial!.dueDate;
      if (_fechaLimite != null) {
        _fechaCtrl.text =
            '${_fechaLimite!.day.toString().padLeft(2, '0')}/'
            '${_fechaLimite!.month.toString().padLeft(2, '0')}/${_fechaLimite!.year}';
      }
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descripcionCtrl.dispose();
    _fechaCtrl.dispose();
    _descripcionFocus.dispose();
    super.dispose();
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();
    final elegida = await showDatePicker(
      context: context,
      initialDate: _fechaLimite ?? hoy,
      firstDate: DateTime(hoy.year, hoy.month, hoy.day),
      lastDate: DateTime(hoy.year + 2),
      helpText: 'Fecha límite de la tarea',
    );
    if (elegida == null || !mounted) return;
    setState(() {
      _fechaLimite = elegida;
      _fechaCtrl.text =
          '${elegida.day.toString().padLeft(2, '0')}/'
          '${elegida.month.toString().padLeft(2, '0')}/${elegida.year}';
    });
  }

  void _guardar() {
    if (!_formKey.currentState!.validate()) return;

    final tarea = Task(
      id: widget.tareaInicial?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: _tituloCtrl.text.trim(),
      description: _descripcionCtrl.text.trim(),
      dueDate: _fechaLimite!,
      category: _categoria,
      priority: _prioridad,
      isCompleted: widget.tareaInicial?.isCompleted ?? false,
    );
    Navigator.pop(context, tarea);
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.tareaInicial != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar tarea' : 'Nueva tarea'),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloCtrl,
              decoration: const InputDecoration(
                labelText: 'Título *',
                helperText: 'Obligatorio, entre 3 y 60 caracteres',
                border: OutlineInputBorder(),
              ),
              maxLength: ValidadoresTarea.tituloMax,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) => _descripcionFocus.requestFocus(),
              validator: ValidadoresTarea.titulo,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descripcionCtrl,
              focusNode: _descripcionFocus,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 2,
              maxLines: 4,
              maxLength: ValidadoresTarea.descripcionMax,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              validator: ValidadoresTarea.descripcion,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _fechaCtrl,
              readOnly: true,
              onTap: _elegirFecha,
              decoration: const InputDecoration(
                labelText: 'Fecha límite *',
                hintText: 'Toca para elegir',
                suffixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              validator: (_) => ValidadoresTarea.fechaLimite(_fechaLimite),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<Priority>(
              value: _prioridad,
              decoration: const InputDecoration(
                labelText: 'Prioridad',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: Priority.baja, child: Text('Baja')),
                DropdownMenuItem(value: Priority.media, child: Text('Media')),
                DropdownMenuItem(value: Priority.alta, child: Text('Alta')),
              ],
              onChanged: (valor) => setState(() => _prioridad = valor ?? Priority.media),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final c in _categorias)
                  DropdownMenuItem(value: c, child: Text(c)),
              ],
              onChanged: (valor) => setState(() => _categoria = valor ?? 'General'),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardar,
              icon: const Icon(Icons.check),
              label: Text(esEdicion ? 'Actualizar tarea' : 'Guardar tarea'),
            ),
          ],
        ),
      ),
    );
  }
}
