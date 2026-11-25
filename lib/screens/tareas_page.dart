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

  Future<void> _alternarCompletada(TareaModelo tarea, bool completada) async{
    try{
      final resultado = await widget.database.actualizarEstado(tarea.id, completada,);

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (resultado > 0) ? 'Estado actualizado correctamente' : 'La tarea no se encontró',),
        ),
      );
    }
    catch(e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar el estado',),
        ),
      );
    }
  }

  Future<void> _editarTarea(TareaModelo tarea) async{
    final controller = TextEditingController(text: tarea.titulo);
    final nuevoTitulo = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar tarea'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Nuevo titulo',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (valor){
              Navigator.pop(context, valor);
            },
          ),
          actions: [
            TextButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: (){
                Navigator.pop(context, controller.text);
              },
              child: const Text('Guardar'),
            )
          ],
        );
      },
    );

    controller.dispose();

    if(!mounted || nuevoTitulo == null) return;

    try {
      final resultado = await widget.database.actualizarTitulo(tarea.id, nuevoTitulo);
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (resultado > 0) ? 'Tarea actualizada correctamente' : 'Error al actualizar la tarea',
          ),
        ),
      );
    }
    catch(e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar la tarea',),
        ),
      );
    }
  }

  void _eliminarTarea(TareaModelo tarea) async{
    try{
      final resultado = await widget.database.eliminarTarea(tarea.id);

      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            (resultado > 0) ? 'Tarea eliminada correctamente' : 'La tarea no se encontró',),
        ),
      );
    }
    catch(e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la tarea',),
        ),
      );
    }
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
                              onChanged: (valor) {
                                if(valor!=null){
                                  _alternarCompletada(tarea, valor);
                                }
                              },
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
