import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import '../models/tarea.dart';

part 'database.g.dart';

class Tareas extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get titulo => text()();
  BoolColumn get completada => boolean().withDefault(const Constant(false))();
}

@DriftDatabase(tables: [Tareas])
class AppDatabase extends _$AppDatabase{
  AppDatabase(): super(driftDatabase(name: 'gestor_tareas'),);
  @override
  int get schemaVersion => 1;

  //F1
  Future<int?> agregarTarea(String titulo){
    final texto = titulo.trim();
    if(texto.isEmpty){
      return Future.value(null);
    }

    return into(tareas).insert(TareasCompanion.insert(titulo: texto,),);
  }

  //F2
  Stream<List<TareaModelo>> consultarTareas(){
    return select(tareas).watch().map((List<Tarea> filas) {
      return filas.map((fila) {
        return TareaModelo(id: fila.id, titulo: fila.titulo, completada: fila.completada,);
      }).toList();
    });
  }

  //F3
  Future<int> actualizarTitulo(int id, String titulo) async{
    final texto = titulo.trim();
    if(texto.isEmpty){
      return 0;
    }
    
    final filasActualizadas = await (update(tareas)..where((tabla) => tabla.id.equals(id))).write(TareasCompanion(titulo: Value(texto),),);
    return filasActualizadas;
  }

  //F4
  Future<int> actualizarEstado(int id, bool completada) async {
    final filasActualizadas = await (update(tareas)..where((tabla) => tabla.id.equals(id))).write(TareasCompanion(completada: Value(completada),),);
    return filasActualizadas;
  }

  //F5
  Future<int> eliminarTarea(int id) async {
    final filasEliminadas = await (delete(tareas)..where((tabla) => tabla.id.equals(id))).go();
    return filasEliminadas;
  }
}