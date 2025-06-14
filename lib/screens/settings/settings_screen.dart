import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:spiritual_meter/models/notification_setting.dart';
import 'package:spiritual_meter/screens/settings/settings_viewmodel.dart';
import 'package:spiritual_meter/core/constant.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = context.read<SettingsViewModel>();

    Future.microtask(() async {
      await viewModel.loadNotifications();
    });
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat('HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).primaryColor;
    final bodySmallColor = textTheme.bodySmall!.color!;
    final titleLargeColor = textTheme.titleLarge!.color!;

    return Consumer<SettingsViewModel>(
      builder: (context, model, child) {
        final notifications = model.notifications;

        if (notifications.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Configuración')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final prayerNotifications =
            notifications.where((n) => n.type == kActivityTypePrayer).toList();
        final bibleNotifications =
            notifications
                .where((n) => n.type == kActivityTypeBibleReading)
                .toList();

        return Scaffold(
          appBar: AppBar(title: const Text('Configuración')),
          body: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildNotificationSection(
                title: 'Notificación Oraciones',
                notifications: prayerNotifications,
                primaryColor: primaryColor,
                titleColor: titleLargeColor,
                bodyColor: bodySmallColor,
                textTheme: textTheme,
                customHeaderWidget: Container(
                  padding: const EdgeInsets.all(12.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                  child: Text(
                    "...se arrodillaba tres veces al día, y oraba y daba gracias delante de su Dios...\nDaniel 6:10",
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              _buildNotificationSection(
                title: 'Notificación Lectura Bíblica',
                notifications: bibleNotifications,
                primaryColor: primaryColor,
                titleColor: titleLargeColor,
                bodyColor: bodySmallColor,
                textTheme: textTheme,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationSection({
    required String title,
    required List<NotificationSetting> notifications,
    required Color primaryColor,
    required Color titleColor,
    required Color bodyColor,
    required TextTheme textTheme,
    Widget? customHeaderWidget,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
        ),
        if (customHeaderWidget != null)
          Column(children: [customHeaderWidget, const SizedBox(height: 16)]),

        ...notifications.map((notification) {
          return Card(
            // margin: const EdgeInsets.symmetric(vertical: 6.0),
            child: ListTile(
              leading: Icon(
                notification.type == kActivityTypePrayer
                    ? Icons.self_improvement
                    : Icons.book,
                color: notification.isEnabled ? primaryColor : bodyColor,
              ),
              title: Text(
                '${_formatTimeOfDay(notification.timeOfDay)} - ${notification.label}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: notification.isEnabled ? titleColor : bodyColor,
                ),
              ),
              trailing: Switch(
                value: notification.isEnabled,
                onChanged: (bool value) async {
                  await viewModel.toggleNotification(notification.id, value);
                },
              ),
              onTap: () async {
                final newTime = await showTimePicker(
                  context: context,
                  initialTime: notification.timeOfDay,
                  builder: (BuildContext context, Widget? child) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        alwaysUse24HourFormat: false,
                        textScaler: const TextScaler.linear(0.9),
                      ),
                      child: child!,
                    );
                  },
                );
                if (newTime != null) {
                  viewModel.updateTime(notification.id, newTime);
                }
              },
            ),
          );
        }),
      ],
    );
  }
}
