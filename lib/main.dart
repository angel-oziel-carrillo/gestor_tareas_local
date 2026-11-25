import 'package:flutter/material.dart';
import 'screens/tareas_page.dart';
import 'data/database.dart';

void main() {
  final database = AppDatabase();
  runApp(GestorTareasApp(database: database));
}

/// Punto de entrada de la aplicación.
/// La configuración del almacenamiento se agregará como parte de la tarea.
class GestorTareasApp extends StatelessWidget {
  final AppDatabase database;
  const GestorTareasApp({super.key, required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestor de tareas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: TareasPage(database: database),
    );
  }
}
