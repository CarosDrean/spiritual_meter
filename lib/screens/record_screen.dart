import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:spiritual_meter/services/database_helper.dart';
import 'package:spiritual_meter/models/activity_log.dart';
import 'package:spiritual_meter/utils/formatters.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late Future<List<ActivityLog>> _activityLogsFuture;
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadActivityLogs();
  }

  Future<void> _loadActivityLogs() async {
    setState(() {
      _activityLogsFuture = _dbHelper.getActivityLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro de Actividades')),
      body: FutureBuilder<List<ActivityLog>>(
        future: _activityLogsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No hay actividades registradas aún.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final log = snapshot.data![index];
                final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

                return Dismissible(
                  key: Key(log.id!.toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Confirmar Eliminación"),
                          content: const Text(
                            "¿Estás seguro de que quieres eliminar este registro?",
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("Cancelar"),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text("Eliminar"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onDismissed: (direction) async {
                    await _dbHelper.deleteActivityLog(log.id!);

                    // Recargar la lista para actualizar la UI (si _activityLogsFuture es una variable de estado)
                    // O si no usas FutureBuilder de esta forma, podrías remover el elemento localmente
                    // si gestionas la lista en el State (ej. List<ActivityLog> _logs = [];)
                    _loadActivityLogs();
                  },
                  child: Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        // <-- ¡ENVUELVE EL COLUMN CON SIZEDBOX!
                        width: double.infinity,
                        // <-- Fuerza al SizedBox a ocupar el máximo ancho
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tipo: ${log.activityType == "prayer" ? "Oración" : "Lectura Bíblica"}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Duración: ${formatDuration(log.durationInSeconds)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Fecha: ${dateFormat.format(log.endTime)}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
