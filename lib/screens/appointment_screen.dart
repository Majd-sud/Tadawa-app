import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:tadawa_app/models/appointment.dart'; 

class AppointmentScreen extends StatefulWidget {
  final List<Appointment> initialAppointments; 
  const AppointmentScreen({super.key, required this.initialAppointments});

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
    _selectedAppointments = ValueNotifier(_getAppointmentsForDay(_selectedDay));

    for (var appointment in widget.initialAppointments) {
      if (_appointments[_selectedDay] == null) {
        _appointments[_selectedDay] = [];
      }
      _appointments[_selectedDay]!.add(appointment);
    }
  }

  List<Appointment> _getAppointmentsForDay(DateTime day) {
    return _appointments[day] ?? [];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
      _selectedAppointments.value = _getAppointmentsForDay(selectedDay);
    }
  }

  void _addOrEditAppointment({Appointment? appointment}) async {
    String appointmentName = appointment?.title ?? '';
    TimeOfDay? selectedTime = appointment?.time;

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
                      Text(selectedTime != null ? selectedTime!.format(context) : 'Select Time'),
                      IconButton(
                        icon: const Icon(Icons.access_time),
                        onPressed: () async {
                          final pickedTime = await showTimePicker(
                            context: context,
                            initialTime: selectedTime ?? TimeOfDay.now(),
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (appointmentName.isNotEmpty && selectedTime != null) {
                      setState(() {
                        if (appointment == null) {
                          if (_appointments[_selectedDay] == null) {
                            _appointments[_selectedDay] = [];
                          }
                          _appointments[_selectedDay]!.add(Appointment(appointmentName, selectedTime!));
                        } else {
                          final index = _appointments[_selectedDay]!.indexOf(appointment);
                          _appointments[_selectedDay]![index] = Appointment(appointmentName, selectedTime!);
                        }
                        _selectedAppointments.value = _getAppointmentsForDay(_selectedDay);
                      });
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

  void _deleteAppointment(Appointment appointment) {
    setState(() {
      _appointments[_selectedDay]?.remove(appointment);
      _selectedAppointments.value = _getAppointmentsForDay(_selectedDay);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${appointment.title} deleted'),
        duration: const Duration(seconds: 2),
      ),
    );
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
            eventLoader: (day) => _getAppointmentsForDay(day),
            firstDay: DateTime.utc(2024, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
            ),
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color.fromARGB(255, 52, 52, 52),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Color.fromARGB(255, 52, 52, 52),
                shape: BoxShape.circle,
              ),
              defaultDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              weekendDecoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
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
          ),
        ],
      ),
    );
  }
}