// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'en';

  static String m0(appointmentName) => "${appointmentName} deleted";

  static String m1(medicationName) => "${medicationName} has been deleted.";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "add": MessageLookupByLibrary.simpleMessage("Add"),
        "addAppointment":
            MessageLookupByLibrary.simpleMessage("Add Appointment"),
        "addMedication": MessageLookupByLibrary.simpleMessage("Add Medication"),
        "antibiotic": MessageLookupByLibrary.simpleMessage("Antibiotic"),
        "appName": MessageLookupByLibrary.simpleMessage("Tadawa"),
        "appearance": MessageLookupByLibrary.simpleMessage("Appearance"),
        "appointmentDeleted": m0,
        "appointments": MessageLookupByLibrary.simpleMessage("Appointments"),
        "cancel": MessageLookupByLibrary.simpleMessage("Cancel"),
        "daily": MessageLookupByLibrary.simpleMessage("Daily"),
        "dark": MessageLookupByLibrary.simpleMessage("Dark"),
        "defaultEmailAddress":
            MessageLookupByLibrary.simpleMessage("Email Address"),
        "defaultUserName": MessageLookupByLibrary.simpleMessage("User Name"),
        "doctorVisit": MessageLookupByLibrary.simpleMessage("Doctor Visit"),
        "editAppointment":
            MessageLookupByLibrary.simpleMessage("Edit Appointment"),
        "editMedication":
            MessageLookupByLibrary.simpleMessage("Edit Medication"),
        "email": MessageLookupByLibrary.simpleMessage("Email"),
        "endDate": MessageLookupByLibrary.simpleMessage("End Date"),
        "enterAppointment":
            MessageLookupByLibrary.simpleMessage("Enter appointment"),
        "errorFetchingMedications":
            MessageLookupByLibrary.simpleMessage("Error fetching medications."),
        "errorFetchingUserData":
            MessageLookupByLibrary.simpleMessage("Error fetching user data."),
        "errorUpdatingProfile":
            MessageLookupByLibrary.simpleMessage("Error updating profile."),
        "expirationDate":
            MessageLookupByLibrary.simpleMessage("Expiration Date"),
        "firstName": MessageLookupByLibrary.simpleMessage("First Name"),
        "language": MessageLookupByLibrary.simpleMessage("Language"),
        "lastName": MessageLookupByLibrary.simpleMessage("Last Name"),
        "light": MessageLookupByLibrary.simpleMessage("Light"),
        "logout": MessageLookupByLibrary.simpleMessage("Logout"),
        "manageNotifications":
            MessageLookupByLibrary.simpleMessage("Manage notifications"),
        "medicationDeleted": m1,
        "medicationName":
            MessageLookupByLibrary.simpleMessage("Medication Name"),
        "noPillsForToday":
            MessageLookupByLibrary.simpleMessage("No pills for today"),
        "medications": MessageLookupByLibrary.simpleMessage("Medications"),
        "meeting": MessageLookupByLibrary.simpleMessage("Meeting"),
        "monthly": MessageLookupByLibrary.simpleMessage("Monthly"),
        "noName": MessageLookupByLibrary.simpleMessage("No Name"),
        "noTitle": MessageLookupByLibrary.simpleMessage("No Title"),
        "notes": MessageLookupByLibrary.simpleMessage("Notes"),
        "notification": MessageLookupByLibrary.simpleMessage("Notification"),
        "notificationInstructions": MessageLookupByLibrary.simpleMessage(
            "Please make sure to open:\nSettings > Apps > Tadawa App > Notifications > Allow"),
        "pillsSchedule": MessageLookupByLibrary.simpleMessage("Pill Schedule"),
        "noMedicationsAdded":
            MessageLookupByLibrary.simpleMessage("no medications added"),
        "notificationSettings":
            MessageLookupByLibrary.simpleMessage("Notification Settings"),
        "ok": MessageLookupByLibrary.simpleMessage("OK"),
        "painkiller": MessageLookupByLibrary.simpleMessage("Painkiller"),
        "phone": MessageLookupByLibrary.simpleMessage("Phone"),
        "pillsCount": MessageLookupByLibrary.simpleMessage("Pills Count"),
        "pleaseEnterFirstName": MessageLookupByLibrary.simpleMessage(
            "Please enter your first name."),
        "pleaseEnterLastName": MessageLookupByLibrary.simpleMessage(
            "Please enter your last name."),
        "pleaseEnterPhoneNumber": MessageLookupByLibrary.simpleMessage(
            "Please enter your phone number."),
        "pleaseEnterUsername":
            MessageLookupByLibrary.simpleMessage("Please enter your username."),
        "pleaseEnterValidEmail": MessageLookupByLibrary.simpleMessage(
            "Please enter a valid email address."),
        "pleaseFillAllFields":
            MessageLookupByLibrary.simpleMessage("Please fill in all fields."),
        "preferences": MessageLookupByLibrary.simpleMessage("Preferences"),
        "profile": MessageLookupByLibrary.simpleMessage("Profile"),
        "profileUpdated": MessageLookupByLibrary.simpleMessage(
            "Profile updated successfully!"),
        "saveMedication":
            MessageLookupByLibrary.simpleMessage("Save Medication"),
        "startDate": MessageLookupByLibrary.simpleMessage("Start Date"),
        "time": MessageLookupByLibrary.simpleMessage("Time"),
        "title": MessageLookupByLibrary.simpleMessage("Settings"),
        "update": MessageLookupByLibrary.simpleMessage("Update"),
        "updateProfile": MessageLookupByLibrary.simpleMessage("Update Profile"),
        "username": MessageLookupByLibrary.simpleMessage("Username"),
        "vitamins": MessageLookupByLibrary.simpleMessage("Vitamins"),
        "warningExpirationSoon": MessageLookupByLibrary.simpleMessage(
            "This medication will expire soon!"),
        "warningPillsLow":
            MessageLookupByLibrary.simpleMessage("Pills are running low!"),
        "weekly": MessageLookupByLibrary.simpleMessage("Weekly")
      };
}
