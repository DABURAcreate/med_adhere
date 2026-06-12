// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get enterYourPin => 'Enter Your Pin:';

  @override
  String get enterRegistrationCode => 'Enter Registration Code';

  @override
  String get continueButton => 'Continue';

  @override
  String get navHome => 'HOME';

  @override
  String get navProgress => 'PROGRESS';

  @override
  String get navMeds => 'MEDS';

  @override
  String get navRiskLevel => 'RISK LEVEL';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get back => 'Back';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String get send => 'Send';

  @override
  String get logout => 'Logout';

  @override
  String get never => 'Never';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get taken => 'Taken';

  @override
  String get missed => 'Missed';

  @override
  String get pending => 'Pending';

  @override
  String get loading => 'Loading…';

  @override
  String get required => 'Required';

  @override
  String get medications => 'Medications';

  @override
  String get inactive => 'INACTIVE';

  @override
  String get active => 'Active';

  @override
  String get highRisk => 'High Risk';

  @override
  String get medRisk => 'Med Risk';

  @override
  String get lowRisk => 'Low Risk';

  @override
  String get pinMismatch => 'PINs do not match. Please try again.';

  @override
  String get pinTooShort => 'Please enter a 4-digit PIN.';

  @override
  String get fullNameLabel => 'Full Name *';

  @override
  String get fullNameRequired => 'Full name is required';

  @override
  String get noData => 'No data';

  @override
  String get noActiveMedications => 'No active medications found.';

  @override
  String get next => 'Next';

  @override
  String get loginNewPatient => 'New patient? Enter your activation code';

  @override
  String get loginWorkerRegister => 'Register as Healthcare Worker';

  @override
  String get createPin => 'Create PIN:';

  @override
  String get confirmPinLabel => 'Confirm PIN:';

  @override
  String get languageLabel => 'Language:';

  @override
  String get languageAlreadyRegistered => 'Already registered? Sign in';

  @override
  String get registerWorkerTitle => 'Register as Worker';

  @override
  String get staffDetails => 'Staff Details';

  @override
  String get staffNumberLabel => 'Staff Number *';

  @override
  String get clinicNameOptional => 'Clinic Name (optional)';

  @override
  String get setYourPin => 'Set Your PIN';

  @override
  String get pinSubtitle => 'Choose a 4-digit PIN you will use to log in.';

  @override
  String get pinLabel => 'PIN';

  @override
  String get confirmPinField => 'Confirm PIN';

  @override
  String get registerSignIn => 'Register & Sign In';

  @override
  String get staffNumberRequired => 'Staff number is required';

  @override
  String get noPatientSession =>
      'No patient session found. Please log in again.';

  @override
  String get todaysDoses => 'Today\'s Doses';

  @override
  String get patientNotFound => 'Patient not found. Please log in again.';

  @override
  String get todayProgress => 'Today progress:';

  @override
  String greetingHi(String name) {
    return 'Hi, $name 👋';
  }

  @override
  String get noPatientSessionShort => 'No patient session found.';

  @override
  String get noMedicationsAssigned => 'No medications assigned yet.';

  @override
  String dosageLabel(String dosage) {
    return 'Dosage: $dosage';
  }

  @override
  String get yourSchedule => 'Your Schedule:';

  @override
  String get noScheduledTimes => 'No scheduled times yet.';

  @override
  String get howToTake => 'How to Take:';

  @override
  String get riskLevel => 'Risk Level';

  @override
  String get noActiveSession => 'No active session.\nPlease log in first.';

  @override
  String riskScore(int score) {
    return 'Score: $score/100';
  }

  @override
  String get thirtyDayAdherence => '30-day adherence';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get missedLast7Days => 'Missed (last 7 days)';

  @override
  String get whyThisRating => 'Why this rating?';

  @override
  String get whatShouldIDo => 'What should I do?';

  @override
  String get recalculate => 'Recalculate';

  @override
  String lastCalculated(String time) {
    return 'Last calculated: $time';
  }

  @override
  String get myProgress => 'My Progress';

  @override
  String get legendPartial => 'Partial';

  @override
  String streakDays(int n) {
    return '$n-day streak';
  }

  @override
  String get noStreak => 'No Streak';

  @override
  String get noDosesLogged => 'No doses logged.';

  @override
  String doseLoggedAt(String time) {
    return 'Taken $time';
  }

  @override
  String doseMissedAt(String scheduledAt) {
    return 'Missed ($scheduledAt)';
  }

  @override
  String get thisMonth => 'This month';

  @override
  String monthlyDosesSummary(int taken, int scheduled) {
    return 'You took $taken of $scheduled scheduled doses.';
  }

  @override
  String get previousMonth => 'Previous Month';

  @override
  String greeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get syncing => 'Syncing…';

  @override
  String syncedAt(String time) {
    return 'Synced $time';
  }

  @override
  String get totalPatients => 'Total Patients';

  @override
  String get avgAdherence => 'Avg Adherence';

  @override
  String get actionRequired => 'Action Required';

  @override
  String get viewAll => 'View all';

  @override
  String get noHighRiskPatients => 'No high-risk patients — great work!';

  @override
  String lastSeen(String time) {
    return 'Last seen: $time';
  }

  @override
  String get adherence => 'adherence';

  @override
  String riskBadge(String score) {
    return 'Risk $score%';
  }

  @override
  String get clinicAdherenceTrend => 'Clinic Adherence Trend';

  @override
  String get thirtyDays => '30 days';

  @override
  String get clinicWideAdherence => 'Clinic-wide medication adherence %';

  @override
  String get loadingTrend => 'Loading trend…';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navPatients => 'Patients';

  @override
  String get navReports => 'Reports';

  @override
  String get navSettings => 'Settings';

  @override
  String get patientList => 'Patient List';

  @override
  String get searchByNameOrCode => 'Search by name or clinic code…';

  @override
  String get filterAll => 'All';

  @override
  String get sortBy => 'Sort by';

  @override
  String get sortRiskLevel => 'Risk Level';

  @override
  String get sortName => 'Name';

  @override
  String get sortLastActive => 'Last Active';

  @override
  String get adherence30d => 'adherence (30d)';

  @override
  String get noPatientsFound => 'No patients found';

  @override
  String get noPatientsFoundSubtitle =>
      'Try adjusting your search or filter, or register a new patient.';

  @override
  String get registerNewPatient => 'Register New Patient';

  @override
  String patientCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count patients',
      one: '1 patient',
    );
    return '$_temp0';
  }

  @override
  String get registerPatient => 'Register Patient';

  @override
  String get stepPatientInfo => 'Patient\nInfo';

  @override
  String get stepConfirm => 'Confirm';

  @override
  String get patientInformationTitle => 'Patient Information';

  @override
  String get patientInformationSubtitle =>
      'Enter the patient\'s basic details as recorded at the clinic.';

  @override
  String get clinicPatientCodeLabel => 'Clinic Patient Code *';

  @override
  String get codeAutoGenerated => 'Auto-generated — edit if needed';

  @override
  String get conditionsLabel => 'Condition(s) *';

  @override
  String get conditionsHint => 'Select all that apply';

  @override
  String get caregiverPhoneOptional => 'Caregiver Phone Number (optional)';

  @override
  String get patientCodeRequired => 'Patient code is required';

  @override
  String get secureStorageInfo =>
      'Full name and ID are stored securely on the backend only. The local device stores only the clinic patient code.';

  @override
  String get medicationsSubtitle =>
      'Add all medications the patient must take.';

  @override
  String medicationCard(int n) {
    return 'Medication $n';
  }

  @override
  String get medicationNameLabel => 'Medication Name *';

  @override
  String get dosageFieldLabel => 'Dosage *';

  @override
  String get timesPerDayField => 'Times per day *';

  @override
  String get medicationNameRequired => 'Medication name is required';

  @override
  String get dosageRequired => 'Dosage is required';

  @override
  String get addAnotherMedication => '+ Add Another Medication';

  @override
  String get remindersTitle => 'Set Reminder Times';

  @override
  String get remindersSubtitle =>
      'Set daily reminder times for each medication. These are set on behalf of the patient.';

  @override
  String timesDaily(int n) {
    return '$n× daily';
  }

  @override
  String doseLabel(int n) {
    return 'Dose $n';
  }

  @override
  String get remindersInfo =>
      'Reminder times are set by the worker on behalf of the patient. The patient can adjust these after activating their account.';

  @override
  String get confirmRegistrationTitle => 'Confirm Registration';

  @override
  String get confirmRegistrationSubtitle =>
      'Review all details before registering the patient.';

  @override
  String get summaryPatientInformation => 'Patient Information';

  @override
  String get summaryClinicCode => 'Clinic Code';

  @override
  String get summaryConditions => 'Conditions';

  @override
  String get summaryCaregiverPhone => 'Caregiver Phone';

  @override
  String get summaryFullName => 'Full Name';

  @override
  String get patientActivationCode => 'Patient Activation Code';

  @override
  String get activationCodeHint =>
      'Give this code to the patient to activate their account';

  @override
  String get copyCode => 'Copy Code';

  @override
  String get patientRegistered => 'Patient Registered!';

  @override
  String patientRegisteredSuccess(String name) {
    return '$name has been registered successfully.';
  }

  @override
  String get patientActivationCodeLabel => 'PATIENT ACTIVATION CODE';

  @override
  String get activationCodeShare =>
      'Share this 5-digit code with the patient.\nThey will use it to set their PIN and activate their account.';

  @override
  String get registerPatientButton => 'Register Patient';

  @override
  String get conditionRequired => 'Please select at least one condition.';

  @override
  String registrationFailed(String error) {
    return 'Registration failed: $error';
  }

  @override
  String get codeCopied => 'Code copied to clipboard';

  @override
  String get activationCodeCopied => 'Activation code copied';

  @override
  String get patientNotFoundError => 'Patient not found.';

  @override
  String couldNotLoadPatient(String error) {
    return 'Could not load patient data: $error';
  }

  @override
  String get adherenceSummary => 'Adherence Summary';

  @override
  String get thirtyDayAdherenceRate => '30-day adherence rate';

  @override
  String get missedDosesLabel => 'missed\ndoses';

  @override
  String get last14Days => 'Last 14 Days';

  @override
  String get workerBadge => 'WORKER';

  @override
  String get whyThisRiskLevel => 'Why this risk level?';

  @override
  String get actionsTitle => 'Actions';

  @override
  String get scheduleFollowUp => 'Schedule Follow-up';

  @override
  String get sendSmsReminder => 'Send SMS Reminder';

  @override
  String get editMedicationSchedule => 'Edit Medication Schedule';

  @override
  String get manageCaregiver => 'Manage Caregiver';

  @override
  String sendSmsDialogContent(String name) {
    return 'Send a medication reminder SMS to $name?';
  }

  @override
  String smsSent(String name) {
    return 'SMS sent to $name';
  }

  @override
  String get followUpLog => 'Follow-up Log';

  @override
  String get noFollowUpNotes => 'No follow-up notes yet.';

  @override
  String get noMedicationsScheduled => 'No medications scheduled.';

  @override
  String get medicationScheduleTitle => 'Medication Schedule';

  @override
  String get unsavedChanges => 'Unsaved Changes';

  @override
  String get leaveWithoutSaving =>
      'You have unsaved changes. Leave without saving?';

  @override
  String get keepEditing => 'Keep Editing';

  @override
  String get discard => 'Discard';

  @override
  String get futureDosesOnly =>
      'Changes apply to future doses only and will not affect logged history.';

  @override
  String medsCount(int count) {
    return '$count meds';
  }

  @override
  String get removeMedication => 'Remove Medication?';

  @override
  String removeMedicationContent(String name) {
    return 'Remove $name from this patient\'s schedule? Past logs will not be affected.';
  }

  @override
  String get saveChangesQuestion => 'Save Changes?';

  @override
  String get saveChangesContent =>
      'Changes will apply to future doses only. Past medication logs will not be affected.';

  @override
  String get scheduleSaved => 'Schedule saved successfully';

  @override
  String saveFailed(String error) {
    return 'Save failed: $error';
  }

  @override
  String get timesPerDay => 'Times per day';

  @override
  String get reminderTimesLabel => 'Reminder times';

  @override
  String get activeLabel => 'Active';

  @override
  String get inactiveLabel => 'Inactive';

  @override
  String get patientReceivesReminders =>
      'Patient receives reminders for this medication';

  @override
  String get noRemindersSent => 'No reminders sent — medication paused';

  @override
  String get addMedication => '+ Add Medication';

  @override
  String get noMedicationsYet => 'No medications yet';

  @override
  String get addFirstMedication =>
      'Tap below to add the first medication for this patient.';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get noChanges => 'No Changes';

  @override
  String get scheduleFollowUpTitle => 'Schedule Follow-up';

  @override
  String get followUpTypeLabel => 'Follow-up Type';

  @override
  String get dateTimeLabel => 'Date & Time';

  @override
  String get dateLabel => 'Date';

  @override
  String get timeLabel => 'Time';

  @override
  String get notesLabel => 'Notes';

  @override
  String get smsPreview => 'SMS Preview';

  @override
  String get editable => 'Editable';

  @override
  String toRecipient(String name) {
    return 'To: $name';
  }

  @override
  String charsCount(int count) {
    return '$count chars';
  }

  @override
  String get smsQueued =>
      'SMS will be queued and sent automatically when a network connection is available.';

  @override
  String get followUpSavedLocally =>
      'Follow-up saved locally. Will sync to backend and send SMS when online.';

  @override
  String get followUpScheduled => 'Follow-up Scheduled';

  @override
  String get savedLocally => 'Saved locally and will sync when online.';

  @override
  String get smsQueuedPill => 'SMS queued — will send when online';

  @override
  String get backToPatient => 'Back to Patient';

  @override
  String get scheduleFollowUpButton => 'Schedule Follow-up';

  @override
  String get followUpCall => 'Call';

  @override
  String get followUpVisit => 'Visit';

  @override
  String get followUpSms => 'SMS';

  @override
  String get notesHint =>
      'E.g. Patient reported difficulty remembering evening dose.';

  @override
  String get reminderSettingsTitle => 'Reminder Settings';

  @override
  String get noActiveMedicationsTitle => 'No active medications';

  @override
  String get noActiveMedicationsSubtitle =>
      'Your healthcare worker will assign medications to your account. They will appear here once added.';

  @override
  String remindersOn(int active, int total) {
    return '$active of $total reminder(s) on';
  }

  @override
  String get addReminderTime => 'Add reminder time';

  @override
  String get reminderFrequencyNote =>
      'Your healthcare worker may adjust your reminder frequency based on your adherence.';

  @override
  String get remindersSaved => 'Reminders saved';

  @override
  String get removeReminderTooltip => 'Remove reminder';

  @override
  String get reports => 'Reports';

  @override
  String get reportType => 'Report Type';

  @override
  String get perPatient => 'Per Patient';

  @override
  String get perClinic => 'Per Clinic';

  @override
  String get perPatientSubtitle => 'Individual adherence\nby date range';

  @override
  String get perClinicSubtitle => 'All patients overview\nby date range';

  @override
  String get selected => 'Selected';

  @override
  String get tapToSelect => 'Tap to select';

  @override
  String get patientLabel => 'Patient';

  @override
  String get noPatientsFoundHint => 'No patients found';

  @override
  String get selectPatient => 'Select a patient…';

  @override
  String get clinicLabel => 'Clinic';

  @override
  String get autoLabel => 'Auto';

  @override
  String get dateRange => 'Date Range';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get exportFormat => 'Export Format';

  @override
  String get previewReportData => 'Preview Report Data';

  @override
  String get previewLabel => 'Preview';

  @override
  String rowsCount(int count) {
    return '$count rows';
  }

  @override
  String get statAvg => 'Avg';

  @override
  String get columnDate => 'Date';

  @override
  String get columnMedication => 'Medication';

  @override
  String get columnPatient => 'Patient';

  @override
  String get columnAdherence => 'Adh. %';

  @override
  String get previewNote =>
      'Preview shows data from local storage. Sync for the latest cloud data.';

  @override
  String get noDataForRange => 'No data for this range';

  @override
  String get noDataSubtitle =>
      'No adherence records were found for the selected\npatient and date range. Try widening your selection.';

  @override
  String get exportPDF => 'Export PDF Report';

  @override
  String get exportCSV => 'Export CSV Report';

  @override
  String get previewAndExport => 'Preview & Export';

  @override
  String get pleaseSelectPatient => 'Please select a patient first.';

  @override
  String errorLoadingReport(String error) {
    return 'Error loading report: $error';
  }

  @override
  String get caregiverTitle => 'Caregiver';

  @override
  String get whatIsCaregiver => 'What is a caregiver?';

  @override
  String get caregiverDescription =>
      'A caregiver will receive an alert when you miss a dose. They will not see your medication details or diagnosis.';

  @override
  String get missedDoseAlert => 'Missed dose alert';

  @override
  String get noMedicationNames => 'No medication names';

  @override
  String get noDiagnosis => 'No diagnosis';

  @override
  String get caregiverLinkedTitle => 'Caregiver Linked';

  @override
  String get activeStatus => 'Active';

  @override
  String get phoneLabel => 'Phone';

  @override
  String get relationshipLabel => 'Relationship';

  @override
  String get alertTypeLabel => 'Alert type';

  @override
  String get dosesMissedOnly => 'Dose-missed only';

  @override
  String get privacyNote =>
      'Your medication details and diagnosis remain private. Your caregiver only knows when a dose is missed.';

  @override
  String get removeCaregiverButton => 'Remove Caregiver';

  @override
  String get caregiverPhoneField => 'Caregiver Phone Number *';

  @override
  String get caregiverPhoneHint =>
      'Enter the caregiver\'s South African mobile number.';

  @override
  String get relationshipField => 'Relationship *';

  @override
  String get selectRelationship => 'Select relationship…';

  @override
  String get consentText =>
      'I confirm the caregiver has agreed to receive dose-missed alerts for this patient. They will not be sent any medication or diagnosis details.';

  @override
  String get linkCaregiver => 'Link Caregiver';

  @override
  String get linking => 'Linking…';

  @override
  String get removeCaregiverDialog => 'Remove Caregiver?';

  @override
  String get removeCaregiverContent =>
      'Removing your caregiver means they will no longer receive dose-missed alerts. You can re-link at any time.';

  @override
  String get phoneRequired => 'Phone number is required';

  @override
  String get phoneInvalid => 'Enter a valid phone number';

  @override
  String get caregiverConsentRequired =>
      'Please confirm the caregiver has agreed.';

  @override
  String get selectRelationshipRequired => 'Please select a relationship';

  @override
  String get caregiverSaveFailed => 'Failed to save. Please try again.';

  @override
  String get caregiverRemoved => 'Caregiver removed.';

  @override
  String get caregiverLinkedSuccess => 'Caregiver Linked!';

  @override
  String get caregiverLinkedSubtitle =>
      'They will receive a dose-missed alert only.\nNo medication or diagnosis details will be shared.';

  @override
  String get privacyProtected => 'Dose-missed alerts only — privacy protected';

  @override
  String get navWorkerHome => 'HOME';

  @override
  String get navWorkerPatients => 'PATIENTS';

  @override
  String get navWorkerReports => 'REPORTS';

  @override
  String get navWorkerRegister => 'REGISTER';

  @override
  String get scheduledLabel => 'Scheduled: ';

  @override
  String get loggedAtLabel => 'Logged at: ';

  @override
  String get takenButton => 'TAKEN';

  @override
  String get missedButton => 'MISSED';

  @override
  String get statusOverdue => 'Overdue';

  @override
  String get logoutTooltip => 'Logout';
}
