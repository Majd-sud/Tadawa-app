import 'package:flutter/material.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:intl/intl.dart';
import 'package:tadawa_app/widgets/medication_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tadawa_app/generated/l10n.dart';

class AddMedicationScreen extends StatefulWidget {
  final Medication? medication;

  const AddMedicationScreen({super.key, this.medication});

  @override
  State<AddMedicationScreen> createState() {
    return _AddMedicationScreenState();
  }
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _nameController = TextEditingController();
  final _scheduleController = TextEditingController();
  final _notesController = TextEditingController();
  final _pillsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _expirationDate;
  TimeOfDay? _time;
  int _pillsCount = 1;
  String? _selectedSchedule;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      _nameController.text = widget.medication!.name;
      _startDate = widget.medication!.startDate;
      _endDate = widget.medication!.endDate;
      _scheduleController.text = widget.medication!.schedule;
      _expirationDate = widget.medication!.expirationDate;
      _notesController.text = widget.medication!.notes;
      _time = widget.medication!.time;
      _pillsCount = widget.medication!.pillsCount;
      _pillsController.text = _pillsCount.toString();
      _selectedSchedule = widget.medication!.frequency;
    }
  }

  void _presentDatePicker(String dateType) async {
    final now = DateTime.now();
    DateTime? pickedDate;

    if (dateType == 'start') {
      pickedDate = await showDatePicker(
        context: context,
        initialDate: _startDate ?? now,
        firstDate: DateTime(now.year - 1),
        lastDate: DateTime(now.year + 5),
      );
    } else if (dateType == 'end') {
      pickedDate = await showDatePicker(
        context: context,
        initialDate: _endDate ?? now,
        firstDate: _startDate ?? now,
        lastDate: DateTime(now.year + 5),
      );
    } else if (dateType == 'expiration') {
      pickedDate = await showDatePicker(
        context: context,
        initialDate: _expirationDate ?? now,
        firstDate: now,
        lastDate: DateTime(now.year + 10),
      );
    }

    if (pickedDate != null) {
      setState(() {
        if (dateType == 'start') {
          _startDate = pickedDate;
        } else if (dateType == 'end') {
          _endDate = pickedDate;
        } else if (dateType == 'expiration') {
          _expirationDate = pickedDate;
        }
      });
    }
  }

  void _presentTimePicker() async {
    final TimeOfDay now = TimeOfDay.now();
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (pickedTime != null) {
      setState(() {
        _time = pickedTime;
      });
    }
  }

  void _saveMedication() async {
    if (_nameController.text.isEmpty ||
        _startDate == null ||
        _endDate == null ||
        _expirationDate == null ||
        _time == null ||
        _selectedSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(S.of(context).pleaseFillAllFields)),
      );
      return;
    }

    final medication = Medication(
      name: _nameController.text,
      startDate: _startDate!,
      endDate: _endDate!,
      schedule: _scheduleController.text,
      expirationDate: _expirationDate!,
      notes: _notesController.text,
      pillsCount: _pillsCount,
      time: _time!,
      frequency: _selectedSchedule ?? S.of(context).daily,
    );

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      if (widget.medication == null) {
        // Adding a new medication
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('medications')
            .add({
          'name': medication.name,
          'startDate': medication.startDate,
          'endDate': medication.endDate,
          'expirationDate': medication.expirationDate,
          'notes': medication.notes,
          'pillsCount': medication.pillsCount,
          'time': medication.time.format(context),
          'frequency': medication.frequency,
        });
      } else {
        // Updating existing medication
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('medications')
            .doc(widget.medication!.id)
            .update({
          'name': medication.name,
          'startDate': medication.startDate,
          'endDate': medication.endDate,
          'expirationDate': medication.expirationDate,
          'notes': medication.notes,
          'pillsCount': medication.pillsCount,
          'time': medication.time.format(context),
          'frequency': medication.frequency,
        });
      }
    }

    Navigator.pop(context, medication);
  }

  void _selectSchedule(String schedule) {
    setState(() {
      _selectedSchedule = schedule;
    });
  }

  void _decreasePillCount() {
    setState(() {
      if (_pillsCount > 1) {
        _pillsCount--;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(255, 254, 247, 255),
        title: Text(
          widget.medication != null
              ? S.of(context).editMedication
              : S.of(context).addMedication,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nameController, S.of(context).medicationName),
              MedicationImage(
                onImageSelected: (imagePath) {
                  setState(() {});
                },
                initialImagePath: null,
              ),
              _buildDateRow(S.of(context).startDate, _startDate,
                  () => _presentDatePicker('start')),
              _buildDateRow(S.of(context).endDate, _endDate,
                  () => _presentDatePicker('end')),
              _buildTimeRow(),
              const SizedBox(height: 20),
              _buildScheduleButtons(),
              const SizedBox(height: 20),
              _buildPillCountPicker(),
              _buildDateRow(S.of(context).expirationDate, _expirationDate,
                  () => _presentDatePicker('expiration')),
              _buildTextField(_notesController, S.of(context).notes),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMedication,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: const Color.fromARGB(255, 46, 161, 132),
                  elevation: 5,
                ),
                child: Text(
                  S.of(context).saveMedication,
                  style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white), // Ensure text is white here
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        maxLength: 50,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.all(10),
        ),
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime? date, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          date == null ? label : DateFormat.yMMMd().format(date),
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          onPressed: onPressed,
          icon: const Icon(Icons.calendar_today),
        ),
      ],
    );
  }

  Widget _buildTimeRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          _time == null ? S.of(context).time : _time!.format(context),
          style: const TextStyle(fontSize: 16),
        ),
        IconButton(
          onPressed: _presentTimePicker,
          icon: const Icon(Icons.access_time),
        ),
      ],
    );
  }

  Widget _buildScheduleButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        ElevatedButton(
          onPressed: () => _selectSchedule(S.of(context).daily),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedSchedule == S.of(context).daily
                ? const Color.fromARGB(255, 46, 161, 132)
                : Colors.grey,
          ),
          child: Text(S.of(context).daily,
              style: const TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () => _selectSchedule(S.of(context).weekly),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedSchedule == S.of(context).weekly
                ? const Color.fromARGB(255, 46, 161, 132)
                : Colors.grey,
          ),
          child: Text(S.of(context).weekly,
              style: const TextStyle(color: Colors.white)),
        ),
        ElevatedButton(
          onPressed: () => _selectSchedule(S.of(context).monthly),
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedSchedule == S.of(context).monthly
                ? const Color.fromARGB(255, 46, 161, 132)
                : Colors.grey,
          ),
          child: Text(S.of(context).monthly,
              style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _buildPillCountPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${S.of(context).pillsCount}: $_pillsCount',
          style: const TextStyle(fontSize: 16),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                if (_pillsCount > 1) {
                  setState(() {
                    _pillsCount--;
                  });
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _pillsCount++;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
