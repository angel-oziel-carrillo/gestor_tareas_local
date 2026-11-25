import 'package:flutter/material.dart';
import '../data/database.dart';
import '../models/tarea.dart';


// Pantalla base SIN persistencia ni operaciones CRUD implementadas.
// Conserva las indicaciones TODO para orientar tu trabajo.
class TareasPage extends StatefulWidget {
  final AppDatabase database;

  const TareasPage({super.key, required this.database});

  @override
  State<TareasPage> createState() => _TareasPageState();
}

class _TareasPageState extends State<TareasPage> {
  final TextEditingController _tituloController = TextEditingController();

  //List<Tarea> _tareas = [];
  late Stream<List<TareaModelo>> _tareasStream;

  @override
  void initState() {
    super.initState();

    _tareasStream = widget.database.consultarTareas();
  }

  Future<void> _agregarTarea() async{
    final resultado = await widget.database.agregarTarea(_tituloController.text);
    if (!mounted) return;
    if(resultado == null){
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese un titulo valido'),),
      );
      return;
    }

    _tituloController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nueva tarea agregada correctamente'),),
    );
  }

  void _alternarCompletada(TareaModelo tarea, bool completada) {
    _pendiente('Implementar actualización de tarea');
  }

  void _editarTarea(TareaModelo tarea) {
    _pendiente('Implementar edición de título');
  }

  void _eliminarTarea(TareaModelo tarea) {
    _pendiente('Implementar eliminación de tarea');
  }

  void _pendiente(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  void dispose() {
    _tituloController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestor de tareas')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Nueva tarea',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _agregarTarea,
              icon: const Icon(Icons.add),
              label: const Text('Agregar tarea'),
            ),
            const SizedBox(height: 12),
            const Text('Mis tareas', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Expanded(
              //child: _tareas.isEmpty
              child: StreamBuilder<List<TareaModelo>>(
                stream: _tareasStream,
                builder: (context, snapshot){
                  if (snapshot.hasError){
                    return Center(
                      child: Text('Error al consultar tareas')
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting){
                    return const Center(
                      child: CircularProgressIndicator()
                    );
                  }

                  final tareas = snapshot.data ?? [];
                  if(tareas.isEmpty){
                    return const Center(child: Text('Todavía no hay tareas guardadas'));
                  }
                  return ListView.builder(
                      itemCount: tareas.length,
                      itemBuilder: (context, index) {
                        final tarea = tareas[index];
                        return Card(
                          child: ListTile(
                            leading: Checkbox(
                              value: tarea.completada,
                              onChanged: null,
                            ),
                            title: Text(tarea.titulo),
                            subtitle: Text('ID: ${tarea.id}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Editar',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editarTarea(tarea),
                                ),
                                IconButton(
                                  tooltip: 'Eliminar',
                                  icon: const Icon(Icons.delete_outline),
                                  onPressed: () => _eliminarTarea(tarea),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
