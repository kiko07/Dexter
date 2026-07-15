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
  /// **'تصفية التصدير (اختياري)'**
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
  /// **'لم يتم العثور على ملفات إكسل أو CSV مدعومة'**
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
  /// **'اختيار الأعمدة:'**
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
  /// **'نموذج من البيانات...'**
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
  /// **'بحث تقريبي'**
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
  /// **'المظهر'**
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
  /// **'اللغة'**
  String get languageSettings;

  /// No description provided for @arabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @autoLockSettings.
  ///
  /// In ar, this message translates to:
  /// **'القفل التلقائي'**
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
  /// **'الإنجليزية'**
  String get english;

  /// No description provided for @designedBy.
  ///
  /// In ar, this message translates to:
  /// **'تم التصميم بواسطة'**
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
  /// **'اختر مجلداً كاملاً'**
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
  /// **'جاري الاستيراد...'**
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
  /// **'يرجى الانتظار وعدم إغلاق التطبيق'**
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
  /// **'آخر 24 ساعة'**
  String get last24Hours;

  /// No description provided for @last7Days.
  ///
  /// In ar, this message translates to:
  /// **'آخر 7 أيام'**
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
  /// **'إضافة بيانات جديدة من ملفات إكسل أو CSV'**
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
  /// **'هل أنت متأكد أنك تريد حذف كافة السجلات المستوردة من الملف \"{fileName}\"؟\nهذا الإجراء لا يمكن التراجع عنه.'**
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

  /// No description provided for @hideData.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء البيانات'**
  String get hideData;

  /// No description provided for @manageIndexedFiles.
  ///
  /// In ar, this message translates to:
  /// **'إدارة الملفات المفهرسة'**
  String get manageIndexedFiles;

  /// No description provided for @noIndexedFilesFound.
  ///
  /// In ar, this message translates to:
  /// **'لم يتم العثور على ملفات مفهرسة'**
  String get noIndexedFilesFound;

  /// No description provided for @delete.
  ///
  /// In ar, this message translates to:
  /// **'حذف'**
  String get delete;

  /// No description provided for @deletedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم حذف {fileName} بنجاح'**
  String deletedSuccessfully(String fileName);

  /// No description provided for @removePassword.
  ///
  /// In ar, this message translates to:
  /// **'إزالة كلمة المرور'**
  String get removePassword;

  /// No description provided for @removePasswordSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'إزالة كلمة المرور من التطبيق بالكامل.'**
  String get removePasswordSubtitle;

  /// No description provided for @confirmRemovePassword.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد إزالة كلمة المرور؟'**
  String get confirmRemovePassword;

  /// No description provided for @passwordRemovedSuccessfully.
  ///
  /// In ar, this message translates to:
  /// **'تم إزالة كلمة المرور بنجاح'**
  String get passwordRemovedSuccessfully;

  /// No description provided for @remove.
  ///
  /// In ar, this message translates to:
  /// **'إزالة'**
  String get remove;

  /// No description provided for @useFaceId.
  ///
  /// In ar, this message translates to:
  /// **'استخدام Face ID'**
  String get useFaceId;

  /// No description provided for @useFingerprint.
  ///
  /// In ar, this message translates to:
  /// **'استخدام البصمة'**
  String get useFingerprint;

  /// No description provided for @faceId.
  ///
  /// In ar, this message translates to:
  /// **'Face ID'**
  String get faceId;

  /// No description provided for @fingerprint.
  ///
  /// In ar, this message translates to:
  /// **'البصمة'**
  String get fingerprint;

  /// No description provided for @useFaceIdToUnlock.
  ///
  /// In ar, this message translates to:
  /// **'استخدام Face ID للفتح'**
  String get useFaceIdToUnlock;

  /// No description provided for @useFingerprintToUnlock.
  ///
  /// In ar, this message translates to:
  /// **'استخدام البصمة للفتح'**
  String get useFingerprintToUnlock;

  /// No description provided for @viewAndDeleteSpecificFileRecords.
  ///
  /// In ar, this message translates to:
  /// **'عرض وحذف سجلات ملفات محددة'**
  String get viewAndDeleteSpecificFileRecords;

  /// No description provided for @selectSheets.
  ///
  /// In ar, this message translates to:
  /// **'اختر الأوراق للاستيراد'**
  String get selectSheets;

  /// No description provided for @scanForDuplicates.
  ///
  /// In ar, this message translates to:
  /// **'فحص التكرارات'**
  String get scanForDuplicates;

  /// No description provided for @findAndRemoveDuplicates.
  ///
  /// In ar, this message translates to:
  /// **'البحث وحذف السجلات المكررة'**
  String get findAndRemoveDuplicates;

  /// No description provided for @noDuplicatesFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد سجلات مكررة!'**
  String get noDuplicatesFound;

  /// No description provided for @duplicatesFound.
  ///
  /// In ar, this message translates to:
  /// **'تم العثور على {count} مجموعة تكرار'**
  String duplicatesFound(int count);

  /// No description provided for @keepFirst.
  ///
  /// In ar, this message translates to:
  /// **'الاحتفاظ بالأول'**
  String get keepFirst;

  /// No description provided for @totalRedundantEntries.
  ///
  /// In ar, this message translates to:
  /// **'إجمالي السجلات الزائدة: {count}'**
  String totalRedundantEntries(int count);

  /// No description provided for @copiesCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} نسخ'**
  String copiesCount(int count);

  /// No description provided for @keepBadge.
  ///
  /// In ar, this message translates to:
  /// **'احتفاظ'**
  String get keepBadge;

  /// No description provided for @duplicateBadge.
  ///
  /// In ar, this message translates to:
  /// **'مكرر'**
  String get duplicateBadge;

  /// No description provided for @payload.
  ///
  /// In ar, this message translates to:
  /// **'بيانات السجل'**
  String get payload;

  /// No description provided for @confirmDeleteDuplicateCopy.
  ///
  /// In ar, this message translates to:
  /// **'هل أنت متأكد أنك تريد حذف هذه النسخة المكررة؟ لا يمكن التراجع عن هذا الإجراء.'**
  String get confirmDeleteDuplicateCopy;

  /// No description provided for @advancedFilters.
  ///
  /// In ar, this message translates to:
  /// **'فلاتر متقدمة'**
  String get advancedFilters;

  /// No description provided for @allFiles.
  ///
  /// In ar, this message translates to:
  /// **'جميع الملفات'**
  String get allFiles;

  /// No description provided for @selectedFiles.
  ///
  /// In ar, this message translates to:
  /// **'{count} ملف(ات) محددة'**
  String selectedFiles(int count);

  /// No description provided for @fileScope.
  ///
  /// In ar, this message translates to:
  /// **'نطاق الملف'**
  String get fileScope;

  /// No description provided for @addFilter.
  ///
  /// In ar, this message translates to:
  /// **'إضافة فلتر'**
  String get addFilter;

  /// No description provided for @field.
  ///
  /// In ar, this message translates to:
  /// **'الحقل'**
  String get field;

  /// No description provided for @operator.
  ///
  /// In ar, this message translates to:
  /// **'العملية'**
  String get operator;

  /// No description provided for @contains.
  ///
  /// In ar, this message translates to:
  /// **'يحتوي على'**
  String get contains;

  /// No description provided for @doesNotContain.
  ///
  /// In ar, this message translates to:
  /// **'لا يحتوي على'**
  String get doesNotContain;

  /// No description provided for @equalTo.
  ///
  /// In ar, this message translates to:
  /// **'يساوي'**
  String get equalTo;

  /// No description provided for @notEqualTo.
  ///
  /// In ar, this message translates to:
  /// **'لا يساوي'**
  String get notEqualTo;

  /// No description provided for @greaterThan.
  ///
  /// In ar, this message translates to:
  /// **'أكبر من'**
  String get greaterThan;

  /// No description provided for @lessThan.
  ///
  /// In ar, this message translates to:
  /// **'أصغر من'**
  String get lessThan;

  /// No description provided for @betweenLabel.
  ///
  /// In ar, this message translates to:
  /// **'بين'**
  String get betweenLabel;

  /// No description provided for @copied.
  ///
  /// In ar, this message translates to:
  /// **'تم النسخ'**
  String get copied;

  /// No description provided for @copy.
  ///
  /// In ar, this message translates to:
  /// **'نسخ'**
  String get copy;

  /// No description provided for @selectAll.
  ///
  /// In ar, this message translates to:
  /// **'تحديد الكل'**
  String get selectAll;

  /// No description provided for @clear.
  ///
  /// In ar, this message translates to:
  /// **'مسح'**
  String get clear;

  /// No description provided for @manualEntriesOnly.
  ///
  /// In ar, this message translates to:
  /// **'الإدخالات اليدوية فقط'**
  String get manualEntriesOnly;

  /// No description provided for @fieldRequired.
  ///
  /// In ar, this message translates to:
  /// **'هذا الحقل مطلوب'**
  String get fieldRequired;

  /// No description provided for @invalidFilterValue.
  ///
  /// In ar, this message translates to:
  /// **'أدخل قيمة صالحة لهذا الفلتر'**
  String get invalidFilterValue;

  /// No description provided for @discardChangesTitle.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل التغييرات؟'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesMessage.
  ///
  /// In ar, this message translates to:
  /// **'لديك بيانات غير محفوظة. هل تريد المغادرة دون حفظها؟'**
  String get discardChangesMessage;

  /// No description provided for @discard.
  ///
  /// In ar, this message translates to:
  /// **'تجاهل'**
  String get discard;

  /// No description provided for @secureStorageErrorTitle.
  ///
  /// In ar, this message translates to:
  /// **'التخزين الآمن غير متاح'**
  String get secureStorageErrorTitle;

  /// No description provided for @secureStorageErrorMessage.
  ///
  /// In ar, this message translates to:
  /// **'تعذر على دكستر قراءة وحدة التخزين الآمنة. أعد تشغيل التطبيق أو تحقق من إعدادات أمان الجهاز قبل المتابعة.'**
  String get secureStorageErrorMessage;

  /// No description provided for @authenticateToUnlock.
  ///
  /// In ar, this message translates to:
  /// **'استخدم المصادقة لفتح دكستر'**
  String get authenticateToUnlock;

  /// No description provided for @authenticateToEnableBiometrics.
  ///
  /// In ar, this message translates to:
  /// **'استخدم المصادقة لتفعيل المصادقة الحيوية'**
  String get authenticateToEnableBiometrics;

  /// No description provided for @passwordTooShort.
  ///
  /// In ar, this message translates to:
  /// **'يجب ألا تقل كلمة المرور عن 4 أحرف'**
  String get passwordTooShort;

  /// No description provided for @showPassword.
  ///
  /// In ar, this message translates to:
  /// **'إظهار كلمة المرور'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In ar, this message translates to:
  /// **'إخفاء كلمة المرور'**
  String get hidePassword;

  /// No description provided for @lockedOutSeconds.
  ///
  /// In ar, this message translates to:
  /// **'محاولات فاشلة كثيرة. حاول مرة أخرى بعد {seconds} ثانية.'**
  String lockedOutSeconds(int seconds);

  /// No description provided for @exportReady.
  ///
  /// In ar, this message translates to:
  /// **'التصدير جاهز'**
  String get exportReady;

  /// No description provided for @matchContains.
  ///
  /// In ar, this message translates to:
  /// **'يحتوي على'**
  String get matchContains;

  /// No description provided for @matchExact.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة تامة'**
  String get matchExact;

  /// No description provided for @matchStartsWith.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ بـ'**
  String get matchStartsWith;

  /// No description provided for @matchFuzzy.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة تقريبية'**
  String get matchFuzzy;

  /// No description provided for @anyField.
  ///
  /// In ar, this message translates to:
  /// **'أي حقل'**
  String get anyField;

  /// No description provided for @recordId.
  ///
  /// In ar, this message translates to:
  /// **'معرّف السجل'**
  String get recordId;

  /// No description provided for @profileId.
  ///
  /// In ar, this message translates to:
  /// **'معرّف الملف التعريفي'**
  String get profileId;

  /// No description provided for @sourceFile.
  ///
  /// In ar, this message translates to:
  /// **'الملف المصدر'**
  String get sourceFile;

  /// No description provided for @importBatch.
  ///
  /// In ar, this message translates to:
  /// **'دفعة الاستيراد'**
  String get importBatch;

  /// No description provided for @createdAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ الإنشاء'**
  String get createdAt;

  /// No description provided for @updatedAt.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ التحديث'**
  String get updatedAt;

  /// No description provided for @startsWith.
  ///
  /// In ar, this message translates to:
  /// **'يبدأ بـ'**
  String get startsWith;

  /// No description provided for @doesNotStartWith.
  ///
  /// In ar, this message translates to:
  /// **'لا يبدأ بـ'**
  String get doesNotStartWith;

  /// No description provided for @endsWith.
  ///
  /// In ar, this message translates to:
  /// **'ينتهي بـ'**
  String get endsWith;

  /// No description provided for @doesNotEndWith.
  ///
  /// In ar, this message translates to:
  /// **'لا ينتهي بـ'**
  String get doesNotEndWith;

  /// No description provided for @containsAllWords.
  ///
  /// In ar, this message translates to:
  /// **'يحتوي على كل الكلمات'**
  String get containsAllWords;

  /// No description provided for @containsAnyWord.
  ///
  /// In ar, this message translates to:
  /// **'يحتوي على أي كلمة'**
  String get containsAnyWord;

  /// No description provided for @containsNoWords.
  ///
  /// In ar, this message translates to:
  /// **'لا يحتوي على أي من الكلمات'**
  String get containsNoWords;

  /// No description provided for @containsCaseSensitive.
  ///
  /// In ar, this message translates to:
  /// **'يحتوي على (مع مراعاة حالة الأحرف)'**
  String get containsCaseSensitive;

  /// No description provided for @equalCaseSensitive.
  ///
  /// In ar, this message translates to:
  /// **'يساوي (مع مراعاة حالة الأحرف)'**
  String get equalCaseSensitive;

  /// No description provided for @notEqualCaseSensitive.
  ///
  /// In ar, this message translates to:
  /// **'لا يساوي (مع مراعاة حالة الأحرف)'**
  String get notEqualCaseSensitive;

  /// No description provided for @inList.
  ///
  /// In ar, this message translates to:
  /// **'موجود في القائمة'**
  String get inList;

  /// No description provided for @notInList.
  ///
  /// In ar, this message translates to:
  /// **'غير موجود في القائمة'**
  String get notInList;

  /// No description provided for @greaterThanOrEqual.
  ///
  /// In ar, this message translates to:
  /// **'أكبر من أو يساوي'**
  String get greaterThanOrEqual;

  /// No description provided for @lessThanOrEqual.
  ///
  /// In ar, this message translates to:
  /// **'أصغر من أو يساوي'**
  String get lessThanOrEqual;

  /// No description provided for @notBetween.
  ///
  /// In ar, this message translates to:
  /// **'ليس بين'**
  String get notBetween;

  /// No description provided for @isNumeric.
  ///
  /// In ar, this message translates to:
  /// **'قيمة رقمية'**
  String get isNumeric;

  /// No description provided for @isNotNumeric.
  ///
  /// In ar, this message translates to:
  /// **'قيمة غير رقمية'**
  String get isNotNumeric;

  /// No description provided for @dateBefore.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ قبل'**
  String get dateBefore;

  /// No description provided for @dateAfter.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ بعد'**
  String get dateAfter;

  /// No description provided for @dateIs.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ يوافق'**
  String get dateIs;

  /// No description provided for @dateIsNot.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ لا يوافق'**
  String get dateIsNot;

  /// No description provided for @dateBetween.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ بين'**
  String get dateBetween;

  /// No description provided for @dateToday.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ هو اليوم'**
  String get dateToday;

  /// No description provided for @dateInLastDays.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ ضمن الأيام الأخيرة'**
  String get dateInLastDays;

  /// No description provided for @lengthEqual.
  ///
  /// In ar, this message translates to:
  /// **'الطول يساوي'**
  String get lengthEqual;

  /// No description provided for @lengthGreaterThan.
  ///
  /// In ar, this message translates to:
  /// **'الطول أكبر من'**
  String get lengthGreaterThan;

  /// No description provided for @lengthLessThan.
  ///
  /// In ar, this message translates to:
  /// **'الطول أصغر من'**
  String get lengthLessThan;

  /// No description provided for @lengthBetween.
  ///
  /// In ar, this message translates to:
  /// **'الطول بين'**
  String get lengthBetween;

  /// No description provided for @fieldExists.
  ///
  /// In ar, this message translates to:
  /// **'الحقل موجود'**
  String get fieldExists;

  /// No description provided for @fieldMissing.
  ///
  /// In ar, this message translates to:
  /// **'الحقل غير موجود'**
  String get fieldMissing;

  /// No description provided for @isEmpty.
  ///
  /// In ar, this message translates to:
  /// **'فارغ'**
  String get isEmpty;

  /// No description provided for @isNotEmpty.
  ///
  /// In ar, this message translates to:
  /// **'غير فارغ'**
  String get isNotEmpty;

  /// No description provided for @valueLabel.
  ///
  /// In ar, this message translates to:
  /// **'القيمة'**
  String get valueLabel;

  /// No description provided for @minValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة الصغرى'**
  String get minValue;

  /// No description provided for @maxValue.
  ///
  /// In ar, this message translates to:
  /// **'القيمة الكبرى'**
  String get maxValue;

  /// No description provided for @dateLabel.
  ///
  /// In ar, this message translates to:
  /// **'التاريخ'**
  String get dateLabel;

  /// No description provided for @startDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ البداية'**
  String get startDate;

  /// No description provided for @endDate.
  ///
  /// In ar, this message translates to:
  /// **'تاريخ النهاية'**
  String get endDate;

  /// No description provided for @characters.
  ///
  /// In ar, this message translates to:
  /// **'عدد الأحرف'**
  String get characters;

  /// No description provided for @minCharacters.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأدنى للأحرف'**
  String get minCharacters;

  /// No description provided for @maxCharacters.
  ///
  /// In ar, this message translates to:
  /// **'الحد الأقصى للأحرف'**
  String get maxCharacters;

  /// No description provided for @days.
  ///
  /// In ar, this message translates to:
  /// **'الأيام'**
  String get days;

  /// No description provided for @separateWordsWithSpaces.
  ///
  /// In ar, this message translates to:
  /// **'افصل الكلمات بمسافات'**
  String get separateWordsWithSpaces;

  /// No description provided for @listValueHint.
  ///
  /// In ar, this message translates to:
  /// **'افصل العناصر بفواصل أو فاصلة منقوطة أو أسطر جديدة'**
  String get listValueHint;

  /// No description provided for @dateFormatHint.
  ///
  /// In ar, this message translates to:
  /// **'سنة-شهر-يوم'**
  String get dateFormatHint;

  /// No description provided for @pickDate.
  ///
  /// In ar, this message translates to:
  /// **'اختر التاريخ'**
  String get pickDate;

  /// No description provided for @statistics.
  ///
  /// In ar, this message translates to:
  /// **'الإحصائيات'**
  String get statistics;

  /// No description provided for @statisticsSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استكشف اتجاهات البيانات المفهرسة وتوزيعها'**
  String get statisticsSubtitle;

  /// No description provided for @last30Days.
  ///
  /// In ar, this message translates to:
  /// **'آخر 30 يوماً'**
  String get last30Days;

  /// No description provided for @allTime.
  ///
  /// In ar, this message translates to:
  /// **'كل الوقت'**
  String get allTime;

  /// No description provided for @manualRecords.
  ///
  /// In ar, this message translates to:
  /// **'السجلات اليدوية'**
  String get manualRecords;

  /// No description provided for @indexedFiles.
  ///
  /// In ar, this message translates to:
  /// **'الملفات المفهرسة'**
  String get indexedFiles;

  /// No description provided for @profiles.
  ///
  /// In ar, this message translates to:
  /// **'الملفات التعريفية'**
  String get profiles;

  /// No description provided for @recordsOverTime.
  ///
  /// In ar, this message translates to:
  /// **'السجلات عبر الزمن'**
  String get recordsOverTime;

  /// No description provided for @breakdown.
  ///
  /// In ar, this message translates to:
  /// **'التوزيع'**
  String get breakdown;

  /// No description provided for @bySourceFile.
  ///
  /// In ar, this message translates to:
  /// **'حسب الملف المصدر'**
  String get bySourceFile;

  /// No description provided for @byProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسب الملف التعريفي'**
  String get byProfile;

  /// No description provided for @noStatisticsData.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد بيانات متاحة لهذه الفترة'**
  String get noStatisticsData;

  /// No description provided for @manualSource.
  ///
  /// In ar, this message translates to:
  /// **'إدخالات يدوية'**
  String get manualSource;

  /// No description provided for @recordsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} سجل'**
  String recordsCount(int count);

  /// No description provided for @refresh.
  ///
  /// In ar, this message translates to:
  /// **'تحديث'**
  String get refresh;

  /// No description provided for @timeRange.
  ///
  /// In ar, this message translates to:
  /// **'النطاق الزمني'**
  String get timeRange;

  /// No description provided for @noIndexedSourceFilesFound.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد ملفات مصدر مفهرسة'**
  String get noIndexedSourceFilesFound;

  /// No description provided for @scanningDuplicateEntries.
  ///
  /// In ar, this message translates to:
  /// **'جارٍ فحص السجلات المكررة...'**
  String get scanningDuplicateEntries;

  /// No description provided for @settingsLoadError.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل الإعدادات: {error}'**
  String settingsLoadError(String error);

  /// No description provided for @importCount.
  ///
  /// In ar, this message translates to:
  /// **'{count} عملية استيراد'**
  String importCount(int count);
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
