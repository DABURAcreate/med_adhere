// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Zulu (`zu`).
class AppLocalizationsZu extends AppLocalizations {
  AppLocalizationsZu([String locale = 'zu']) : super(locale);

  @override
  String get enterYourPin => 'Faka i-PIN yakho:';

  @override
  String get enterRegistrationCode => 'Faka Ikhodi Yokubhalisa';

  @override
  String get continueButton => 'Qhubeka';

  @override
  String get navHome => 'IKHAYA';

  @override
  String get navProgress => 'INQUBEKELA';

  @override
  String get navMeds => 'IMITHI';

  @override
  String get navRiskLevel => 'IZINGA LENGOZI';

  @override
  String get cancel => 'Khansela';

  @override
  String get save => 'Londoloza';

  @override
  String get done => 'Qedile';

  @override
  String get back => 'Emuva';

  @override
  String get edit => 'Hlela';

  @override
  String get remove => 'Susa';

  @override
  String get send => 'Thumela';

  @override
  String get logout => 'Phuma';

  @override
  String get never => 'Akukho';

  @override
  String get today => 'Namhlanje';

  @override
  String get yesterday => 'Izolo';

  @override
  String daysAgo(int count) {
    return '$count izinsuku ezedlule';
  }

  @override
  String get taken => 'Ithathiwe';

  @override
  String get missed => 'Ingenziwa';

  @override
  String get pending => 'Ilindile';

  @override
  String get loading => 'Iyalayisha…';

  @override
  String get required => 'Iyadingeka';

  @override
  String get medications => 'Imithi';

  @override
  String get inactive => 'AYISEBENZI';

  @override
  String get active => 'Iyasebenza';

  @override
  String get highRisk => 'Ingozi Enkulu';

  @override
  String get medRisk => 'Ingozi Ephakathi';

  @override
  String get lowRisk => 'Ingozi Encane';

  @override
  String get pinMismatch => 'Ama-PIN awafani. Sicela uzame futhi.';

  @override
  String get pinTooShort => 'Sicela ufake i-PIN enamanombolo angu-4.';

  @override
  String get fullNameLabel => 'Igama Eligcwele *';

  @override
  String get fullNameRequired => 'Igama eligcwele liyadingeka';

  @override
  String get noData => 'Ayikho idatha';

  @override
  String get noActiveMedications => 'Ayikho imithi esebenzayo.';

  @override
  String get next => 'Okulandelayo';

  @override
  String get loginNewPatient =>
      'Umsakazo omsha? Faka ikhodi yakho yokusebenzisa';

  @override
  String get loginWorkerRegister => 'Bhalisa njengeSisebenzi seZempilo';

  @override
  String get createPin => 'Dala i-PIN:';

  @override
  String get confirmPinLabel => 'Qinisekisa i-PIN:';

  @override
  String get languageLabel => 'Ulimi:';

  @override
  String get languageAlreadyRegistered => 'Usuvele ubhalisiwe? Ngena';

  @override
  String get registerWorkerTitle => 'Bhalisa njengeSisebenzi';

  @override
  String get staffDetails => 'Imininingwane Yabasebenzi';

  @override
  String get staffNumberLabel => 'Inombolo Yabasebenzi *';

  @override
  String get clinicNameOptional => 'Igama leKliniki (okukhethekile)';

  @override
  String get setYourPin => 'Setha i-PIN yakho';

  @override
  String get pinSubtitle =>
      'Khetha i-PIN enamanombolo angu-4 oyisebenzisa ukuze ungene.';

  @override
  String get pinLabel => 'I-PIN';

  @override
  String get confirmPinField => 'Qinisekisa i-PIN';

  @override
  String get registerSignIn => 'Bhalisa & Ngena';

  @override
  String get staffNumberRequired => 'Inombolo yabasebenzi iyadingeka';

  @override
  String get noPatientSession =>
      'Ayikho iseshini yomntu ogulayo. Sicela ungene futhi.';

