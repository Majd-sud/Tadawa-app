import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tadawa_app/notification_service.dart';
import 'package:tadawa_app/theme.dart';
import 'package:tadawa_app/theme_providor.dart';
import 'package:tadawa_app/generated/l10n.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Medication> _medications = [];
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    tz.initializeTimeZones();
    _setLocalTimeZone();
    NotificationService.initialize();
    _fetchMedications();
  }

  Future<void> _setLocalTimeZone() async {
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  Future<void> _fetchMedications() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('medications')
            .get();

        setState(() {
          _medications = snapshot.docs
              .map((doc) => Medication.fromFirestore(doc.data(), doc.id))
              .toList();
        });

        await _scheduleNotifications();
      } catch (e) {
        print(S.of(context).errorFetchingMedications + ": $e");
      }
    } else {
      print(S.of(context).defaultUserName);
    }
  }

  bool _hasLowPills() {
    return _medications.any((medication) => medication.pillsCount < 5);
  }

  Future<void> _scheduleNotifications() async {
    for (var medication in _medications) {
      final List<DateTime> reminderDates = _generateReminderDates(
        medication.startDate,
        medication.endDate,
        medication.frequency,
        medication.time,
      );

      for (var reminderDate in reminderDates) {
        final tz.TZDateTime localDateTime = tz.TZDateTime(
          tz.local,
          reminderDate.year,
          reminderDate.month,
          reminderDate.day,
          medication.time.hour,
          medication.time.minute,
        );

        if (localDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
          continue;
        }

        await _scheduleNotification(medication, localDateTime);
      }

      if (!medication.isExpired()) {
        await _scheduleExpiryNotification(medication);
      }
    }
  }

  Future<void> _scheduleExpiryNotification(Medication medication) async {
    final tz.TZDateTime localDateTime =
        tz.TZDateTime.from(medication.expirationDate, tz.local);

    if (localDateTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
      medication.id.hashCode ^ medication.expirationDate.millisecondsSinceEpoch,
      S.of(context).warningExpirationSoon,
      '${S.of(context).medicationName}: "${medication.name}"',
      localDateTime.subtract(Duration(days: 1)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medication_channel',
          'Medication Expiry Alerts',
          channelDescription: 'Channel for medication expiry alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _scheduleNotification(
      Medication medication, tz.TZDateTime localDateTime) async {
    try {
      await NotificationService.flutterLocalNotificationsPlugin.zonedSchedule(
        medication.id.hashCode ^ localDateTime.millisecondsSinceEpoch,
        S.of(context).notification,
        '${S.of(context).time}: ${medication.name}',
        localDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'medication_channel',
            'Medication Reminders',
            channelDescription: 'Channel for medication reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exact,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print(S.of(context).errorFetchingMedications + ": $e");
    }
  }

  List<DateTime> _generateReminderDates(DateTime start, DateTime end,
      String frequency, TimeOfDay medicationTime) {
    List<DateTime> reminderDates = [];
    DateTime currentDate = start;

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      reminderDates.add(DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        medicationTime.hour,
        medicationTime.minute,
      ));

      switch (frequency) {
        case 'Daily':
          currentDate = currentDate.add(const Duration(days: 1));
          break;
        case 'Weekly':
          currentDate = currentDate.add(const Duration(days: 7));
          break;
        case 'Monthly':
          currentDate = DateTime(
              currentDate.year, currentDate.month + 1, currentDate.day);
          break;
        default:
          break;
      }
    }

    return reminderDates;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 254, 247, 255),
        title: Text(S.of(context).medications),
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 20),
          Expanded(
            child: _buildMedicationList(),
          ),
          if (_medications.any((medication) =>
              medication.expirationDate
                  .isBefore(DateTime.now().add(const Duration(days: 7))) &&
              !medication.isExpired()))
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                color: Colors.orange[200],
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  S.of(context).warningExpirationSoon,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          if (_hasLowPills())
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                color: Colors.yellow[200],
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  S.of(context).warningPillsLow,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMedicationList() {
    final todaysMedications = _getTodaysMedications(_selectedDate);

    if (todaysMedications.isEmpty) {
      return Center(
        child: Text(S.of(context).errorFetchingMedications),
      );
    }

    return ListView.builder(
      itemCount: todaysMedications.length,
      itemBuilder: (context, index) {
        final medication = todaysMedications[index];
        return Card(
          color: const Color.fromRGBO(247, 242, 250, 1),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(medication.name),
            subtitle: Text(
              '${S.of(context).time}: ${medication.time.format(context)}',
            ),
            trailing: Checkbox(
              value: medication.takenStatus[_selectedDate] ?? false,
              onChanged: (value) {
                setState(() {
                  medication.takenStatus[_selectedDate] = value ?? false;
                  if (value == true && medication.pillsCount > 0) {
                    medication.pillsCount -= 1;
                  }
                });
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildDateSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.subtract(const Duration(days: 1));
            });
          },
        ),
        Text(
          DateFormat.yMMMMd().format(_selectedDate),
          style: const TextStyle(fontSize: 20),
        ),
        IconButton(
          icon: const Icon(Icons.arrow_forward),
          onPressed: () {
            setState(() {
              _selectedDate = _selectedDate.add(const Duration(days: 1));
            });
          },
        ),
      ],
    );
  }

  List<Medication> _getTodaysMedications(DateTime date) {
    return _medications.where((medication) {
      final reminderDates = _generateReminderDates(
        medication.startDate,
        medication.endDate,
        medication.frequency,
        medication.time,
      );

      return reminderDates.any((reminderDate) {
        return reminderDate.year == date.year &&
            reminderDate.month == date.month &&
            reminderDate.day == date.day;
      });
    }).toList();
  }
}
