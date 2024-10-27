import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const uuid = Uuid();
final formatter = DateFormat.yMd();

class Medication {
  Medication({
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.schedule,
    required this.expirationDate,
    required this.pillsCount,
    this.notes = '',
    this.photoUrl = '',
    required this.frequency,
    Map<DateTime, bool>? takenStatus,
    String? id, // Optional id parameter
  })  : id = id ?? uuid.v4(), // Generate a new ID if not provided
        takenStatus = takenStatus ?? {};

  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final TimeOfDay time;
  final String schedule;
  final DateTime expirationDate;
  final int pillsCount;
  final String notes;
  final String photoUrl;
  final String frequency;
  final Map<DateTime, bool> takenStatus;

  // Utility method to parse Firestore date values
  static DateTime parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    }
    throw Exception('Invalid date format');
  }

  factory Medication.fromFirestore(Map<String, dynamic> data, String id) {
    return Medication(
      id: id, // Pass the document ID
      name: data['name'] ?? '',
      startDate: parseDate(data['startDate']),
      endDate: parseDate(data['endDate']),
      expirationDate: parseDate(data['expirationDate']),
      notes: data['notes'] ?? '',
      pillsCount: data['pillsCount'] ?? 0,
      time: _parseTime(data['time']),
      frequency: data['frequency'] ?? '',
      schedule: data['schedule'] ?? '',
    );
  }

  // Parse time from Firestore
  static TimeOfDay _parseTime(dynamic timeData) {
    if (timeData is String) {
      // Sanitize and check the format
      String sanitizedTime = timeData
          .replaceAll(RegExp(r'[\u200B-\u200D\uFEFF]'), '') // Remove zero-width characters
          .replaceAll(RegExp(r'[^\d:APMapm ]'), '') // Remove unwanted characters
          .trim();

      // Log the sanitized time for debugging
      print('Sanitized time string: "$sanitizedTime"');

      if (sanitizedTime.isEmpty) {
        throw Exception('Sanitized time string is empty');
      }

      try {
        // Split the time into components
        final parts = sanitizedTime.split(' ');
        if (parts.length != 2) {
          throw Exception('Invalid time format: $sanitizedTime');
        }

        // Extract time and period (AM/PM)
        final timePart = parts[0];
        final periodPart = parts[1].toUpperCase();

        // Further split the time part into hours and minutes
        final timeComponents = timePart.split(':');
        if (timeComponents.length != 2) {
          throw Exception('Invalid time format: $sanitizedTime');
        }

        int hour = int.parse(timeComponents[0]);
        int minute = int.parse(timeComponents[1]);

        // Adjust hour for AM/PM
        if (periodPart == 'PM' && hour != 12) {
          hour += 12; // Convert to 24-hour format
        } else if (periodPart == 'AM' && hour == 12) {
          hour = 0; // Handle midnight
        }

        // Create a DateTime object
        final dateTime = DateTime(2021, 1, 1, hour, minute); // Use a dummy date
        return TimeOfDay.fromDateTime(dateTime);
      } catch (e) {
        print('Error parsing time: "$sanitizedTime" - $e');
        throw Exception('Invalid time format: $sanitizedTime');
      }
    }
    throw Exception('Time data is not a string: $timeData');
  }

  String get formattedStartDate => formatter.format(startDate);
  String get formattedEndDate => formatter.format(endDate);
  String get formattedExpDate => formatter.format(expirationDate);
}