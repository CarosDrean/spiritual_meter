import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:spiritual_meter/screens/records/records_viewmodel.dart';
import 'package:spiritual_meter/models/activity_log.dart';
import 'package:spiritual_meter/utils/formatters.dart';

class RecordScreen extends StatefulWidget {
  const RecordScreen({super.key});

  @override
  State<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends State<RecordScreen> {
  late RecordViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = context.read<RecordViewModel>();

    Future.microtask(() async {
      await viewModel.loadActivityLogs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RecordViewModel>(
      builder: (context, model, child) {
        final logs = model.logs;

        return Scaffold(
          appBar: AppBar(title: const Text('Registro de Actividades')),
          body:
              logs.isEmpty
                  ? const Center(
                    child: Text('No hay actividades registradas aún.'),
                  )
                  : _buildList(logs),
        );
      },
    );
  }

  Widget _buildList(List<ActivityLog> logs) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final viewModel = context.read<RecordViewModel>();

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];

        return Dismissible(
          key: Key(log.id!.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder:
                  (_) => AlertDialog(
                    title: const Text("Confirmar Eliminación"),
                    content: const Text("¿Eliminar este registro?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text("Cancelar"),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text("Eliminar"),
                      ),
                    ],
                  ),
            );
          },
          onDismissed: (_) {
            viewModel.deleteActivity(log.id!);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
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
}
