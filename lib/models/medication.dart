import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

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
    required this.notes,
    required this.photoUrl, 
    this.frequency = 'Daily', 
    this.isTaken = false,
  }) : id = uuid.v4();

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
  bool isTaken;

  String get formattedStartDate {
    return formatter.format(startDate);
  }

  String get formattedEndDate {
    return formatter.format(endDate);
  }

  String get formattedExpDate {
    return formatter.format(expirationDate);
  }
}