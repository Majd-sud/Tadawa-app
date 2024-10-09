import 'package:flutter/material.dart';
import 'package:tadawa_app/models/medication.dart';
import 'package:intl/intl.dart';

class MainScreen extends StatefulWidget {
  final List<Medication> medications;

  const MainScreen({super.key, required this.medications});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late DateTime _today;
  late List<DateTime> _monthDates; // Stores a month's worth of dates
  late DateTime _selectedDate; // Stores the currently selected date
  late PageController _pageController;

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _today = DateTime.now(); // Initialize today’s date
    _monthDates = _generateMonthDates(_today); // Generate a month of dates
    _selectedDate = _today; // Set today as the default selected date
    _pageController = PageController(viewportFraction: 0.8);
  }

  // Generate a month's worth of dates centered around today
  List<DateTime> _generateMonthDates(DateTime date) {
    List<DateTime> monthDates = [];
    for (int i = 0; i < 30; i++) { // Change to 30 days for a month
      monthDates.add(date.add(Duration(days: i - 15))); // Center around today
    }
    return monthDates;
  }

  List<Medication> _getTodaysMedications(DateTime date) {
    return widget.medications.where((medication) {
      final reminderDates = _generateReminderDates(
        medication.startDate,
        medication.endDate,
        medication.frequency,
      );
      return reminderDates.contains(date);
    }).toList();
  }

  List<DateTime> _generateReminderDates(DateTime start, DateTime end, String frequency) {
    List<DateTime> reminderDates = [];
    DateTime currentDate = start;

    while (currentDate.isBefore(end) || currentDate.isAtSameMomentAs(end)) {
      reminderDates.add(currentDate);
      if (frequency == 'Daily') {
        currentDate = currentDate.add(Duration(days: 1));
      } else if (frequency == 'Weekly') {
        currentDate = currentDate.add(Duration(days: 7));
      } else if (frequency == 'Monthly') {
        currentDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);
      }
    }

    return reminderDates;
  }

  void _navigateToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medications Overview'),
      ),
      body: Column(
        children: [
          _buildDateNavigation(),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _getTodaysMedications(_selectedDate).length,
              itemBuilder: (context, index) {
                final medication = _getTodaysMedications(_selectedDate)[index];
                return ListTile(
                  title: Text(medication.name),
                  trailing: Checkbox(
                    value: medication.isTaken,
                    onChanged: (value) {
                      setState(() {
                        medication.isTaken = value ?? false; // Update medication taken status
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigation() {
    return SizedBox(
      height: 80, // Adjusted height for the date box area
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left),
            onPressed: () {
              if (_currentPage > 0) {
                _currentPage--;
                _navigateToPage(_currentPage);
                _updateSelectedDate(_currentPage);
              }
            },
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: (_monthDates.length / 4).ceil(), // Update to reflect month dates
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  _updateSelectedDate(index);
                });
              },
              itemBuilder: (context, index) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (i) {
                    final dateIndex = index * 4 + i;
                    if (dateIndex >= _monthDates.length) {
                      return SizedBox.shrink(); // Empty space for out-of-bounds
                    }
                    final date = _monthDates[dateIndex];
                    final isSelected = date.isSameDate(_selectedDate);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedDate = date; // Update the selected date
                        });
                      },
                      child: Container(
                        width: isSelected ? 70 : 50, // Adjusted width
                        margin: const EdgeInsets.symmetric(horizontal: 1), // Reduced margin
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blueAccent : Colors.white,
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                DateFormat.E().format(date),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSelected ? 16 : 12, // Adjusted font size
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                DateFormat.d().format(date),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isSelected ? 16 : 12, // Adjusted font size
                                  color: isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right),
            onPressed: () {
              if (_currentPage < (_monthDates.length / 4).ceil() - 1) {
                _currentPage++;
                _navigateToPage(_currentPage);
                _updateSelectedDate(_currentPage);
              }
            },
          ),
        ],
      ),
    );
  }

  void _updateSelectedDate(int page) {
    int index = page * 4 + 3; // Get the last date in the current view
    if (index < _monthDates.length) {
      setState(() {
        _selectedDate = _monthDates[index]; // Update selected date to the last date in the group
      });
    }
  }
}

// Extension for date comparisons
extension DateTimeComparison on DateTime {
  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }
}