import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Appointment {
  final String id;
  final String title;
  final TimeOfDay time;
  final DateTime date;

  Appointment({
    required this.id,
    required this.title,
    required this.time,
    required this.date,
  });

  factory Appointment.fromFirestore(Map<String, dynamic> data, String id) {
    // Validate and handle potential null values
    return Appointment(
      id: id,
      title: data['title'] ?? 'No Title', // Default value if title is null
      time: TimeOfDay(
        hour: data['timeHour'] ?? 0,   // Default to 0 hours if null
        minute: data['timeMinute'] ?? 0, // Default to 0 minutes if null
      ),
      date: (data['date'] as Timestamp).toDate(), // Ensure date is a Timestamp
    );
  }

  Map<String, dynamic> toMap(BuildContext context) {
    return {
      'title': title,
      'timeHour': time.hour,
      'timeMinute': time.minute,
      'date': Timestamp.fromDate(date),
    };
  }

  Appointment copyWith({String? title, TimeOfDay? time, DateTime? date}) {
    return Appointment(
      id: id,
      title: title ?? this.title,
      time: time ?? this.time,
      date: date ?? this.date,
    );
  }
}