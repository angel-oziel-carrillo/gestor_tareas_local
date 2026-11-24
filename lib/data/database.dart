import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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
}