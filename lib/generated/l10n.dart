// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Settings`
  String get title {
    return Intl.message(
      'Settings',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Preferences`
  String get preferences {
    return Intl.message(
      'Preferences',
      name: 'preferences',
      desc: '',
      args: [],
    );
  }

  /// `Appearance`
  String get appearance {
    return Intl.message(
      'Appearance',
      name: 'appearance',
      desc: '',
      args: [],
    );
  }

  /// `Language`
  String get language {
    return Intl.message(
      'Language',
      name: 'language',
      desc: '',
      args: [],
    );
  }

  /// `Notification`
  String get notification {
    return Intl.message(
      'Notification',
      name: 'notification',
      desc: '',
      args: [],
    );
  }

  /// `Notification Settings`
  String get notificationSettings {
    return Intl.message(
      'Notification Settings',
      name: 'notificationSettings',
      desc: '',
      args: [],
    );
  }

  /// `Please make sure to open:\nSettings > Apps > Tadawa App > Notifications > Allow`
  String get notificationInstructions {
    return Intl.message(
      'Please make sure to open:\nSettings > Apps > Tadawa App > Notifications > Allow',
      name: 'notificationInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Logout`
  String get logout {
    return Intl.message(
      'Logout',
      name: 'logout',
      desc: '',
      args: [],
    );
  }

  /// `Tadawa`
  String get appName {
    return Intl.message(
      'Tadawa',
      name: 'appName',
      desc: '',
      args: [],
    );
  }

  /// `User Name`
  String get defaultUserName {
    return Intl.message(
      'User Name',
      name: 'defaultUserName',
      desc: '',
      args: [],
    );
  }

  /// `Email Address`
  String get defaultEmailAddress {
    return Intl.message(
      'Email Address',
      name: 'defaultEmailAddress',
      desc: '',
      args: [],
    );
  }

  /// `Manage notifications`
  String get manageNotifications {
    return Intl.message(
      'Manage notifications',
      name: 'manageNotifications',
      desc: '',
      args: [],
    );
  }

  /// `OK`
  String get ok {
    return Intl.message(
      'OK',
      name: 'ok',
      desc: '',
      args: [],
    );
  }

  /// `Light`
  String get light {
    return Intl.message(
      'Light',
      name: 'light',
      desc: '',
      args: [],
    );
  }

  /// `Dark`
  String get dark {
    return Intl.message(
      'Dark',
      name: 'dark',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get profile {
    return Intl.message(
      'Profile',
      name: 'profile',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `First Name`
  String get firstName {
    return Intl.message(
      'First Name',
      name: 'firstName',
      desc: '',
      args: [],
    );
  }

  /// `Last Name`
  String get lastName {
    return Intl.message(
      'Last Name',
      name: 'lastName',
      desc: '',
      args: [],
    );
  }

  /// `Phone`
  String get phone {
    return Intl.message(
      'Phone',
      name: 'phone',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get email {
    return Intl.message(
      'Email',
      name: 'email',
      desc: '',
      args: [],
    );
  }

  /// `Update Profile`
  String get updateProfile {
    return Intl.message(
      'Update Profile',
      name: 'updateProfile',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your username.`
  String get pleaseEnterUsername {
    return Intl.message(
      'Please enter your username.',
      name: 'pleaseEnterUsername',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your first name.`
  String get pleaseEnterFirstName {
    return Intl.message(
      'Please enter your first name.',
      name: 'pleaseEnterFirstName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your last name.`
  String get pleaseEnterLastName {
    return Intl.message(
      'Please enter your last name.',
      name: 'pleaseEnterLastName',
      desc: '',
      args: [],
    );
  }

  /// `Please enter your phone number.`
  String get pleaseEnterPhoneNumber {
    return Intl.message(
      'Please enter your phone number.',
      name: 'pleaseEnterPhoneNumber',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address.`
  String get pleaseEnterValidEmail {
    return Intl.message(
      'Please enter a valid email address.',
      name: 'pleaseEnterValidEmail',
      desc: '',
      args: [],
    );
  }

  /// `Profile updated successfully!`
  String get profileUpdated {
    return Intl.message(
      'Profile updated successfully!',
      name: 'profileUpdated',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching user data.`
  String get errorFetchingUserData {
    return Intl.message(
      'Error fetching user data.',
      name: 'errorFetchingUserData',
      desc: '',
      args: [],
    );
  }

  /// `Error updating profile.`
  String get errorUpdatingProfile {
    return Intl.message(
      'Error updating profile.',
      name: 'errorUpdatingProfile',
      desc: '',
      args: [],
    );
  }

  /// `Medications`
  String get medications {
    return Intl.message(
      'Medications',
      name: 'medications',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get startDate {
    return Intl.message(
      'Start Date',
      name: 'startDate',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get endDate {
    return Intl.message(
      'End Date',
      name: 'endDate',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get time {
    return Intl.message(
      'Time',
      name: 'time',
      desc: '',
      args: [],
    );
  }

  /// `Warning: Pills are running low!`
  String get warningPillsLow {
    return Intl.message(
      'Pills are running low!',
      name: 'warningPillsLow',
      desc: '',
      args: [],
    );
  }

  /// `Warning: This medication will expire soon!`
  String get warningExpirationSoon {
    return Intl.message(
      'This medication will expire soon!',
      name: 'warningExpirationSoon',
      desc: '',
      args: [],
    );
  }

  /// `Error fetching medications.`
  String get errorFetchingMedications {
    return Intl.message(
      'Error fetching medications.',
      name: 'errorFetchingMedications',
      desc: '',
      args: [],
    );
  }

  /// `{medicationName} has been deleted.`
  String medicationDeleted(Object medicationName) {
    return Intl.message(
      '$medicationName has been deleted.',
      name: 'medicationDeleted',
      desc: '',
      args: [medicationName],
    );
  }

  /// `Add Medication`
  String get addMedication {
    return Intl.message(
      'Add Medication',
      name: 'addMedication',
      desc: '',
      args: [],
    );
  }

  /// `Edit Medication`
  String get editMedication {
    return Intl.message(
      'Edit Medication',
      name: 'editMedication',
      desc: '',
      args: [],
    );
  }

  /// `Medication Name`
  String get medicationName {
    return Intl.message(
      'Medication Name',
      name: 'medicationName',
      desc: '',
      args: [],
    );
  }

  /// `Expiration Date`
  String get expirationDate {
    return Intl.message(
      'Expiration Date',
      name: 'expirationDate',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message(
      'Notes',
      name: 'notes',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get daily {
    return Intl.message(
      'Daily',
      name: 'daily',
      desc: '',
      args: [],
    );
  }

  /// `No pills for today`
  String get noPillsForToday {
    return Intl.message(
      'No Medications for today',
      name: 'noPillsForToday',
      desc: '',
      args: [],
    );
  }

  /// `Pill Schedule`
  String get pillsSchedule {
    return Intl.message(
      'Medications Schedule',
      name: 'pillsSchedule',
      desc: '',
      args: [],
    );
  }

  String get noMedicationsAdded {
    return Intl.message(
      'No medications added',
      name: 'noMedicationsAdded',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get weekly {
    return Intl.message(
      'Weekly',
      name: 'weekly',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get monthly {
    return Intl.message(
      'Monthly',
      name: 'monthly',
      desc: '',
      args: [],
    );
  }

  /// `Pills Count`
  String get pillsCount {
    return Intl.message(
      'Pills Count',
      name: 'pillsCount',
      desc: '',
      args: [],
    );
  }

  /// `Save Medication`
  String get saveMedication {
    return Intl.message(
      'Save Medication',
      name: 'saveMedication',
      desc: '',
      args: [],
    );
  }

  /// `Please fill in all fields.`
  String get pleaseFillAllFields {
    return Intl.message(
      'Please fill in all fields.',
      name: 'pleaseFillAllFields',
      desc: '',
      args: [],
    );
  }

  /// `Appointments`
  String get appointments {
    return Intl.message(
      'Appointments',
      name: 'appointments',
      desc: '',
      args: [],
    );
  }

  /// `Add Appointment`
  String get addAppointment {
    return Intl.message(
      'Add Appointment',
      name: 'addAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Edit Appointment`
  String get editAppointment {
    return Intl.message(
      'Edit Appointment',
      name: 'editAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Enter appointment`
  String get enterAppointment {
    return Intl.message(
      'Enter appointment',
      name: 'enterAppointment',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get add {
    return Intl.message(
      'Add',
      name: 'add',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `{appointmentName} deleted`
  String appointmentDeleted(Object appointmentName) {
    return Intl.message(
      '$appointmentName deleted',
      name: 'appointmentDeleted',
      desc: '',
      args: [appointmentName],
    );
  }

  /// `Doctor Visit`
  String get doctorVisit {
    return Intl.message(
      'Doctor Visit',
      name: 'doctorVisit',
      desc: '',
      args: [],
    );
  }

  /// `Meeting`
  String get meeting {
    return Intl.message(
      'Meeting',
      name: 'meeting',
      desc: '',
      args: [],
    );
  }

  /// `No Title`
  String get noTitle {
    return Intl.message(
      'No Title',
      name: 'noTitle',
      desc: '',
      args: [],
    );
  }

  /// `Painkiller`
  String get painkiller {
    return Intl.message(
      'Painkiller',
      name: 'painkiller',
      desc: '',
      args: [],
    );
  }

  /// `Antibiotic`
  String get antibiotic {
    return Intl.message(
      'Antibiotic',
      name: 'antibiotic',
      desc: '',
      args: [],
    );
  }

  /// `Vitamins`
  String get vitamins {
    return Intl.message(
      'Vitamins',
      name: 'vitamins',
      desc: '',
      args: [],
    );
  }

  /// `No Name`
  String get noName {
    return Intl.message(
      'No Name',
      name: 'noName',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