  @override
  String get todaysDoses => 'Amaphilisi Anamhlanje';

  @override
  String get patientNotFound => 'Umguli akatholakali. Sicela ungene futhi.';

  @override
  String get todayProgress => 'Inqubekela yanamhlanje:';

  @override
  String greetingHi(String name) {
    return 'Sawubona, $name 👋';
  }

  @override
  String get noPatientSessionShort => 'Ayikho iseshini yomntu ogulayo.';

  @override
  String get noMedicationsAssigned => 'Ayikho imithi enikwe umntu ogulayo.';

  @override
  String dosageLabel(String dosage) {
    return 'Isibalo semithi: $dosage';
  }

  @override
  String get yourSchedule => 'Isikhathi Sakho:';

  @override
  String get noScheduledTimes => 'Awekho amasikhathi amiselweyo.';

  @override
  String get howToTake => 'Indlela Yokuphuza:';

  @override
  String get riskLevel => 'Izinga Lengozi';

  @override
  String get noActiveSession =>
      'Ayikho iseshini esebenzayo.\nSicela ungene kuqala.';

  @override
  String riskScore(int score) {
    return 'Amanqaku: $score/100';
  }

  @override
  String get thirtyDayAdherence => 'Ukulandela kwezinsuku ezingama-30';

  @override
  String get currentStreak => 'Ukulandela kwamanje';

  @override
  String get missedLast7Days => 'Ingenziwa (ezinsuku ze-7 ezedlule)';

  @override
  String get whyThisRating => 'Kungani leli zinga?';

  @override
  String get whatShouldIDo => 'Ngenzeni?';

  @override
  String get recalculate => 'Bala kabusha';

  @override
  String lastCalculated(String time) {
    return 'Ubalwe kwamuva: $time';
  }

  @override
  String get myProgress => 'Inqubekela Yami';

  @override
  String get legendPartial => 'Ingxenye';

  @override
  String streakDays(int n) {
    return 'Ukulandela kwezinsuku ezingu-$n';
  }

  @override
  String get noStreak => 'Ayikho Inqubekela';

  @override
  String get noDosesLogged => 'Ayikho amaphilisi arekhodi.';

  @override
  String doseLoggedAt(String time) {
    return 'Ithathiwe ngo-$time';
  }

  @override
  String doseMissedAt(String scheduledAt) {
    return 'Ingenziwa ($scheduledAt)';
  }

  @override
  String get thisMonth => 'Inyanga le';

  @override
  String monthlyDosesSummary(int taken, int scheduled) {
    return 'Uthathile $taken kwezinga $scheduled zamaPhilisi amiselweyo.';
  }

  @override
  String get previousMonth => 'Inyanga Edlule';

  @override
  String greeting(String name) {
    return 'Sawubona, $name';
  }

  @override
  String get syncing => 'Iyavumelanisa…';

  @override
  String syncedAt(String time) {
    return 'Ivumelanisiwe ngo-$time';
  }

  @override
  String get totalPatients => 'Bonke Abantu abagulayo';

  @override
  String get avgAdherence => 'Ukulandela Okwavelele';

  @override
  String get actionRequired => 'Isinyathelo Siyadingeka';

  @override
  String get viewAll => 'Bona konke';

  @override
  String get noHighRiskPatients => 'Ayikho ingozi enkulu — umsebenzi omuhle!';

  @override
  String lastSeen(String time) {
    return 'Ibonwe kwamuva: $time';
  }

  @override
  String get adherence => 'ukulandela';

  @override
  String riskBadge(String score) {
    return 'Ingozi $score%';
  }

  @override
  String get clinicAdherenceTrend => 'Isimo Sokulandela EseKliniki';

  @override
  String get thirtyDays => 'Izinsuku ezingama-30';

  @override
  String get clinicWideAdherence => 'Iphesenti lokulandela kwemithi eKliniki';

  @override
  String get loadingTrend => 'Iyalayisha isimo…';

  @override
  String get navDashboard => 'Ikhaya';

