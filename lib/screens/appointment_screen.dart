import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tadawa_app/models/appointment.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  _AppointmentScreenState createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  late final ValueNotifier<List<Appointment>> _selectedAppointments;
  late DateTime _focusedDay;
  late DateTime _selectedDay;
  final Map<DateTime, List<Appointment>> _appointments = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _selectedDay = DateTime.now();
    _selectedAppointments = ValueNotifier<List<Appointment>>([]);

    // Fetch appointments from Firestore
    _fetchAppointments();
  }

  void _fetchAppointments() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .snapshots()
          .listen((snapshot) {
        _appointments.clear();
        for (var doc in snapshot.docs) {
          try {
            var appointment = Appointment.fromFirestore(doc.data(), doc.id);
            DateTime appointmentDate = DateTime(
              appointment.date.year,
              appointment.date.month,
              appointment.date.day,
            );

            // Add appointment to the map
            _appointments.putIfAbsent(appointmentDate, () => []).add(appointment);
          } catch (e) {
            print("Error parsing appointment: ${doc.data()} - $e");
          }
        }

        // Update the selected appointments for the current selected day
        _updateSelectedAppointments();
        
        // Update the calendar markers
        setState(() {});
      }, onError: (error) {
        print("Error fetching appointments: $error");
      });
    } else {
      print("No user is signed in.");
    }
  }

  void _updateSelectedAppointments() {
    _selectedAppointments.value = _getAppointmentsForDay(_selectedDay);
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    return _appointments[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _updateSelectedAppointments();
      });
    }
  }

  void _addOrEditAppointment({Appointment? appointment}) async {
    String appointmentName = appointment?.title ?? '';
    TimeOfDay selectedTime = appointment?.time ?? TimeOfDay.now();
    DateTime selectedDate = appointment?.date ?? _selectedDay;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(appointment == null ? 'Add Appointment' : 'Edit Appointment'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      appointmentName = value;
                    },
                    decoration: const InputDecoration(hintText: "Enter appointment"),
                    controller: TextEditingController(text: appointmentName),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(selectedTime.format(context)),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (pickedTime != null) {
                            setDialogState(() {
                              selectedTime = pickedTime;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text("Date: ${selectedDate.toLocal()}".split(' ')[0]),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.utc(2030, 12, 31),
                      );
                      if (pickedDate != null) {
                        setDialogState(() {
                          selectedDate = pickedDate;
                        });
                      }
                    },
                    child: const Text("Select Date"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (appointmentName.isNotEmpty) {
                      _saveAppointment(
                        appointment: appointment != null
                            ? appointment.copyWith(
                                title: appointmentName,
                                time: selectedTime,
                                date: selectedDate)
                            : Appointment(
                                id: UniqueKey().toString(), // Only for new appointments
                                title: appointmentName,
                                time: selectedTime,
                                date: selectedDate,
                              ),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(appointment == null ? 'Add' : 'Update'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveAppointment({required Appointment appointment}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final appointmentData = appointment.toMap(context);

      // Always update, regardless of whether it's new or existing
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .doc(appointment.id)
          .set(appointmentData, SetOptions(merge: true));

      // Update local state
      final index = _appointments[appointment.date]?.indexWhere((a) => a.id == appointment.id);
      if (index != null && index >= 0) {
        _appointments[appointment.date]![index] = appointment;
      } else {
        _appointments[appointment.date]?.add(appointment);
      }

      // Update the selected appointments
      _updateSelectedAppointments();
    }
  }

  void _deleteAppointment(Appointment appointment) {
    setState(() {
      _appointments[_selectedDay]?.remove(appointment);
      _updateSelectedAppointments();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${appointment.title} deleted'),
        duration: const Duration(seconds: 2),
      ),
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('appointments')
          .doc(appointment.id)
          .delete();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditAppointment(),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<Appointment>(
            focusedDay: _focusedDay,
            currentDay: _selectedDay,
            onDaySelected: _onDaySelected,
            eventLoader: (day) {
              return _getAppointmentsForDay(day);
            },
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(255, 46, 161, 132), // Selected color
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 46, 161, 132), // Today color
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Color.fromARGB(255, 46, 161, 132), // Marker color
                shape: BoxShape.circle,
              ),
              markersMaxCount: 1,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ValueListenableBuilder<List<Appointment>>(
              valueListenable: _selectedAppointments,
              builder: (context, value, _) {
                return ListView.builder(
                  itemCount: value.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      elevation: 4,
                      child: ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(
                          value[index].title,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Time: ${value[index].time.format(context)}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        onTap: () => _addOrEditAppointment(appointment: value[index]),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteAppointment(value[index]),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}