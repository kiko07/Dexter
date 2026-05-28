import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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
    Locale('ar'),
    Locale('en'),
  ];

  /// The title of the application
  ///
  /// In ar, this message translates to:
  /// **'دكستر'**
  String get appTitle;

  /// No description provided for @incorrectPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور غير صحيحة'**
  String get incorrectPassword;

  /// No description provided for @setupNewPassword.
  ///
  /// In ar, this message translates to:
  /// **'قم بإعداد كلمة مرور جديدة'**
  String get setupNewPassword;

  /// No description provided for @enterPassword.
  ///
  /// In ar, this message translates to:
  /// **'أدخل كلمة المرور'**
  String get enterPassword;

  /// No description provided for @password.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get password;

  /// No description provided for @saveAndStart.
  ///
  /// In ar, this message translates to:
  /// **'حفظ والبدء'**
  String get saveAndStart;

  /// No description provided for @login.
  ///
  /// In ar, this message translates to:
  /// **'دخول'**
  String get login;

  /// No description provided for @setupProfileFirst.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إعداد ملف تعريف (Profile) أولاً لاستيراد البيانات.'**
  String get setupProfileFirst;

  /// No description provided for @manualEntry.
  ///
  /// In ar, this message translates to:
  /// **'إدخال يدوي'**
  String get manualEntry;

  /// No description provided for @duplicateEntryWarning.
  ///
  /// In ar, this message translates to:
  /// **'تحذير: تم العثور على سجل مكرر!'**
  String get duplicateEntryWarning;

  /// No description provided for @saveAnyway.
  ///
  /// In ar, this message translates to:
  /// **'حفظ على أي حال'**
  String get saveAnyway;

  /// No description provided for @recordSavedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم حفظ السجل بنجاح'**
  String get recordSavedSuccessfully;

  /// No description provided for @saveRecord.
  ///
  /// In ar, this message translates to:
  /// **'حفظ السجل'**
  String get saveRecord;

  /// No description provided for @noDataToExport.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات للتصدير'**
  String get noDataToExport;

  /// No description provided for @failedToCreateFile.
  ///
  /// In ar, this message translates to:
  /// **'فشل إنشاء الملف'**
  String get failedToCreateFile;

  /// No description provided for @failedToSaveCheckPermissions.
  ///
  /// In ar, this message translates to:
  /// **'تعذر حفظ الملف. تحقق من الصلاحيات.'**
  String get failedToSaveCheckPermissions;

  /// No description provided for @exportData.
  ///
  /// In ar, this message translates to:
  /// **'تصدير البيانات'**
  String get exportData;

  /// No description provided for @exportDataDescription.
  ///
  /// In ar, this message translates to:
  /// **'سيتم تجميع وتصدير كافة البيانات من جميع ملفات التعريف في ملف إكسل واحد.'**
  String get exportDataDescription;

  /// No description provided for @filterExportOptional.
  ///
  /// In ar, this message translates to:
  /// **'تصفية بالتصدير (اختياري)'**
  String get filterExportOptional;

  /// No description provided for @exportAllAsExcel.
  ///
  /// In ar, this message translates to:
  /// **'تصدير كافة البيانات كملف Excel'**
  String get exportAllAsExcel;

  /// No description provided for @importHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل الاستيراد'**
  String get importHistory;

  /// No description provided for @noImportHistory.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد سجل استيراد'**
  String get noImportHistory;

  /// No description provided for @undoImport.
  ///
  /// In ar, this message translates to:
  /// **'تراجع عن الاستيراد'**
  String get undoImport;

  /// No description provided for @confirmUndo.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد التراجع'**
  String get confirmUndo;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'إلغاء'**
  String get cancel;

  /// No description provided for @undoImportSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم التراجع عن الاستيراد بنجاح'**
  String get undoImportSuccess;

  /// No description provided for @confirmDelete.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الحذف'**
  String get confirmDelete;

  /// No description provided for @search.
  ///
  /// In ar, this message translates to:
  /// **'بحث'**
  String get search;

  /// No description provided for @data.
  ///
  /// In ar, this message translates to:
  /// **'البيانات'**
  String get data;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @importComplete.
  ///
  /// In ar, this message translates to:
  /// **'اكتمل الاستيراد'**
  String get importComplete;

  /// No description provided for @totalRecords.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السجلات:'**
  String get totalRecords;

  /// No description provided for @importedRecords.
  ///
  /// In ar, this message translates to:
  /// **'تم استيراد:'**
  String get importedRecords;

  /// No description provided for @skippedDuplicates.
  ///
  /// In ar, this message translates to:
  /// **'تم تخطي (مكرر):'**
  String get skippedDuplicates;

  /// No description provided for @recordsWithError.
  ///
  /// In ar, this message translates to:
  /// **'سجلات بها خطأ:'**
  String get recordsWithError;

  /// No description provided for @finish.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get finish;

  /// No description provided for @importData.
  ///
  /// In ar, this message translates to:
  /// **'استيراد البيانات'**
  String get importData;

  /// No description provided for @chooseFileOrFolder.
  ///
  /// In ar, this message translates to:
  /// **'اختر الملف أو المجلد'**
  String get chooseFileOrFolder;

  /// No description provided for @files.
  ///
  /// In ar, this message translates to:
  /// **'ملفات'**
  String get files;

  /// No description provided for @noExcelFilesFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على ملفات إكسيل'**
  String get noExcelFilesFound;

  /// No description provided for @folder.
  ///
  /// In ar, this message translates to:
  /// **'مجلد'**
  String get folder;

  /// No description provided for @headerRowNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم صف المرجع (العناوين):'**
  String get headerRowNumber;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @selectColumns.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الأعمدة'**
  String get selectColumns;

  /// No description provided for @importAllFieldsAuto.
  ///
  /// In ar, this message translates to:
  /// **'استيراد كل الحقول تلقائياً'**
  String get importAllFieldsAuto;

  /// No description provided for @chooseColumns.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الاعمدة:'**
  String get chooseColumns;

  /// No description provided for @none.
  ///
  /// In ar, this message translates to:
  /// **'لا يوجد'**
  String get none;

  /// No description provided for @previous.
  ///
  /// In ar, this message translates to:
  /// **'السابق'**
  String get previous;

  /// No description provided for @dataPreview.
  ///
  /// In ar, this message translates to:
  /// **'معاينة البيانات'**
  String get dataPreview;

  /// No description provided for @dataWillBeImportedAsFollows.
  ///
  /// In ar, this message translates to:
  /// **'سيتم استيراد البيانات بالشكل التالي بناءً على اختيارك:'**
  String get dataWillBeImportedAsFollows;

  /// No description provided for @sampleData.
  ///
  /// In ar, this message translates to:
  /// **'بيانات تجريبية...'**
  String get sampleData;

  /// No description provided for @looksCorrectStartImport.
  ///
  /// In ar, this message translates to:
  /// **'يبدو صحيحاً - ابدأ الاستيراد'**
  String get looksCorrectStartImport;

  /// No description provided for @importing.
  ///
  /// In ar, this message translates to:
  /// **'جاري الاستيراد...'**
  String get importing;

  /// No description provided for @searchResult.
  ///
  /// In ar, this message translates to:
  /// **'نتيجة البحث'**
  String get searchResult;

  /// No description provided for @searchTitle.
  ///
  /// In ar, this message translates to:
  /// **'البحث'**
  String get searchTitle;

  /// No description provided for @searchForRecord.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن سجل...'**
  String get searchForRecord;

  /// No description provided for @matchType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المطابقة:'**
  String get matchType;

  /// No description provided for @exactMatch.
  ///
  /// In ar, this message translates to:
  /// **'بحث دقيق'**
  String get exactMatch;

  /// No description provided for @containsMatch.
  ///
  /// In ar, this message translates to:
  /// **'بحث شامل'**
  String get containsMatch;

  /// No description provided for @fuzzyMatch.
  ///
  /// In ar, this message translates to:
  /// **'توسيع دائرة البحث'**
  String get fuzzyMatch;

  /// No description provided for @pleaseEnterDataToSearch.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء إدخال بيانات للبحث'**
  String get pleaseEnterDataToSearch;

  /// No description provided for @noResults.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد نتائج'**
  String get noResults;

  /// No description provided for @themeSettings.
  ///
  /// In ar, this message translates to:
  /// **'المظهر (Theme)'**
  String get themeSettings;

  /// No description provided for @system.
  ///
  /// In ar, this message translates to:
  /// **'النظام'**
  String get system;

  /// No description provided for @light.
  ///
  /// In ar, this message translates to:
  /// **'فاتح'**
  String get light;

  /// No description provided for @dark.
  ///
  /// In ar, this message translates to:
  /// **'داكن'**
  String get dark;

  /// No description provided for @languageSettings.
  ///
  /// In ar, this message translates to:
  /// **'اللغة (Language)'**
  String get languageSettings;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @autoLockSettings.
  ///
  /// In ar, this message translates to:
  /// **'القفل التلقائي (Auto-Lock)'**
  String get autoLockSettings;

  /// No description provided for @immediately.
  ///
  /// In ar, this message translates to:
  /// **'فوراً'**
  String get immediately;

  /// No description provided for @oneMinute.
  ///
  /// In ar, this message translates to:
  /// **'دقيقة واحدة'**
  String get oneMinute;

  /// No description provided for @fiveMinutes.
  ///
  /// In ar, this message translates to:
  /// **'5 دقائق'**
  String get fiveMinutes;

  /// No description provided for @never.
  ///
  /// In ar, this message translates to:
  /// **'أبداً'**
  String get never;

  /// No description provided for @resetPassword.
  ///
  /// In ar, this message translates to:
  /// **'إعادة تعيين كلمة المرور'**
  String get resetPassword;

  /// No description provided for @changeCurrentAppPassword.
  ///
  /// In ar, this message translates to:
  /// **'قم بتغيير كلمة مرور التطبيق الحالية.'**
  String get changeCurrentAppPassword;

  /// No description provided for @lockAppNow.
  ///
  /// In ar, this message translates to:
  /// **'قفل التطبيق الآن'**
  String get lockAppNow;

  /// No description provided for @clearAllData.
  ///
  /// In ar, this message translates to:
  /// **'مسح جميع البيانات'**
  String get clearAllData;

  /// No description provided for @allDataWillBeDeletedForever.
  ///
  /// In ar, this message translates to:
  /// **'سيتم حذف كافة البيانات وكلمات المرور نهائياً.'**
  String get allDataWillBeDeletedForever;

  /// No description provided for @currentPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية'**
  String get currentPassword;

  /// No description provided for @newPassword.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الجديدة'**
  String get newPassword;

  /// No description provided for @passwordChangedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم تغيير كلمة المرور بنجاح'**
  String get passwordChangedSuccessfully;

  /// No description provided for @save.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get save;

  /// No description provided for @warningClearAllData.
  ///
  /// In ar, this message translates to:
  /// **'تحذير: مسح جميع البيانات'**
  String get warningClearAllData;

  /// No description provided for @confirmClearAllDataText.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد مسح كافة البيانات من التطبيق؟ هذا الإجراء لا يمكن التراجع عنه وسيتم تسجيل خروجك من التطبيق فوراً.'**
  String get confirmClearAllDataText;

  /// No description provided for @confirmClear.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد المسح'**
  String get confirmClear;

  /// No description provided for @appearanceAndLanguage.
  ///
  /// In ar, this message translates to:
  /// **'المظهر واللغة'**
  String get appearanceAndLanguage;

  /// No description provided for @security.
  ///
  /// In ar, this message translates to:
  /// **'الأمان والحماية'**
  String get security;

  /// No description provided for @dataAndSync.
  ///
  /// In ar, this message translates to:
  /// **'البيانات والمزامنة'**
  String get dataAndSync;

  /// No description provided for @autoUpdateImportedFiles.
  ///
  /// In ar, this message translates to:
  /// **'تحديث تلقائي للملفات المستوردة'**
  String get autoUpdateImportedFiles;

  /// No description provided for @checkForUpdatesOnStartup.
  ///
  /// In ar, this message translates to:
  /// **'فحص التحديثات عند بدء التطبيق'**
  String get checkForUpdatesOnStartup;

  /// No description provided for @scanWatchedFolders.
  ///
  /// In ar, this message translates to:
  /// **'فحص المجلدات المراقبة'**
  String get scanWatchedFolders;

  /// No description provided for @autoSearchNewFilesInFolders.
  ///
  /// In ar, this message translates to:
  /// **'البحث عن ملفات جديدة في المجلدات تلقائياً'**
  String get autoSearchNewFilesInFolders;

  /// No description provided for @addFolderToWatch.
  ///
  /// In ar, this message translates to:
  /// **'إضافة مجلد للمراقبة'**
  String get addFolderToWatch;

  /// No description provided for @advancedManagement.
  ///
  /// In ar, this message translates to:
  /// **'إدارة متقدمة'**
  String get advancedManagement;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور الحالية غير صحيحة'**
  String get currentPasswordIncorrect;

  /// No description provided for @english.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @designedBy.
  ///
  /// In ar, this message translates to:
  /// **'مُصَمم بمعرفة'**
  String get designedBy;

  /// No description provided for @ahmedElKilany.
  ///
  /// In ar, this message translates to:
  /// **'النقيب / أحمد الكيلاني'**
  String get ahmedElKilany;

  /// No description provided for @sortNewest.
  ///
  /// In ar, this message translates to:
  /// **'الأحدث'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In ar, this message translates to:
  /// **'الأقدم'**
  String get sortOldest;

  /// No description provided for @sortAlphabeticalAsc.
  ///
  /// In ar, this message translates to:
  /// **'أبجدياً (أ-ي)'**
  String get sortAlphabeticalAsc;

  /// No description provided for @sortAlphabeticalDesc.
  ///
  /// In ar, this message translates to:
  /// **'أبجدياً (ي-أ)'**
  String get sortAlphabeticalDesc;

  /// No description provided for @showAllData.
  ///
  /// In ar, this message translates to:
  /// **'عرض جميع البيانات'**
  String get showAllData;

  /// No description provided for @processedRecordsCount.
  ///
  /// In ar, this message translates to:
  /// **'تم معالجة: {count} سجل'**
  String processedRecordsCount(int count);

  /// No description provided for @chooseSpecificFiles.
  ///
  /// In ar, this message translates to:
  /// **'اختر ملفات محددة'**
  String get chooseSpecificFiles;

  /// No description provided for @chooseEntireFolder.
  ///
  /// In ar, this message translates to:
  /// **'اختر مجلد كامل'**
  String get chooseEntireFolder;

  /// No description provided for @errorOccurred.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ: {error}'**
  String errorOccurred(String error);

  /// No description provided for @filesSelected.
  ///
  /// In ar, this message translates to:
  /// **'تم اختيار {count} ملف(ات)'**
  String filesSelected(int count);

  /// No description provided for @rowNumber.
  ///
  /// In ar, this message translates to:
  /// **'الصف {number}'**
  String rowNumber(int number);

  /// No description provided for @stepReferenceRow.
  ///
  /// In ar, this message translates to:
  /// **'الصف المرجعي'**
  String get stepReferenceRow;

  /// No description provided for @stepColumnSelection.
  ///
  /// In ar, this message translates to:
  /// **'اختيار الأعمدة'**
  String get stepColumnSelection;

  /// No description provided for @stepReview.
  ///
  /// In ar, this message translates to:
  /// **'مراجعة'**
  String get stepReview;

  /// No description provided for @stepImporting.
  ///
  /// In ar, this message translates to:
  /// **'جاري الاستيراد'**
  String get stepImporting;

  /// No description provided for @autoUpdateSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم التحديث التلقائي بنجاح. أُضيف {count} سجل جديد.'**
  String autoUpdateSuccess(int count);

  /// No description provided for @autoUpdateError.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ أثناء التحديث التلقائي: {error}'**
  String autoUpdateError(String error);

  /// No description provided for @updateData.
  ///
  /// In ar, this message translates to:
  /// **'تحديث البيانات'**
  String get updateData;

  /// No description provided for @updateDataSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فحص الملفات المستوردة والمجلدات المراقبة بحثاً عن تحديثات'**
  String get updateDataSubtitle;

  /// No description provided for @exportingWait.
  ///
  /// In ar, this message translates to:
  /// **'جاري التصدير...'**
  String get exportingWait;

  /// No description provided for @scanningWait.
  ///
  /// In ar, this message translates to:
  /// **'جاري الفحص...'**
  String get scanningWait;

  /// No description provided for @pleaseWaitAndDoNotClose.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الانتظار ولا تغلق التطبيق'**
  String get pleaseWaitAndDoNotClose;

  /// No description provided for @chooseTimeRangeForExport.
  ///
  /// In ar, this message translates to:
  /// **'اختر النطاق الزمني للبيانات التي تريد تصديرها.'**
  String get chooseTimeRangeForExport;

  /// No description provided for @allData.
  ///
  /// In ar, this message translates to:
  /// **'كل البيانات'**
  String get allData;

  /// No description provided for @last24Hours.
  ///
  /// In ar, this message translates to:
  /// **'آخر ٢٤ ساعة'**
  String get last24Hours;

  /// No description provided for @last7Days.
  ///
  /// In ar, this message translates to:
  /// **'آخر ٧ أيام'**
  String get last7Days;

  /// No description provided for @customPeriod.
  ///
  /// In ar, this message translates to:
  /// **'فترة مخصصة'**
  String get customPeriod;

  /// No description provided for @chooseDates.
  ///
  /// In ar, this message translates to:
  /// **'اختر التواريخ'**
  String get chooseDates;

  /// No description provided for @pleaseSelectTimeRangeFirst.
  ///
  /// In ar, this message translates to:
  /// **'الرجاء اختيار فترة زمنية أولاً.'**
  String get pleaseSelectTimeRangeFirst;

  /// No description provided for @exportNow.
  ///
  /// In ar, this message translates to:
  /// **'تصدير الآن'**
  String get exportNow;

  /// No description provided for @importDataSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة بيانات جديدة من ملفات Excel'**
  String get importDataSubtitle;

  /// No description provided for @exportDataSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تصدير كافة البيانات المسجلة إلى ملف Excel'**
  String get exportDataSubtitle;

  /// No description provided for @recordCountAndDate.
  ///
  /// In ar, this message translates to:
  /// **'عدد السجلات: {count}\nالتاريخ: {date}'**
  String recordCountAndDate(int count, String date);

  /// No description provided for @confirmDeleteImportBatch.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف كافة السجلات التي تم استيرادها في ملف \"{fileName}\"؟\nهذا الإجراء لا يمكن التراجع عنه.'**
  String confirmDeleteImportBatch(String fileName);

  /// No description provided for @recordNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم السجل: {id}'**
  String recordNumber(int id);

  /// No description provided for @allDataExportedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير كافة البيانات بنجاح إلى: {path}'**
  String allDataExportedSuccess(String path);

  /// No description provided for @dataExportedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تم تصدير البيانات بنجاح إلى: {path}'**
  String dataExportedSuccess(String path);

  /// No description provided for @filtersAndSorting.
  ///
  /// In ar, this message translates to:
  /// **'التصفية والفرز'**
  String get filtersAndSorting;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
