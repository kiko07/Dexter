// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Dexter';

  @override
  String get incorrectPassword => 'Incorrect password';

  @override
  String get setupNewPassword => 'Set up a new password';

  @override
  String get enterPassword => 'Enter password';

  @override
  String get password => 'Password';

  @override
  String get saveAndStart => 'Save and Start';

  @override
  String get login => 'Login';

  @override
  String get setupProfileFirst =>
      'Please set up a Profile first to import data.';

  @override
  String get manualEntry => 'Manual Entry';

  @override
  String get duplicateEntryWarning => 'Warning: Duplicate entry found!';

  @override
  String get saveAnyway => 'Save anyway';

  @override
  String get recordSavedSuccessfully => 'Record saved successfully';

  @override
  String get saveRecord => 'Save Record';

  @override
  String get noDataToExport => 'No data to export';

  @override
  String get failedToCreateFile => 'Failed to create file';

  @override
  String get failedToSaveCheckPermissions =>
      'Could not save file. Check permissions.';

  @override
  String get exportData => 'Export Data';

  @override
  String get exportDataDescription =>
      'All data from all profiles will be aggregated and exported into a single Excel file.';

  @override
  String get filterExportOptional => 'Filter Export (Optional)';

  @override
  String get exportAllAsExcel => 'Export all data as Excel file';

  @override
  String get importHistory => 'Import History';

  @override
  String get noImportHistory => 'No import history';

  @override
  String get undoImport => 'Undo Import';

  @override
  String get confirmUndo => 'Confirm Undo';

  @override
  String get cancel => 'Cancel';

  @override
  String get undoImportSuccess => 'Import undone successfully';

  @override
  String get confirmDelete => 'Confirm Delete';

  @override
  String get search => 'Search';

  @override
  String get data => 'Data';

  @override
  String get settings => 'Settings';

  @override
  String get importComplete => 'Import Complete';

  @override
  String get totalRecords => 'Total Records:';

  @override
  String get importedRecords => 'Imported:';

  @override
  String get skippedDuplicates => 'Skipped (Duplicates):';

  @override
  String get recordsWithError => 'Records with error:';

  @override
  String get finish => 'Finish';

  @override
  String get importData => 'Import Data';

  @override
  String get chooseFileOrFolder => 'Choose File or Folder';

  @override
  String get files => 'Files';

  @override
  String get noExcelFilesFound => 'No supported Excel or CSV files found';

  @override
  String get folder => 'Folder';

  @override
  String get headerRowNumber => 'Header Row Number:';

  @override
  String get next => 'Next';

  @override
  String get selectColumns => 'Select Columns';

  @override
  String get importAllFieldsAuto => 'Import all fields automatically';

  @override
  String get chooseColumns => 'Choose columns:';

  @override
  String get none => 'None';

  @override
  String get previous => 'Previous';

  @override
  String get dataPreview => 'Data Preview';

  @override
  String get dataWillBeImportedAsFollows =>
      'Data will be imported as follows based on your selection:';

  @override
  String get sampleData => 'Sample data...';

  @override
  String get looksCorrectStartImport => 'Looks correct - Start Import';

  @override
  String get importing => 'Importing...';

  @override
  String get searchResult => 'Search Result';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchForRecord => 'Search for a record...';

  @override
  String get matchType => 'Match Type:';

  @override
  String get exactMatch => 'Exact Search';

  @override
  String get containsMatch => 'Contains Search';

  @override
  String get fuzzyMatch => 'Fuzzy Search';

  @override
  String get pleaseEnterDataToSearch => 'Please enter data to search';

  @override
  String get noResults => 'No results';

  @override
  String get themeSettings => 'Theme';

  @override
  String get system => 'System';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get languageSettings => 'Language';

  @override
  String get arabic => 'Arabic';

  @override
  String get autoLockSettings => 'Auto-Lock';

  @override
  String get immediately => 'Immediately';

  @override
  String get oneMinute => '1 Minute';

  @override
  String get fiveMinutes => '5 Minutes';

  @override
  String get never => 'Never';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get changeCurrentAppPassword => 'Change current app password.';

  @override
  String get lockAppNow => 'Lock App Now';

  @override
  String get clearAllData => 'Clear All Data';

  @override
  String get allDataWillBeDeletedForever =>
      'All data and passwords will be permanently deleted.';

  @override
  String get currentPassword => 'Current Password';

  @override
  String get newPassword => 'New Password';

  @override
  String get passwordChangedSuccessfully => 'Password changed successfully';

  @override
  String get save => 'Save';

  @override
  String get warningClearAllData => 'Warning: Clear All Data';

  @override
  String get confirmClearAllDataText =>
      'Are you sure you want to clear all data from the application? This action cannot be undone and you will be logged out immediately.';

  @override
  String get confirmClear => 'Confirm Clear';

  @override
  String get appearanceAndLanguage => 'Appearance & Language';

  @override
  String get security => 'Security';

  @override
  String get dataAndSync => 'Data & Sync';

  @override
  String get autoUpdateImportedFiles => 'Auto-update imported files';

  @override
  String get checkForUpdatesOnStartup => 'Check for updates on startup';

  @override
  String get scanWatchedFolders => 'Scan watched folders';

  @override
  String get autoSearchNewFilesInFolders =>
      'Automatically search for new files in folders';

  @override
  String get addFolderToWatch => 'Add a folder to watch';

  @override
  String get advancedManagement => 'Advanced Management';

  @override
  String get currentPasswordIncorrect => 'Current password incorrect';

  @override
  String get english => 'English';

  @override
  String get designedBy => 'Designed by';

  @override
  String get ahmedElKilany => 'Captain / Ahmed El-Kilany';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortAlphabeticalAsc => 'Alphabetical (A-Z)';

  @override
  String get sortAlphabeticalDesc => 'Alphabetical (Z-A)';

  @override
  String get showAllData => 'Show all data';

  @override
  String processedRecordsCount(int count) {
    return 'Processed: $count records';
  }

  @override
  String get chooseSpecificFiles => 'Choose specific files';

  @override
  String get chooseEntireFolder => 'Choose entire folder';

  @override
  String errorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String filesSelected(int count) {
    return 'Selected $count file(s)';
  }

  @override
  String rowNumber(int number) {
    return 'Row $number';
  }

  @override
  String get stepReferenceRow => 'Reference Row';

  @override
  String get stepColumnSelection => 'Column Selection';

  @override
  String get stepReview => 'Review';

  @override
  String get stepImporting => 'Importing...';

  @override
  String autoUpdateSuccess(int count) {
    return 'Auto-update successful. Added $count new records.';
  }

  @override
  String autoUpdateError(String error) {
    return 'Error during auto-update: $error';
  }

  @override
  String get updateData => 'Update Data';

  @override
  String get updateDataSubtitle =>
      'Scan imported files and watched folders for updates';

  @override
  String get exportingWait => 'Exporting...';

  @override
  String get scanningWait => 'Scanning...';

  @override
  String get pleaseWaitAndDoNotClose => 'Please wait and do not close the app';

  @override
  String get chooseTimeRangeForExport =>
      'Choose the time range for the data you want to export.';

  @override
  String get allData => 'All Data';

  @override
  String get last24Hours => 'Last 24 Hours';

  @override
  String get last7Days => 'Last 7 Days';

  @override
  String get customPeriod => 'Custom Period';

  @override
  String get chooseDates => 'Choose Dates';

  @override
  String get pleaseSelectTimeRangeFirst => 'Please select a time range first.';

  @override
  String get exportNow => 'Export Now';

  @override
  String get importDataSubtitle => 'Add new data from Excel or CSV files';

  @override
  String get exportDataSubtitle =>
      'Export all registered data to an Excel file';

  @override
  String recordCountAndDate(int count, String date) {
    return 'Records: $count\nDate: $date';
  }

  @override
  String confirmDeleteImportBatch(String fileName) {
    return 'Are you sure you want to delete all records imported from file \"$fileName\"?\nThis action cannot be undone.';
  }

  @override
  String recordNumber(int id) {
    return 'Record Number: $id';
  }

  @override
  String allDataExportedSuccess(String path) {
    return 'All data exported successfully to: $path';
  }

  @override
  String dataExportedSuccess(String path) {
    return 'Data exported successfully to: $path';
  }

  @override
  String get filtersAndSorting => 'Filters & Sorting';

  @override
  String get hideData => 'Hide data';

  @override
  String get manageIndexedFiles => 'Manage Indexed Files';

  @override
  String get noIndexedFilesFound => 'No indexed files found';

  @override
  String get delete => 'Delete';

  @override
  String deletedSuccessfully(String fileName) {
    return '$fileName deleted successfully';
  }

  @override
  String get removePassword => 'Remove Password';

  @override
  String get removePasswordSubtitle => 'Remove the app password completely.';

  @override
  String get confirmRemovePassword =>
      'Are you sure you want to remove the password?';

  @override
  String get passwordRemovedSuccessfully => 'Password removed successfully';

  @override
  String get remove => 'Remove';

  @override
  String get useFaceId => 'Use Face ID';

  @override
  String get useFingerprint => 'Use Fingerprint';

  @override
  String get faceId => 'Face ID';

  @override
  String get fingerprint => 'Fingerprint';

  @override
  String get useFaceIdToUnlock => 'Use Face ID to unlock';

  @override
  String get useFingerprintToUnlock => 'Use Fingerprint to unlock';

  @override
  String get viewAndDeleteSpecificFileRecords =>
      'View and delete specific file records';

  @override
  String get selectSheets => 'Select Sheets to Import';

  @override
  String get scanForDuplicates => 'Scan for Duplicates';

  @override
  String get findAndRemoveDuplicates => 'Find and remove duplicate entries';

  @override
  String get noDuplicatesFound => 'No duplicates found!';

  @override
  String duplicatesFound(int count) {
    return '$count duplicate group(s) found';
  }

  @override
  String get keepFirst => 'Keep First';

  @override
  String totalRedundantEntries(int count) {
    return 'Total redundant entries: $count';
  }

  @override
  String copiesCount(int count) {
    return '$count copies';
  }

  @override
  String get keepBadge => 'KEEP';

  @override
  String get duplicateBadge => 'DUP';

  @override
  String get payload => 'Record data';

  @override
  String get confirmDeleteDuplicateCopy =>
      'Are you sure you want to delete this duplicate copy? This action cannot be undone.';

  @override
  String get advancedFilters => 'Advanced Filters';

  @override
  String get allFiles => 'All Files';

  @override
  String selectedFiles(int count) {
    return '$count file(s) selected';
  }

  @override
  String get fileScope => 'File Scope';

  @override
  String get chooseSearchScope => '1. Choose Excel file scope';

  @override
  String get chooseSearchScopeHint =>
      'Choose every imported Excel file, or select only the files you need before adding a filter.';

  @override
  String get allExcelFiles => 'All imported Excel files';

  @override
  String get allExcelFilesHint => 'Search every imported Excel file.';

  @override
  String get chooseExcelFiles => 'Choose specific Excel files';

  @override
  String get chooseExcelFilesHint =>
      'Search one or more Excel files that you select below.';

  @override
  String get selectAtLeastOneExcelFile =>
      'Select at least one Excel file to use this scope.';

  @override
  String get manualEntriesOnlyHint =>
      'Search only records entered manually, not imported Excel files.';

  @override
  String get addFilter => 'Add Filter';

  @override
  String get field => 'Field';

  @override
  String get operator => 'Operator';

  @override
  String get contains => 'Contains';

  @override
  String get doesNotContain => 'Does not contain';

  @override
  String get equalTo => 'Equal to';

  @override
  String get notEqualTo => 'Not equal to';

  @override
  String get greaterThan => 'Greater than';

  @override
  String get lessThan => 'Less than';

  @override
  String get betweenLabel => 'Between';

  @override
  String get copied => 'Copied';

  @override
  String get copy => 'Copy';

  @override
  String get selectAll => 'Select All';

  @override
  String get clear => 'Clear';

  @override
  String get manualEntriesOnly => 'Manually-entered only';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get invalidFilterValue => 'Enter a valid value for this filter';

  @override
  String get discardChangesTitle => 'Discard changes?';

  @override
  String get discardChangesMessage =>
      'You have unsaved data. Leave without saving it?';

  @override
  String get discard => 'Discard';

  @override
  String get secureStorageErrorTitle => 'Secure storage unavailable';

  @override
  String get secureStorageErrorMessage =>
      'Dexter could not read its secure storage. Restart the app or check device security settings before continuing.';

  @override
  String get authenticateToUnlock => 'Authenticate to unlock Dexter';

  @override
  String get authenticateToEnableBiometrics =>
      'Authenticate to enable biometrics';

  @override
  String get passwordTooShort => 'Password must be at least 4 characters';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String lockedOutSeconds(int seconds) {
    return 'Too many failed attempts. Try again in $seconds seconds.';
  }

  @override
  String get exportReady => 'Export ready';

  @override
  String get matchContains => 'Contains';

  @override
  String get matchExact => 'Exact';

  @override
  String get matchStartsWith => 'Starts with';

  @override
  String get matchFuzzy => 'Fuzzy';

  @override
  String get anyField => 'Any field';

  @override
  String get recordId => 'Record ID';

  @override
  String get profileId => 'Profile ID';

  @override
  String get sourceFile => 'Source file';

  @override
  String get importBatch => 'Import batch';

  @override
  String get createdAt => 'Created at';

  @override
  String get updatedAt => 'Updated at';

  @override
  String get startsWith => 'Starts with';

  @override
  String get doesNotStartWith => 'Does not start with';

  @override
  String get endsWith => 'Ends with';

  @override
  String get doesNotEndWith => 'Does not end with';

  @override
  String get containsAllWords => 'Has every word entered';

  @override
  String get containsAnyWord => 'Has at least one word entered';

  @override
  String get containsNoWords => 'Has none of the words entered';

  @override
  String get containsCaseSensitive => 'Contains exactly (case-sensitive)';

  @override
  String get equalCaseSensitive => 'Matches exactly (case-sensitive)';

  @override
  String get notEqualCaseSensitive => 'Does not match exactly (case-sensitive)';

  @override
  String get inList => 'Matches an item in a list';

  @override
  String get notInList => 'Does not match any item in a list';

  @override
  String get greaterThanOrEqual => 'Greater than or equal to';

  @override
  String get lessThanOrEqual => 'Less than or equal to';

  @override
  String get notBetween => 'Not between';

  @override
  String get isNumeric => 'Is numeric';

  @override
  String get isNotNumeric => 'Is not numeric';

  @override
  String get dateBefore => 'Date before';

  @override
  String get dateAfter => 'Date after';

  @override
  String get dateIs => 'Date is';

  @override
  String get dateIsNot => 'Date is not';

  @override
  String get dateBetween => 'Date between';

  @override
  String get dateToday => 'Date is today';

  @override
  String get dateInLastDays => 'Date is within the last N days';

  @override
  String get lengthEqual => 'Has exactly this many characters';

  @override
  String get lengthGreaterThan => 'Has more than this many characters';

  @override
  String get lengthLessThan => 'Has fewer than this many characters';

  @override
  String get lengthBetween => 'Has a character count in this range';

  @override
  String get fieldExists => 'Field exists (even if blank)';

  @override
  String get fieldMissing => 'Field is missing';

  @override
  String get isEmpty => 'Is blank';

  @override
  String get isNotEmpty => 'Has a value';

  @override
  String get valueLabel => 'Value';

  @override
  String get minValue => 'Minimum value';

  @override
  String get maxValue => 'Maximum value';

  @override
  String get dateLabel => 'Date';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get characters => 'Characters';

  @override
  String get minCharacters => 'Minimum characters';

  @override
  String get maxCharacters => 'Maximum characters';

  @override
  String get days => 'Days';

  @override
  String get separateWordsWithSpaces => 'Separate words with spaces';

  @override
  String get listValueHint =>
      'Separate items with commas, semicolons, or new lines';

  @override
  String get dateFormatHint => 'YYYY-MM-DD';

  @override
  String get pickDate => 'Pick date';

  @override
  String get filterExplanation => 'How this filter works';

  @override
  String get textFilterHint =>
      'Text matching ignores uppercase and lowercase unless the filter says case-sensitive.';

  @override
  String get numberFilterHint =>
      'Use numbers only. Text values are ignored for numeric comparisons.';

  @override
  String get dateFilterHint =>
      'Use the calendar to choose a date. Dates are compared by calendar day.';

  @override
  String get lengthFilterHint =>
      'Counts the characters in the field value, including spaces.';

  @override
  String get fieldStatusFilterHint =>
      '“Exists” checks whether the field is present; “blank” checks whether its value has no text.';

  @override
  String get statistics => 'Statistics';

  @override
  String get statisticsSubtitle =>
      'Explore trends and the composition of indexed data';

  @override
  String get last30Days => 'Last 30 Days';

  @override
  String get allTime => 'All Time';

  @override
  String get manualRecords => 'Manual Records';

  @override
  String get indexedFiles => 'Indexed Files';

  @override
  String get profiles => 'Profiles';

  @override
  String get recordsOverTime => 'Records Over Time';

  @override
  String get breakdown => 'Breakdown';

  @override
  String get bySourceFile => 'By Source File';

  @override
  String get byProfile => 'By Profile';

  @override
  String get noStatisticsData => 'No data is available for this period';

  @override
  String get manualSource => 'Manual entries';

  @override
  String recordsCount(int count) {
    return '$count records';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get timeRange => 'Time Range';

  @override
  String get noIndexedSourceFilesFound => 'No indexed source files found';

  @override
  String get scanningDuplicateEntries => 'Scanning for duplicate entries...';

  @override
  String settingsLoadError(String error) {
    return 'Could not load settings: $error';
  }

  @override
  String importCount(int count) {
    return '$count imports';
  }
}
