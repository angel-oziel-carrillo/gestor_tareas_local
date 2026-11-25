/// Modelo inicial de tarea. No contiene código de SQLite.
/// Investiga cómo representar estos campos en una tabla persistente.
class TareaModelo {
  final int id;
  final String titulo;
  final bool completada;

  const TareaModelo({
    required this.id,
    required this.titulo,
    required this.completada,
  });
}
