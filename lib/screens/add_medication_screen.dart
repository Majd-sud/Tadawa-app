import 'package:flutter/material.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:intl/intl.dart';
import 'package:tadawa_app/widgets/medication_image.dart';

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
  final TextEditingController _pillsController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  DateTime? _expirationDate;
  TimeOfDay? _time;
  int _pillsCount = 1;
  String? _selectedSchedule;
  String? _photoUrl;

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
      _photoUrl = widget.medication!.photoUrl;
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

  void _saveMedication() {
    if (_nameController.text.isEmpty ||
        _startDate == null ||
        _endDate == null ||
        _expirationDate == null ||
        _time == null ||
        _selectedSchedule == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
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
      photoUrl: _photoUrl!,
      frequency: _selectedSchedule ?? 'Daily',
    );

    Navigator.pop(context, medication);
  }

  void _selectSchedule(String schedule) {
    setState(() {
      _selectedSchedule = schedule;
    });
  }

  void _updatePillsCount(int change) {
    setState(() {
      _pillsCount += change;
      if (_pillsCount < 1) _pillsCount = 1;
      _pillsController.text = _pillsCount.toString();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scheduleController.dispose();
    _notesController.dispose();
    _pillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.medication != null ? 'Edit Medication' : 'Add Medication'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField(_nameController, 'Medication Name'),
              MedicationImage(
                onImageSelected: (imagePath) {
                  setState(() {
                    _photoUrl = imagePath;
                  });
                },
                initialImagePath: _photoUrl,
              ),
              _buildDateRow(
                  'Start Date', _startDate, () => _presentDatePicker('start')),
              _buildDateRow(
                  'End Date', _endDate, () => _presentDatePicker('end')),
              _buildTimeRow(),
              SizedBox(height: 20),
              _buildScheduleButtons(), // Ensure this reflects the selected frequency
              SizedBox(height: 20),
              _buildPillCountPicker(),
              _buildDateRow('Expiration Date', _expirationDate,
                  () => _presentDatePicker('expiration')),
              _buildTextField(_notesController, 'Notes'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMedication,
                child: const Text('Save Medication'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Card(
      elevation: 4,
      child: TextField(
        controller: controller,
        maxLength: 50,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.all(10),
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
          style: TextStyle(fontSize: 16),
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
          _time == null ? 'Start Time' : _time!.format(context),
          style: TextStyle(fontSize: 16),
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
          onPressed: () => _selectSchedule('Daily'),
          child: Text('Daily'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _selectedSchedule == 'Daily' ? Colors.blue : Colors.grey,
          ),
        ),
        ElevatedButton(
          onPressed: () => _selectSchedule('Weekly'),
          child: Text('Weekly'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _selectedSchedule == 'Weekly' ? Colors.blue : Colors.grey,
          ),
        ),
        ElevatedButton(
          onPressed: () => _selectSchedule('Monthly'),
          child: Text('Monthly'),
          style: ElevatedButton.styleFrom(
            backgroundColor:
                _selectedSchedule == 'Monthly' ? Colors.blue : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildPillCountPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: () => _updatePillsCount(-1),
        ),
        Container(
          width: 50,
          child: TextField(
            controller: _pillsController,
            decoration: const InputDecoration(labelText: 'Pills'),
            textAlign: TextAlign.center,
            readOnly: true,
          ),
        ),
        IconButton(
          icon: Icon(Icons.add),
          onPressed: () => _updatePillsCount(1),
        ),
      ],
    );
  }
}
