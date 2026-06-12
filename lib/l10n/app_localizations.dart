import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zu'),
  ];

  /// No description provided for @enterYourPin.
  ///
  /// In en, this message translates to:
  /// **'Enter Your Pin:'**
  String get enterYourPin;

  /// No description provided for @enterRegistrationCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Registration Code'**
  String get enterRegistrationCode;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get navHome;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS'**
  String get navProgress;

  /// No description provided for @navMeds.
  ///
  /// In en, this message translates to:
  /// **'MEDS'**
  String get navMeds;

  /// No description provided for @navRiskLevel.
  ///
  /// In en, this message translates to:
  /// **'RISK LEVEL'**
  String get navRiskLevel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @never.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get never;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String daysAgo(int count);

  /// No description provided for @taken.
  ///
  /// In en, this message translates to:
  /// **'Taken'**
  String get taken;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @medications.
  ///
  /// In en, this message translates to:
  /// **'Medications'**
  String get medications;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'INACTIVE'**
  String get inactive;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @highRisk.
  ///
  /// In en, this message translates to:
  /// **'High Risk'**
  String get highRisk;

  /// No description provided for @medRisk.
  ///
  /// In en, this message translates to:
  /// **'Med Risk'**
  String get medRisk;

  /// No description provided for @lowRisk.
  ///
  /// In en, this message translates to:
  /// **'Low Risk'**
  String get lowRisk;

  /// No description provided for @pinMismatch.
  ///
  /// In en, this message translates to:
  /// **'PINs do not match. Please try again.'**
  String get pinMismatch;

  /// No description provided for @pinTooShort.
  ///
  /// In en, this message translates to:
  /// **'Please enter a 4-digit PIN.'**
  String get pinTooShort;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full Name *'**
  String get fullNameLabel;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Full name is required'**
  String get fullNameRequired;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noActiveMedications.
  ///
  /// In en, this message translates to:
  /// **'No active medications found.'**
  String get noActiveMedications;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @loginNewPatient.
  ///
  /// In en, this message translates to:
  /// **'New patient? Enter your activation code'**
  String get loginNewPatient;

  /// No description provided for @loginWorkerRegister.
  ///
  /// In en, this message translates to:
  /// **'Register as Healthcare Worker'**
  String get loginWorkerRegister;

  /// No description provided for @createPin.
  ///
  /// In en, this message translates to:
  /// **'Create PIN:'**
  String get createPin;

  /// No description provided for @confirmPinLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN:'**
  String get confirmPinLabel;

  /// No description provided for @languageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language:'**
  String get languageLabel;

  /// No description provided for @languageAlreadyRegistered.
  ///
  /// In en, this message translates to:
  /// **'Already registered? Sign in'**
  String get languageAlreadyRegistered;

  /// No description provided for @registerWorkerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register as Worker'**
  String get registerWorkerTitle;

  /// No description provided for @staffDetails.
  ///
  /// In en, this message translates to:
  /// **'Staff Details'**
  String get staffDetails;

  /// No description provided for @staffNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Staff Number *'**
  String get staffNumberLabel;

  /// No description provided for @clinicNameOptional.
  ///
  /// In en, this message translates to:
  /// **'Clinic Name (optional)'**
  String get clinicNameOptional;

  /// No description provided for @setYourPin.
  ///
  /// In en, this message translates to:
  /// **'Set Your PIN'**
  String get setYourPin;

  /// No description provided for @pinSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a 4-digit PIN you will use to log in.'**
  String get pinSubtitle;

  /// No description provided for @pinLabel.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pinLabel;

  /// No description provided for @confirmPinField.
  ///
  /// In en, this message translates to:
  /// **'Confirm PIN'**
  String get confirmPinField;

  /// No description provided for @registerSignIn.
  ///
  /// In en, this message translates to:
  /// **'Register & Sign In'**
  String get registerSignIn;

  /// No description provided for @staffNumberRequired.
  ///
  /// In en, this message translates to:
  /// **'Staff number is required'**
  String get staffNumberRequired;

  /// No description provided for @noPatientSession.
  ///
  /// In en, this message translates to:
  /// **'No patient session found. Please log in again.'**
  String get noPatientSession;

  /// No description provided for @todaysDoses.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Doses'**
  String get todaysDoses;

  /// No description provided for @patientNotFound.
  ///
  /// In en, this message translates to:
  /// **'Patient not found. Please log in again.'**
  String get patientNotFound;

  /// No description provided for @todayProgress.
  ///
  /// In en, this message translates to:
  /// **'Today progress:'**
  String get todayProgress;

  /// No description provided for @greetingHi.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name} 👋'**
  String greetingHi(String name);

  /// No description provided for @noPatientSessionShort.
  ///
  /// In en, this message translates to:
  /// **'No patient session found.'**
  String get noPatientSessionShort;

  /// No description provided for @noMedicationsAssigned.
  ///
  /// In en, this message translates to:
  /// **'No medications assigned yet.'**
  String get noMedicationsAssigned;

  /// No description provided for @dosageLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage: {dosage}'**
  String dosageLabel(String dosage);

  /// No description provided for @yourSchedule.
  ///
  /// In en, this message translates to:
  /// **'Your Schedule:'**
  String get yourSchedule;

  /// No description provided for @noScheduledTimes.
  ///
  /// In en, this message translates to:
  /// **'No scheduled times yet.'**
  String get noScheduledTimes;

  /// No description provided for @howToTake.
  ///
  /// In en, this message translates to:
  /// **'How to Take:'**
  String get howToTake;

  /// No description provided for @riskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get riskLevel;

  /// No description provided for @noActiveSession.
  ///
  /// In en, this message translates to:
  /// **'No active session.\nPlease log in first.'**
  String get noActiveSession;

  /// No description provided for @riskScore.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}/100'**
  String riskScore(int score);

  /// No description provided for @thirtyDayAdherence.
  ///
  /// In en, this message translates to:
  /// **'30-day adherence'**
  String get thirtyDayAdherence;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @missedLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Missed (last 7 days)'**
  String get missedLast7Days;

  /// No description provided for @whyThisRating.
  ///
  /// In en, this message translates to:
  /// **'Why this rating?'**
  String get whyThisRating;

  /// No description provided for @whatShouldIDo.
  ///
  /// In en, this message translates to:
  /// **'What should I do?'**
  String get whatShouldIDo;

  /// No description provided for @recalculate.
  ///
  /// In en, this message translates to:
  /// **'Recalculate'**
  String get recalculate;

  /// No description provided for @lastCalculated.
  ///
  /// In en, this message translates to:
  /// **'Last calculated: {time}'**
  String lastCalculated(String time);

  /// No description provided for @myProgress.
  ///
  /// In en, this message translates to:
  /// **'My Progress'**
  String get myProgress;

  /// No description provided for @legendPartial.
  ///
  /// In en, this message translates to:
  /// **'Partial'**
  String get legendPartial;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{n}-day streak'**
  String streakDays(int n);

  /// No description provided for @noStreak.
  ///
  /// In en, this message translates to:
  /// **'No Streak'**
  String get noStreak;

  /// No description provided for @noDosesLogged.
  ///
  /// In en, this message translates to:
  /// **'No doses logged.'**
  String get noDosesLogged;

  /// No description provided for @doseLoggedAt.
  ///
  /// In en, this message translates to:
  /// **'Taken {time}'**
  String doseLoggedAt(String time);

  /// No description provided for @doseMissedAt.
  ///
  /// In en, this message translates to:
  /// **'Missed ({scheduledAt})'**
  String doseMissedAt(String scheduledAt);

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @monthlyDosesSummary.
  ///
  /// In en, this message translates to:
  /// **'You took {taken} of {scheduled} scheduled doses.'**
  String monthlyDosesSummary(int taken, int scheduled);

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get previousMonth;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi, {name}'**
  String greeting(String name);

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncing;

  /// No description provided for @syncedAt.
  ///
  /// In en, this message translates to:
  /// **'Synced {time}'**
  String syncedAt(String time);

  /// No description provided for @totalPatients.
  ///
  /// In en, this message translates to:
  /// **'Total Patients'**
  String get totalPatients;

  /// No description provided for @avgAdherence.
  ///
  /// In en, this message translates to:
  /// **'Avg Adherence'**
  String get avgAdherence;

  /// No description provided for @actionRequired.
  ///
  /// In en, this message translates to:
  /// **'Action Required'**
  String get actionRequired;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get viewAll;

  /// No description provided for @noHighRiskPatients.
  ///
  /// In en, this message translates to:
  /// **'No high-risk patients — great work!'**
  String get noHighRiskPatients;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen: {time}'**
  String lastSeen(String time);

  /// No description provided for @adherence.
  ///
  /// In en, this message translates to:
  /// **'adherence'**
  String get adherence;

  /// No description provided for @riskBadge.
  ///
  /// In en, this message translates to:
  /// **'Risk {score}%'**
  String riskBadge(String score);

  /// No description provided for @clinicAdherenceTrend.
  ///
  /// In en, this message translates to:
  /// **'Clinic Adherence Trend'**
  String get clinicAdherenceTrend;

  /// No description provided for @thirtyDays.
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get thirtyDays;

  /// No description provided for @clinicWideAdherence.
  ///
  /// In en, this message translates to:
  /// **'Clinic-wide medication adherence %'**
  String get clinicWideAdherence;

  /// No description provided for @loadingTrend.
  ///
  /// In en, this message translates to:
  /// **'Loading trend…'**
  String get loadingTrend;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navPatients.
  ///
  /// In en, this message translates to:
  /// **'Patients'**
  String get navPatients;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @patientList.
  ///
  /// In en, this message translates to:
  /// **'Patient List'**
  String get patientList;

  /// No description provided for @searchByNameOrCode.
  ///
  /// In en, this message translates to:
  /// **'Search by name or clinic code…'**
  String get searchByNameOrCode;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @sortBy.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get sortBy;

  /// No description provided for @sortRiskLevel.
  ///
  /// In en, this message translates to:
  /// **'Risk Level'**
  String get sortRiskLevel;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortLastActive.
  ///
  /// In en, this message translates to:
  /// **'Last Active'**
  String get sortLastActive;

  /// No description provided for @adherence30d.
  ///
  /// In en, this message translates to:
  /// **'adherence (30d)'**
  String get adherence30d;

  /// No description provided for @noPatientsFound.
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatientsFound;

  /// No description provided for @noPatientsFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filter, or register a new patient.'**
  String get noPatientsFoundSubtitle;

  /// No description provided for @registerNewPatient.
  ///
  /// In en, this message translates to:
  /// **'Register New Patient'**
  String get registerNewPatient;

  /// No description provided for @patientCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 patient} other{{count} patients}}'**
  String patientCount(num count);

  /// No description provided for @registerPatient.
  ///
  /// In en, this message translates to:
  /// **'Register Patient'**
  String get registerPatient;

  /// No description provided for @stepPatientInfo.
  ///
  /// In en, this message translates to:
  /// **'Patient\nInfo'**
  String get stepPatientInfo;

  /// No description provided for @stepConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get stepConfirm;

  /// No description provided for @patientInformationTitle.
  ///
  /// In en, this message translates to:
  /// **'Patient Information'**
  String get patientInformationTitle;

  /// No description provided for @patientInformationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the patient\'s basic details as recorded at the clinic.'**
  String get patientInformationSubtitle;

  /// No description provided for @clinicPatientCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic Patient Code *'**
  String get clinicPatientCodeLabel;

  /// No description provided for @codeAutoGenerated.
  ///
  /// In en, this message translates to:
  /// **'Auto-generated — edit if needed'**
  String get codeAutoGenerated;

  /// No description provided for @conditionsLabel.
  ///
  /// In en, this message translates to:
  /// **'Condition(s) *'**
  String get conditionsLabel;

  /// No description provided for @conditionsHint.
  ///
  /// In en, this message translates to:
  /// **'Select all that apply'**
  String get conditionsHint;

  /// No description provided for @caregiverPhoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Phone Number (optional)'**
  String get caregiverPhoneOptional;

  /// No description provided for @patientCodeRequired.
  ///
  /// In en, this message translates to:
  /// **'Patient code is required'**
  String get patientCodeRequired;

  /// No description provided for @secureStorageInfo.
  ///
  /// In en, this message translates to:
  /// **'Full name and ID are stored securely on the backend only. The local device stores only the clinic patient code.'**
  String get secureStorageInfo;

  /// No description provided for @medicationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Add all medications the patient must take.'**
  String get medicationsSubtitle;

  /// No description provided for @medicationCard.
  ///
  /// In en, this message translates to:
  /// **'Medication {n}'**
  String medicationCard(int n);

  /// No description provided for @medicationNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Medication Name *'**
  String get medicationNameLabel;

  /// No description provided for @dosageFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Dosage *'**
  String get dosageFieldLabel;

  /// No description provided for @timesPerDayField.
  ///
  /// In en, this message translates to:
  /// **'Times per day *'**
  String get timesPerDayField;

  /// No description provided for @medicationNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Medication name is required'**
  String get medicationNameRequired;

  /// No description provided for @dosageRequired.
  ///
  /// In en, this message translates to:
  /// **'Dosage is required'**
  String get dosageRequired;

  /// No description provided for @addAnotherMedication.
  ///
  /// In en, this message translates to:
  /// **'+ Add Another Medication'**
  String get addAnotherMedication;

  /// No description provided for @remindersTitle.
  ///
  /// In en, this message translates to:
  /// **'Set Reminder Times'**
  String get remindersTitle;

  /// No description provided for @remindersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Set daily reminder times for each medication. These are set on behalf of the patient.'**
  String get remindersSubtitle;

  /// No description provided for @timesDaily.
  ///
  /// In en, this message translates to:
  /// **'{n}× daily'**
  String timesDaily(int n);

  /// No description provided for @doseLabel.
  ///
  /// In en, this message translates to:
  /// **'Dose {n}'**
  String doseLabel(int n);

  /// No description provided for @remindersInfo.
  ///
  /// In en, this message translates to:
  /// **'Reminder times are set by the worker on behalf of the patient. The patient can adjust these after activating their account.'**
  String get remindersInfo;

  /// No description provided for @confirmRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm Registration'**
  String get confirmRegistrationTitle;

  /// No description provided for @confirmRegistrationSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review all details before registering the patient.'**
  String get confirmRegistrationSubtitle;

  /// No description provided for @summaryPatientInformation.
  ///
  /// In en, this message translates to:
  /// **'Patient Information'**
  String get summaryPatientInformation;

  /// No description provided for @summaryClinicCode.
  ///
  /// In en, this message translates to:
  /// **'Clinic Code'**
  String get summaryClinicCode;

  /// No description provided for @summaryConditions.
  ///
  /// In en, this message translates to:
  /// **'Conditions'**
  String get summaryConditions;

  /// No description provided for @summaryCaregiverPhone.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Phone'**
  String get summaryCaregiverPhone;

  /// No description provided for @summaryFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get summaryFullName;

  /// No description provided for @patientActivationCode.
  ///
  /// In en, this message translates to:
  /// **'Patient Activation Code'**
  String get patientActivationCode;

  /// No description provided for @activationCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Give this code to the patient to activate their account'**
  String get activationCodeHint;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy Code'**
  String get copyCode;

  /// No description provided for @patientRegistered.
  ///
  /// In en, this message translates to:
  /// **'Patient Registered!'**
  String get patientRegistered;

  /// No description provided for @patientRegisteredSuccess.
  ///
  /// In en, this message translates to:
  /// **'{name} has been registered successfully.'**
  String patientRegisteredSuccess(String name);

  /// No description provided for @patientActivationCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'PATIENT ACTIVATION CODE'**
  String get patientActivationCodeLabel;

  /// No description provided for @activationCodeShare.
  ///
  /// In en, this message translates to:
  /// **'Share this 5-digit code with the patient.\nThey will use it to set their PIN and activate their account.'**
  String get activationCodeShare;

  /// No description provided for @registerPatientButton.
  ///
  /// In en, this message translates to:
  /// **'Register Patient'**
  String get registerPatientButton;

  /// No description provided for @conditionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one condition.'**
  String get conditionRequired;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed: {error}'**
  String registrationFailed(String error);

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied to clipboard'**
  String get codeCopied;

  /// No description provided for @activationCodeCopied.
  ///
  /// In en, this message translates to:
  /// **'Activation code copied'**
  String get activationCodeCopied;

  /// No description provided for @patientNotFoundError.
  ///
  /// In en, this message translates to:
  /// **'Patient not found.'**
  String get patientNotFoundError;

  /// No description provided for @couldNotLoadPatient.
  ///
  /// In en, this message translates to:
  /// **'Could not load patient data: {error}'**
  String couldNotLoadPatient(String error);

  /// No description provided for @adherenceSummary.
  ///
  /// In en, this message translates to:
  /// **'Adherence Summary'**
  String get adherenceSummary;

  /// No description provided for @thirtyDayAdherenceRate.
  ///
  /// In en, this message translates to:
  /// **'30-day adherence rate'**
  String get thirtyDayAdherenceRate;

  /// No description provided for @missedDosesLabel.
  ///
  /// In en, this message translates to:
  /// **'missed\ndoses'**
  String get missedDosesLabel;

  /// No description provided for @last14Days.
  ///
  /// In en, this message translates to:
  /// **'Last 14 Days'**
  String get last14Days;

  /// No description provided for @workerBadge.
  ///
  /// In en, this message translates to:
  /// **'WORKER'**
  String get workerBadge;

  /// No description provided for @whyThisRiskLevel.
  ///
  /// In en, this message translates to:
  /// **'Why this risk level?'**
  String get whyThisRiskLevel;

  /// No description provided for @actionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actionsTitle;

  /// No description provided for @scheduleFollowUp.
  ///
  /// In en, this message translates to:
  /// **'Schedule Follow-up'**
  String get scheduleFollowUp;

  /// No description provided for @sendSmsReminder.
  ///
  /// In en, this message translates to:
  /// **'Send SMS Reminder'**
  String get sendSmsReminder;

  /// No description provided for @editMedicationSchedule.
  ///
  /// In en, this message translates to:
  /// **'Edit Medication Schedule'**
  String get editMedicationSchedule;

  /// No description provided for @manageCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Manage Caregiver'**
  String get manageCaregiver;

  /// No description provided for @sendSmsDialogContent.
  ///
  /// In en, this message translates to:
  /// **'Send a medication reminder SMS to {name}?'**
  String sendSmsDialogContent(String name);

  /// No description provided for @smsSent.
  ///
  /// In en, this message translates to:
  /// **'SMS sent to {name}'**
  String smsSent(String name);

  /// No description provided for @followUpLog.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Log'**
  String get followUpLog;

  /// No description provided for @noFollowUpNotes.
  ///
  /// In en, this message translates to:
  /// **'No follow-up notes yet.'**
  String get noFollowUpNotes;

  /// No description provided for @noMedicationsScheduled.
  ///
  /// In en, this message translates to:
  /// **'No medications scheduled.'**
  String get noMedicationsScheduled;

  /// No description provided for @medicationScheduleTitle.
  ///
  /// In en, this message translates to:
  /// **'Medication Schedule'**
  String get medicationScheduleTitle;

  /// No description provided for @unsavedChanges.
  ///
  /// In en, this message translates to:
  /// **'Unsaved Changes'**
  String get unsavedChanges;

  /// No description provided for @leaveWithoutSaving.
  ///
  /// In en, this message translates to:
  /// **'You have unsaved changes. Leave without saving?'**
  String get leaveWithoutSaving;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keepEditing;

  /// No description provided for @discard.
  ///
  /// In en, this message translates to:
  /// **'Discard'**
  String get discard;

  /// No description provided for @futureDosesOnly.
  ///
  /// In en, this message translates to:
  /// **'Changes apply to future doses only and will not affect logged history.'**
  String get futureDosesOnly;

  /// No description provided for @medsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} meds'**
  String medsCount(int count);

  /// No description provided for @removeMedication.
  ///
  /// In en, this message translates to:
  /// **'Remove Medication?'**
  String get removeMedication;

  /// No description provided for @removeMedicationContent.
  ///
  /// In en, this message translates to:
  /// **'Remove {name} from this patient\'s schedule? Past logs will not be affected.'**
  String removeMedicationContent(String name);

  /// No description provided for @saveChangesQuestion.
  ///
  /// In en, this message translates to:
  /// **'Save Changes?'**
  String get saveChangesQuestion;

  /// No description provided for @saveChangesContent.
  ///
  /// In en, this message translates to:
  /// **'Changes will apply to future doses only. Past medication logs will not be affected.'**
  String get saveChangesContent;

  /// No description provided for @scheduleSaved.
  ///
  /// In en, this message translates to:
  /// **'Schedule saved successfully'**
  String get scheduleSaved;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String saveFailed(String error);

  /// No description provided for @timesPerDay.
  ///
  /// In en, this message translates to:
  /// **'Times per day'**
  String get timesPerDay;

  /// No description provided for @reminderTimesLabel.
  ///
  /// In en, this message translates to:
  /// **'Reminder times'**
  String get reminderTimesLabel;

  /// No description provided for @activeLabel.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeLabel;

  /// No description provided for @inactiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactiveLabel;

  /// No description provided for @patientReceivesReminders.
  ///
  /// In en, this message translates to:
  /// **'Patient receives reminders for this medication'**
  String get patientReceivesReminders;

  /// No description provided for @noRemindersSent.
  ///
  /// In en, this message translates to:
  /// **'No reminders sent — medication paused'**
  String get noRemindersSent;

  /// No description provided for @addMedication.
  ///
  /// In en, this message translates to:
  /// **'+ Add Medication'**
  String get addMedication;

  /// No description provided for @noMedicationsYet.
  ///
  /// In en, this message translates to:
  /// **'No medications yet'**
  String get noMedicationsYet;

  /// No description provided for @addFirstMedication.
  ///
  /// In en, this message translates to:
  /// **'Tap below to add the first medication for this patient.'**
  String get addFirstMedication;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @noChanges.
  ///
  /// In en, this message translates to:
  /// **'No Changes'**
  String get noChanges;

  /// No description provided for @scheduleFollowUpTitle.
  ///
  /// In en, this message translates to:
  /// **'Schedule Follow-up'**
  String get scheduleFollowUpTitle;

  /// No description provided for @followUpTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Type'**
  String get followUpTypeLabel;

  /// No description provided for @dateTimeLabel.
  ///
  /// In en, this message translates to:
  /// **'Date & Time'**
  String get dateTimeLabel;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesLabel;

  /// No description provided for @smsPreview.
  ///
  /// In en, this message translates to:
  /// **'SMS Preview'**
  String get smsPreview;

  /// No description provided for @editable.
  ///
  /// In en, this message translates to:
  /// **'Editable'**
  String get editable;

  /// No description provided for @toRecipient.
  ///
  /// In en, this message translates to:
  /// **'To: {name}'**
  String toRecipient(String name);

  /// No description provided for @charsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String charsCount(int count);

  /// No description provided for @smsQueued.
  ///
  /// In en, this message translates to:
  /// **'SMS will be queued and sent automatically when a network connection is available.'**
  String get smsQueued;

  /// No description provided for @followUpSavedLocally.
  ///
  /// In en, this message translates to:
  /// **'Follow-up saved locally. Will sync to backend and send SMS when online.'**
  String get followUpSavedLocally;

  /// No description provided for @followUpScheduled.
  ///
  /// In en, this message translates to:
  /// **'Follow-up Scheduled'**
  String get followUpScheduled;

  /// No description provided for @savedLocally.
  ///
  /// In en, this message translates to:
  /// **'Saved locally and will sync when online.'**
  String get savedLocally;

  /// No description provided for @smsQueuedPill.
  ///
  /// In en, this message translates to:
  /// **'SMS queued — will send when online'**
  String get smsQueuedPill;

  /// No description provided for @backToPatient.
  ///
  /// In en, this message translates to:
  /// **'Back to Patient'**
  String get backToPatient;

  /// No description provided for @scheduleFollowUpButton.
  ///
  /// In en, this message translates to:
  /// **'Schedule Follow-up'**
  String get scheduleFollowUpButton;

  /// No description provided for @followUpCall.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get followUpCall;

  /// No description provided for @followUpVisit.
  ///
  /// In en, this message translates to:
  /// **'Visit'**
  String get followUpVisit;

  /// No description provided for @followUpSms.
  ///
  /// In en, this message translates to:
  /// **'SMS'**
  String get followUpSms;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'E.g. Patient reported difficulty remembering evening dose.'**
  String get notesHint;

  /// No description provided for @reminderSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reminder Settings'**
  String get reminderSettingsTitle;

  /// No description provided for @noActiveMedicationsTitle.
  ///
  /// In en, this message translates to:
  /// **'No active medications'**
  String get noActiveMedicationsTitle;

  /// No description provided for @noActiveMedicationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your healthcare worker will assign medications to your account. They will appear here once added.'**
  String get noActiveMedicationsSubtitle;

  /// No description provided for @remindersOn.
  ///
  /// In en, this message translates to:
  /// **'{active} of {total} reminder(s) on'**
  String remindersOn(int active, int total);

  /// No description provided for @addReminderTime.
  ///
  /// In en, this message translates to:
  /// **'Add reminder time'**
  String get addReminderTime;

  /// No description provided for @reminderFrequencyNote.
  ///
  /// In en, this message translates to:
  /// **'Your healthcare worker may adjust your reminder frequency based on your adherence.'**
  String get reminderFrequencyNote;

  /// No description provided for @remindersSaved.
  ///
  /// In en, this message translates to:
  /// **'Reminders saved'**
  String get remindersSaved;

  /// No description provided for @removeReminderTooltip.
  ///
  /// In en, this message translates to:
  /// **'Remove reminder'**
  String get removeReminderTooltip;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @reportType.
  ///
  /// In en, this message translates to:
  /// **'Report Type'**
  String get reportType;

  /// No description provided for @perPatient.
  ///
  /// In en, this message translates to:
  /// **'Per Patient'**
  String get perPatient;

  /// No description provided for @perClinic.
  ///
  /// In en, this message translates to:
  /// **'Per Clinic'**
  String get perClinic;

  /// No description provided for @perPatientSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Individual adherence\nby date range'**
  String get perPatientSubtitle;

  /// No description provided for @perClinicSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All patients overview\nby date range'**
  String get perClinicSubtitle;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @tapToSelect.
  ///
  /// In en, this message translates to:
  /// **'Tap to select'**
  String get tapToSelect;

  /// No description provided for @patientLabel.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get patientLabel;

  /// No description provided for @noPatientsFoundHint.
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatientsFoundHint;

  /// No description provided for @selectPatient.
  ///
  /// In en, this message translates to:
  /// **'Select a patient…'**
  String get selectPatient;

  /// No description provided for @clinicLabel.
  ///
  /// In en, this message translates to:
  /// **'Clinic'**
  String get clinicLabel;

  /// No description provided for @autoLabel.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get autoLabel;

  /// No description provided for @dateRange.
  ///
  /// In en, this message translates to:
  /// **'Date Range'**
  String get dateRange;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @exportFormat.
  ///
  /// In en, this message translates to:
  /// **'Export Format'**
  String get exportFormat;

  /// No description provided for @previewReportData.
  ///
  /// In en, this message translates to:
  /// **'Preview Report Data'**
  String get previewReportData;

  /// No description provided for @previewLabel.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get previewLabel;

  /// No description provided for @rowsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} rows'**
  String rowsCount(int count);

  /// No description provided for @statAvg.
  ///
  /// In en, this message translates to:
  /// **'Avg'**
  String get statAvg;

  /// No description provided for @columnDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get columnDate;

  /// No description provided for @columnMedication.
  ///
  /// In en, this message translates to:
  /// **'Medication'**
  String get columnMedication;

  /// No description provided for @columnPatient.
  ///
  /// In en, this message translates to:
  /// **'Patient'**
  String get columnPatient;

  /// No description provided for @columnAdherence.
  ///
  /// In en, this message translates to:
  /// **'Adh. %'**
  String get columnAdherence;

  /// No description provided for @previewNote.
  ///
  /// In en, this message translates to:
  /// **'Preview shows data from local storage. Sync for the latest cloud data.'**
  String get previewNote;

  /// No description provided for @noDataForRange.
  ///
  /// In en, this message translates to:
  /// **'No data for this range'**
  String get noDataForRange;

  /// No description provided for @noDataSubtitle.
  ///
  /// In en, this message translates to:
  /// **'No adherence records were found for the selected\npatient and date range. Try widening your selection.'**
  String get noDataSubtitle;

  /// No description provided for @exportPDF.
  ///
  /// In en, this message translates to:
  /// **'Export PDF Report'**
  String get exportPDF;

  /// No description provided for @exportCSV.
  ///
  /// In en, this message translates to:
  /// **'Export CSV Report'**
  String get exportCSV;

  /// No description provided for @previewAndExport.
  ///
  /// In en, this message translates to:
  /// **'Preview & Export'**
  String get previewAndExport;

  /// No description provided for @pleaseSelectPatient.
  ///
  /// In en, this message translates to:
  /// **'Please select a patient first.'**
  String get pleaseSelectPatient;

  /// No description provided for @errorLoadingReport.
  ///
  /// In en, this message translates to:
  /// **'Error loading report: {error}'**
  String errorLoadingReport(String error);

  /// No description provided for @caregiverTitle.
  ///
  /// In en, this message translates to:
  /// **'Caregiver'**
  String get caregiverTitle;

  /// No description provided for @whatIsCaregiver.
  ///
  /// In en, this message translates to:
  /// **'What is a caregiver?'**
  String get whatIsCaregiver;

  /// No description provided for @caregiverDescription.
  ///
  /// In en, this message translates to:
  /// **'A caregiver will receive an alert when you miss a dose. They will not see your medication details or diagnosis.'**
  String get caregiverDescription;

  /// No description provided for @missedDoseAlert.
  ///
  /// In en, this message translates to:
  /// **'Missed dose alert'**
  String get missedDoseAlert;

  /// No description provided for @noMedicationNames.
  ///
  /// In en, this message translates to:
  /// **'No medication names'**
  String get noMedicationNames;

  /// No description provided for @noDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'No diagnosis'**
  String get noDiagnosis;

  /// No description provided for @caregiverLinkedTitle.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Linked'**
  String get caregiverLinkedTitle;

  /// No description provided for @activeStatus.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get activeStatus;

  /// No description provided for @phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneLabel;

  /// No description provided for @relationshipLabel.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get relationshipLabel;

  /// No description provided for @alertTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Alert type'**
  String get alertTypeLabel;

  /// No description provided for @dosesMissedOnly.
  ///
  /// In en, this message translates to:
  /// **'Dose-missed only'**
  String get dosesMissedOnly;

  /// No description provided for @privacyNote.
  ///
  /// In en, this message translates to:
  /// **'Your medication details and diagnosis remain private. Your caregiver only knows when a dose is missed.'**
  String get privacyNote;

  /// No description provided for @removeCaregiverButton.
  ///
  /// In en, this message translates to:
  /// **'Remove Caregiver'**
  String get removeCaregiverButton;

  /// No description provided for @caregiverPhoneField.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Phone Number *'**
  String get caregiverPhoneField;

  /// No description provided for @caregiverPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the caregiver\'s South African mobile number.'**
  String get caregiverPhoneHint;

  /// No description provided for @relationshipField.
  ///
  /// In en, this message translates to:
  /// **'Relationship *'**
  String get relationshipField;

  /// No description provided for @selectRelationship.
  ///
  /// In en, this message translates to:
  /// **'Select relationship…'**
  String get selectRelationship;

  /// No description provided for @consentText.
  ///
  /// In en, this message translates to:
  /// **'I confirm the caregiver has agreed to receive dose-missed alerts for this patient. They will not be sent any medication or diagnosis details.'**
  String get consentText;

  /// No description provided for @linkCaregiver.
  ///
  /// In en, this message translates to:
  /// **'Link Caregiver'**
  String get linkCaregiver;

  /// No description provided for @linking.
  ///
  /// In en, this message translates to:
  /// **'Linking…'**
  String get linking;

  /// No description provided for @removeCaregiverDialog.
  ///
  /// In en, this message translates to:
  /// **'Remove Caregiver?'**
  String get removeCaregiverDialog;

  /// No description provided for @removeCaregiverContent.
  ///
  /// In en, this message translates to:
  /// **'Removing your caregiver means they will no longer receive dose-missed alerts. You can re-link at any time.'**
  String get removeCaregiverContent;

  /// No description provided for @phoneRequired.
  ///
  /// In en, this message translates to:
  /// **'Phone number is required'**
  String get phoneRequired;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number'**
  String get phoneInvalid;

  /// No description provided for @caregiverConsentRequired.
  ///
  /// In en, this message translates to:
  /// **'Please confirm the caregiver has agreed.'**
  String get caregiverConsentRequired;

  /// No description provided for @selectRelationshipRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a relationship'**
  String get selectRelationshipRequired;

  /// No description provided for @caregiverSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to save. Please try again.'**
  String get caregiverSaveFailed;

  /// No description provided for @caregiverRemoved.
  ///
  /// In en, this message translates to:
  /// **'Caregiver removed.'**
  String get caregiverRemoved;

  /// No description provided for @caregiverLinkedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Caregiver Linked!'**
  String get caregiverLinkedSuccess;

  /// No description provided for @caregiverLinkedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'They will receive a dose-missed alert only.\nNo medication or diagnosis details will be shared.'**
  String get caregiverLinkedSubtitle;

  /// No description provided for @privacyProtected.
  ///
  /// In en, this message translates to:
  /// **'Dose-missed alerts only — privacy protected'**
  String get privacyProtected;

  /// No description provided for @navWorkerHome.
  ///
  /// In en, this message translates to:
  /// **'HOME'**
  String get navWorkerHome;

  /// No description provided for @navWorkerPatients.
  ///
  /// In en, this message translates to:
  /// **'PATIENTS'**
  String get navWorkerPatients;

  /// No description provided for @navWorkerReports.
  ///
  /// In en, this message translates to:
  /// **'REPORTS'**
  String get navWorkerReports;

  /// No description provided for @navWorkerRegister.
  ///
  /// In en, this message translates to:
  /// **'REGISTER'**
  String get navWorkerRegister;

  /// No description provided for @scheduledLabel.
  ///
  /// In en, this message translates to:
  /// **'Scheduled: '**
  String get scheduledLabel;

  /// No description provided for @loggedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Logged at: '**
  String get loggedAtLabel;

  /// No description provided for @takenButton.
  ///
  /// In en, this message translates to:
  /// **'TAKEN'**
  String get takenButton;

  /// No description provided for @missedButton.
  ///
  /// In en, this message translates to:
  /// **'MISSED'**
  String get missedButton;

  /// No description provided for @statusOverdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get statusOverdue;

  /// No description provided for @logoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTooltip;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'zu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zu':
      return AppLocalizationsZu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