  @override
  String get navPatients => 'Abantu abagulayo';

  @override
  String get navReports => 'Imibiko';

  @override
  String get navSettings => 'Izilungiselelo';

  @override
  String get patientList => 'Uhlu Labantu abagulayo';

  @override
  String get searchByNameOrCode => 'Sesha ngegama noma ikhodi yeKliniki…';

  @override
  String get filterAll => 'Bonke';

  @override
  String get sortBy => 'Hlukanisa nge';

  @override
  String get sortRiskLevel => 'Izinga Lengozi';

  @override
  String get sortName => 'Igama';

  @override
  String get sortLastActive => 'Okwamuva Ukusebenza';

  @override
  String get adherence30d => 'ukulandela (30d)';

  @override
  String get noPatientsFound => 'Akatholakali umuntu ogulayo';

  @override
  String get noPatientsFoundSubtitle =>
      'Zama ukuguqula ukusesha kwakho noma isihluzo, noma bhalisa umuntu omsha ogulayo.';

  @override
  String get registerNewPatient => 'Bhalisa Umuntu Omsha Ogulayo';

  @override
  String patientCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count abantu abagulayo',
      one: 'umuntu oyedwa ogulayo',
    );
    return '$_temp0';
  }

  @override
  String get registerPatient => 'Bhalisa Umuntu Ogulayo';

  @override
  String get stepPatientInfo => 'Ulwazi\nloMguli';

  @override
  String get stepConfirm => 'Qinisekisa';

  @override
  String get patientInformationTitle => 'Ulwazi Lomntu Ogulayo';

  @override
  String get patientInformationSubtitle =>
      'Faka imininingwane eyisisekelo yomntu ogulayo njengoba irekhodi eKliniki.';

  @override
  String get clinicPatientCodeLabel => 'Ikhodi Yomntu Ogulayo EKliniki *';

  @override
  String get codeAutoGenerated =>
      'Ikhiqizwa ngokuzenzela — guqula uma kudingeka';

  @override
  String get conditionsLabel => 'Isifo/Izifo *';

  @override
  String get conditionsHint => 'Khetha konke okusebenzayo';

  @override
  String get caregiverPhoneOptional =>
      'Inombolo Yocingo Lomnakekeli (okukhethekile)';

  @override
  String get patientCodeRequired => 'Ikhodi yomntu ogulayo iyadingeka';

  @override
  String get secureStorageInfo =>
      'Igama eligcwele ne-ID igcinwa ngokuvikeleka ku-backend kuphela. Idivayisi yendawo igcina ikhodi yeKliniki kuphela.';

  @override
  String get medicationsSubtitle =>
      'Faka yonke imithi umuntu ogulayo ofanele ayithethe.';

  @override
  String medicationCard(int n) {
    return 'Umuthi $n';
  }

  @override
  String get medicationNameLabel => 'Igama Lomuthi *';

  @override
  String get dosageFieldLabel => 'Isibalo Somuthi *';

  @override
  String get timesPerDayField => 'Izikhathi ngosuku *';

  @override
  String get medicationNameRequired => 'Igama lomuthi liyadingeka';

  @override
  String get dosageRequired => 'Isibalo somuthi siyadingeka';

  @override
  String get addAnotherMedication => '+ Faka Elinye Umuthi';

  @override
  String get remindersTitle => 'Setha Izikhathi Zezikhumbuzo';

  @override
  String get remindersSubtitle =>
      'Setha izikhathi zezikhumbuzo zanamuhla-nomunye usuku ngomuthi ngamunye. Lezi zisetha egameni lomntu ogulayo.';

  @override
  String timesDaily(int n) {
    return '$n× ngosuku';
  }

  @override
  String doseLabel(int n) {
    return 'Umphambano $n';
  }

  @override
  String get remindersInfo =>
      'Izikhathi zezikhumbuzo zisetha ngusisebenzi egameni lomntu ogulayo. Umuntu ogulayo angaguqula lezi emuva kokukhipha i-akhawunti yakhe.';

  @override
  String get confirmRegistrationTitle => 'Qinisekisa Ukubhalisa';

  @override
  String get confirmRegistrationSubtitle =>
      'Bheka yonke imininingwane ngaphambi kokubhalisa umuntu ogulayo.';

  @override
  String get summaryPatientInformation => 'Ulwazi Lomntu Ogulayo';

  @override
  String get summaryClinicCode => 'Ikhodi YeKliniki';

  @override
  String get summaryConditions => 'Izifo';

  @override
  String get summaryCaregiverPhone => 'Inombolo Yocingo Lomnakekeli';

  @override
  String get summaryFullName => 'Igama Eligcwele';

  @override
  String get patientActivationCode => 'Ikhodi Yokusebenzisa Komntu Ogulayo';

  @override
  String get activationCodeHint =>
      'Nika umuntu ogulayo leli khodi ukuze asebenzise i-akhawunti yakhe';

  @override
  String get copyCode => 'Kopisha Ikhodi';

  @override
  String get patientRegistered => 'Umuntu Ogulayo Ubhalisiwe!';

  @override
  String patientRegisteredSuccess(String name) {
    return '$name ubhalisiwe ngempumelelo.';
  }

  @override
  String get patientActivationCodeLabel =>
      'IKHODI YOKUSEBENZISA KOMNTU OGULAYO';

  @override
  String get activationCodeShare =>
      'Yabelana naleli khodi enamanombolo angu-5 nomuntu ogulayo.\nBayosisebenzisa ukusetha i-PIN yabo futhi basebenzise i-akhawunti yabo.';

  @override
  String get registerPatientButton => 'Bhalisa Umuntu Ogulayo';

  @override
  String get conditionRequired => 'Sicela ukhethe isifo esisodwa okungenani.';

  @override
  String registrationFailed(String error) {
    return 'Ukubhalisa kwehlulekile: $error';
  }

  @override
  String get codeCopied => 'Ikhodi ikopishiwe ku-clipboard';

  @override
  String get activationCodeCopied => 'Ikhodi yokusebenzisa ikopishiwe';

  @override
  String get patientNotFoundError => 'Umuntu ogulayo akatholakali.';

  @override
  String couldNotLoadPatient(String error) {
    return 'Ayikwazeki ukulayisha idatha yomntu ogulayo: $error';
  }

  @override
  String get adherenceSummary => 'Isifinyezo Sokulandela';

  @override
  String get thirtyDayAdherenceRate =>
      'Iphesenti lokulandela lwezinsuku ezingama-30';

  @override
  String get missedDosesLabel => 'amaphilisi\nangenziwanga';

  @override
  String get last14Days => 'Izinsuku Ezingu-14 Ezedlule';

  @override
  String get workerBadge => 'ISISEBENZI';

  @override
  String get whyThisRiskLevel => 'Kungani leli zinga lengozi?';

  @override
  String get actionsTitle => 'Izinyathelo';

  @override
  String get scheduleFollowUp => 'Hlela Ukubuya';

  @override
  String get sendSmsReminder => 'Thumela i-SMS Yesikhumbuzo';

  @override
  String get editMedicationSchedule => 'Hlela Uhlelo Lwemithi';

  @override
  String get manageCaregiver => 'Phatha Umnakekeli';

  @override
  String sendSmsDialogContent(String name) {
    return 'Thumela i-SMS yesikhumbuzo semithi ku-$name?';
  }

  @override
  String smsSent(String name) {
    return 'I-SMS ithunyiwe ku-$name';
  }

  @override
  String get followUpLog => 'Irekhodi Lokubuya';

  @override
  String get noFollowUpNotes => 'Awekho amanothi okubuya.';

  @override
  String get noMedicationsScheduled => 'Ayikho imithi emiselwayo.';

  @override
  String get medicationScheduleTitle => 'Uhlelo Lwemithi';

  @override
  String get unsavedChanges => 'Izinguquko Ezingalondolozwanga';

  @override
  String get leaveWithoutSaving =>
      'Unezinguquko ezingalondolozwanga. Hamba ngaphandle kokulondoloza?';

  @override
  String get keepEditing => 'Qhubeka Ushintsha';

  @override
  String get discard => 'Lahla';

  @override
  String get futureDosesOnly =>
      'Izinguquko zisebenza kuphela kwamaphilisi esikhathini esizayo futhi aziyithinti imininingwane erekhodiwe.';

  @override
  String medsCount(int count) {
    return '$count imithi';
  }

  @override
  String get removeMedication => 'Susa Umuthi?';

  @override
  String removeMedicationContent(String name) {
    return 'Susa $name kuhlelo lomntu ogulayo? Amalogisi asedlule ngeke athinteke.';
  }

  @override
  String get saveChangesQuestion => 'Londoloza Izinguquko?';

  @override
  String get saveChangesContent =>
      'Izinguquko zisebenza kuphela kwamaphilisi esikhathini esizayo. Amalogisi asedlule ngeke athinteke.';

  @override
  String get scheduleSaved => 'Uhlelo lulondolozwe ngempumelelo';

  @override
  String saveFailed(String error) {
    return 'Ukulondoloza kwehlulekile: $error';
  }

  @override
  String get timesPerDay => 'Izikhathi ngosuku';

  @override
  String get reminderTimesLabel => 'Izikhathi Zezikhumbuzo';

  @override
  String get activeLabel => 'Iyasebenza';

  @override
  String get inactiveLabel => 'Ayisebenzi';

  @override
  String get patientReceivesReminders =>
      'Umuntu ogulayo uthola izikhumbuzo zalo muthi';

  @override
  String get noRemindersSent => 'Azithunywa izikhumbuzo — umuthi uphephiswe';

  @override
  String get addMedication => '+ Faka Umuthi';

  @override
  String get noMedicationsYet => 'Ayikho imithi';

  @override
  String get addFirstMedication =>
      'Chofoza ngezansi ukufaka umuthi wokuqala walomntu ogulayo.';

  @override
  String get saveChanges => 'Londoloza Izinguquko';

  @override
  String get noChanges => 'Azikho Izinguquko';

  @override
  String get scheduleFollowUpTitle => 'Hlela Ukubuya';

  @override
  String get followUpTypeLabel => 'Uhlobo Lokubuyela';

  @override
  String get dateTimeLabel => 'Usuku Nesikhathi';

  @override
  String get dateLabel => 'Usuku';

  @override
  String get timeLabel => 'Isikhathi';

  @override
  String get notesLabel => 'Amanothi';

  @override
  String get smsPreview => 'Ukubuka i-SMS';

  @override
  String get editable => 'Inguqulwa';

  @override
  String toRecipient(String name) {
    return 'Ku: $name';
  }

  @override
  String charsCount(int count) {
    return '$count izinhlamvu';
  }

  @override
  String get smsQueued =>
      'I-SMS izobhekwa futhi ithunywe ngokuzenzela uma kunxenye intanethi.';

  @override
  String get followUpSavedLocally =>
      'Ukubuya kulondolozwe endaweni. Kuzovumelaniswa ku-backend futhi kuthumele i-SMS uma ku-intanethi.';

  @override
  String get followUpScheduled => 'Ukubuya Kumishelwe';

  @override
  String get savedLocally =>
      'Kulondolozwe endaweni futhi kuzovumelaniswa uma ku-intanethi.';

  @override
  String get smsQueuedPill => 'I-SMS ilindile — iyothunywa uma ku-intanethi';

  @override
  String get backToPatient => 'Buyela kuMntu Ogulayo';

  @override
  String get scheduleFollowUpButton => 'Hlela Ukubuya';

  @override
  String get followUpCall => 'Ucingo';

  @override
  String get followUpVisit => 'Ukuvakasha';

  @override
  String get followUpSms => 'I-SMS';

  @override
  String get notesHint =>
      'Nj. Umuntu ogulayo wabika inkinga yokukhumbula umphambano wakusihlwa.';

  @override
  String get reminderSettingsTitle => 'Izilungiselelo Zezikhumbuzo';

  @override
  String get noActiveMedicationsTitle => 'Ayikho imithi esebenzayo';

  @override
  String get noActiveMedicationsSubtitle =>
      'Isisebenzi sakho sezempilo sizonikelezela imithi ku-akhawunti yakho. Izovela lapha uma izengezwa.';

  @override
  String remindersOn(int active, int total) {
    return '$active kwezingu-$total isikhumbuzo sivuliwe';
  }

  @override
  String get addReminderTime => 'Faka isikhathi sesikhumbuzo';

  @override
  String get reminderFrequencyNote =>
      'Isisebenzi sakho sezempilo singashintsha imikhakha yezikhumbuzo zakho ngokusekelwe kukulandela kwakho.';

  @override
  String get remindersSaved => 'Izikhumbuzo zilondolozwe';

  @override
  String get removeReminderTooltip => 'Susa isikhumbuzo';

  @override
  String get reports => 'Imibiko';

  @override
  String get reportType => 'Uhlobo Lombiko';

  @override
  String get perPatient => 'Ngomntu Ogulayo';

  @override
  String get perClinic => 'NgeKliniki';

  @override
  String get perPatientSubtitle =>
      'Ukulandela komuntu ngamunye\nngoqobo losuku';

  @override
  String get perClinicSubtitle =>
      'Ukubuka bonke abantu abagulayo\nngoqobo losuku';

  @override
  String get selected => 'Ikhethiwe';

  @override
  String get tapToSelect => 'Chofoza ukuze ukhethe';

  @override
  String get patientLabel => 'Umuntu Ogulayo';

  @override
  String get noPatientsFoundHint => 'Akatholakali umuntu ogulayo';

  @override
  String get selectPatient => 'Khetha umuntu ogulayo…';

  @override
  String get clinicLabel => 'IKliniki';

  @override
  String get autoLabel => 'Ngokuzenzela';

  @override
  String get dateRange => 'Inqobo Yamalanga';

  @override
  String daysCount(int count) {
    return '$count izinsuku';
  }

  @override
  String get exportFormat => 'Ifomethi Yokukhipha';

  @override
  String get previewReportData => 'Buka Idatha Yombiko';

  @override
  String get previewLabel => 'Ukubuka';

  @override
  String rowsCount(int count) {
    return '$count imigqa';
  }

  @override
  String get statAvg => 'Okwavelele';

  @override
  String get columnDate => 'Usuku';

  @override
  String get columnMedication => 'Umuthi';

  @override
  String get columnPatient => 'Umuntu Ogulayo';

  @override
  String get columnAdherence => 'Iphes. %';

  @override
  String get previewNote =>
      'Ukubuka kubonisa idatha endaweni. Vumela ukuvumelaniswa ukuze uthole idatha yakamuva.';

  @override
  String get noDataForRange => 'Ayikho idatha naleli banga';

  @override
  String get noDataSubtitle =>
      'Ayikho amarekhodi okulandela atholakele kumntu ogulayo nokubanga lwamalanga elikhethiwe. Zama ukwandisa ukukhetha kwakho.';

  @override
  String get exportPDF => 'Khipha Umbiko we-PDF';

  @override
  String get exportCSV => 'Khipha Umbiko we-CSV';

  @override
  String get previewAndExport => 'Buka & Khipha';

  @override
  String get pleaseSelectPatient => 'Sicela ukhethe umuntu ogulayo kuqala.';

  @override
  String errorLoadingReport(String error) {
    return 'Iphutha ukulayisha umbiko: $error';
  }

  @override
  String get caregiverTitle => 'Umnakekeli';

  @override
  String get whatIsCaregiver => 'Yini uMnakekeli?';

  @override
  String get caregiverDescription =>
      'Umnakekeli uzothola isaziso uma uphutha umphambano. Ngeke babone imininingwane yakho yemithi noma ukuxilongwa kwakho.';

  @override
  String get missedDoseAlert => 'Isaziso sokuphuthelwa umphambano';

  @override
  String get noMedicationNames => 'Ayikho amagama emithi';

  @override
  String get noDiagnosis => 'Ayikho ukuxilongwa';

  @override
  String get caregiverLinkedTitle => 'Umnakekeli Uhlanganisiwe';

  @override
  String get activeStatus => 'Uyasebenza';

  @override
  String get phoneLabel => 'Inombolo Yocingo';

  @override
  String get relationshipLabel => 'Ubuhlobo';

  @override
  String get alertTypeLabel => 'Uhlobo Lwesaziso';

  @override
  String get dosesMissedOnly => 'Ukuphuthelwa umphambano kuphela';

  @override
  String get privacyNote =>
      'Imininingwane yakho yemithi nokuxilongwa kuhlala kuyimfihlo. Umnakekeli wakho uazi kuphela uma umphambano uphutha.';

  @override
  String get removeCaregiverButton => 'Susa Umnakekeli';

  @override
  String get caregiverPhoneField => 'Inombolo Yocingo Lomnakekeli *';

  @override
  String get caregiverPhoneHint =>
      'Faka inombolo yocingo lomnakekeli yase-Ningizimu Afrika.';

  @override
  String get relationshipField => 'Ubuhlobo *';

  @override
  String get selectRelationship => 'Khetha ubuhlobo…';

  @override
  String get consentText =>
      'Ngiyaqinisekisa ukuthi umnakekeli uvumelene ukuthola izaziso zokuphuthelwa amaphilisi. Ngeke bathunywe imininingwane yemithi noma yokuxilongwa.';

  @override
  String get linkCaregiver => 'Hlanganisa Umnakekeli';

  @override
  String get linking => 'Iyahlanganisa…';

  @override
  String get removeCaregiverDialog => 'Susa Umnakekeli?';

  @override
  String get removeCaregiverContent =>
      'Ukususa uMnakekeli wakho kusho ukuthi ngeke besathola izaziso zokuphuthelwa amaphilisi. Ungaphinda uhlanganise noma nini.';

  @override
  String get phoneRequired => 'Inombolo yocingo iyadingeka';

  @override
  String get phoneInvalid => 'Faka inombolo yocingo evumelekile';

  @override
  String get caregiverConsentRequired =>
      'Sicela uqinisekise ukuthi umnakekeli uvumelene.';

  @override
  String get selectRelationshipRequired => 'Sicela ukhethe ubuhlobo';

  @override
  String get caregiverSaveFailed =>
      'Ukulondoloza kwehlulekile. Sicela uzame futhi.';

  @override
  String get caregiverRemoved => 'Umnakekeli usuliwe.';

  @override
  String get caregiverLinkedSuccess => 'Umnakekeli Uhlanganisiwe!';

  @override
  String get caregiverLinkedSubtitle =>
      'Bayothola isaziso sokuphuthelwa umphambano kuphela.\nAyikho imininingwane yemithi noma yokuxilongwa eyosabelwa.';

  @override
  String get privacyProtected =>
      'Izaziso zokuphuthelwa amaphilisi kuphela — imfihlo iyavikelwa';

  @override
  String get navWorkerHome => 'IKHAYA';

  @override
  String get navWorkerPatients => 'ABANTU ABAGULAYO';

  @override
  String get navWorkerReports => 'IMIBIKO';

  @override
  String get navWorkerRegister => 'BHALISA';

  @override
  String get scheduledLabel => 'Amiselwe: ';

  @override
  String get loggedAtLabel => 'Irekhodi ngo: ';

  @override
  String get takenButton => 'ITHATHIWE';

  @override
  String get missedButton => 'INGENZIWA';

  @override
  String get statusOverdue => 'Isikhathi Sidlule';

  @override
  String get logoutTooltip => 'Phuma';
}
