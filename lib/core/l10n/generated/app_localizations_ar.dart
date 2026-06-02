// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'دكستر';

  @override
  String get incorrectPassword => 'كلمة المرور غير صحيحة';

  @override
  String get setupNewPassword => 'قم بإعداد كلمة مرور جديدة';

  @override
  String get enterPassword => 'أدخل كلمة المرور';

  @override
  String get password => 'كلمة المرور';

  @override
  String get saveAndStart => 'حفظ والبدء';

  @override
  String get login => 'دخول';

  @override
  String get setupProfileFirst =>
      'الرجاء إعداد ملف تعريف (Profile) أولاً لاستيراد البيانات.';

  @override
  String get manualEntry => 'إدخال يدوي';

  @override
  String get duplicateEntryWarning => 'تحذير: تم العثور على سجل مكرر!';

  @override
  String get saveAnyway => 'حفظ على أي حال';

  @override
  String get recordSavedSuccessfully => 'تم حفظ السجل بنجاح';

  @override
  String get saveRecord => 'حفظ السجل';

  @override
  String get noDataToExport => 'لا توجد بيانات للتصدير';

  @override
  String get failedToCreateFile => 'فشل إنشاء الملف';

  @override
  String get failedToSaveCheckPermissions =>
      'تعذر حفظ الملف. تحقق من الصلاحيات.';

  @override
  String get exportData => 'تصدير البيانات';

  @override
  String get exportDataDescription =>
      'سيتم تجميع وتصدير كافة البيانات من جميع ملفات التعريف في ملف إكسل واحد.';

  @override
  String get filterExportOptional => 'تصفية التصدير (اختياري)';

  @override
  String get exportAllAsExcel => 'تصدير كافة البيانات كملف Excel';

  @override
  String get importHistory => 'سجل الاستيراد';

  @override
  String get noImportHistory => 'لا يوجد سجل استيراد';

  @override
  String get undoImport => 'تراجع عن الاستيراد';

  @override
  String get confirmUndo => 'تأكيد التراجع';

  @override
  String get cancel => 'إلغاء';

  @override
  String get undoImportSuccess => 'تم التراجع عن الاستيراد بنجاح';

  @override
  String get confirmDelete => 'تأكيد الحذف';

  @override
  String get search => 'بحث';

  @override
  String get data => 'البيانات';

  @override
  String get settings => 'الإعدادات';

  @override
  String get importComplete => 'اكتمل الاستيراد';

  @override
  String get totalRecords => 'إجمالي السجلات:';

  @override
  String get importedRecords => 'تم استيراد:';

  @override
  String get skippedDuplicates => 'تم تخطي (مكرر):';

  @override
  String get recordsWithError => 'سجلات بها خطأ:';

  @override
  String get finish => 'إنهاء';

  @override
  String get importData => 'استيراد البيانات';

  @override
  String get chooseFileOrFolder => 'اختر الملف أو المجلد';

  @override
  String get files => 'ملفات';

  @override
  String get noExcelFilesFound => 'لم يتم العثور على ملفات إكسيل';

  @override
  String get folder => 'مجلد';

  @override
  String get headerRowNumber => 'رقم صف المرجع (العناوين):';

  @override
  String get next => 'التالي';

  @override
  String get selectColumns => 'تحديد الأعمدة';

  @override
  String get importAllFieldsAuto => 'استيراد كل الحقول تلقائياً';

  @override
  String get chooseColumns => 'اختيار الأعمدة:';

  @override
  String get none => 'لا يوجد';

  @override
  String get previous => 'السابق';

  @override
  String get dataPreview => 'معاينة البيانات';

  @override
  String get dataWillBeImportedAsFollows =>
      'سيتم استيراد البيانات بالشكل التالي بناءً على اختيارك:';

  @override
  String get sampleData => 'نموذج من البيانات...';

  @override
  String get looksCorrectStartImport => 'يبدو صحيحاً - ابدأ الاستيراد';

  @override
  String get importing => 'جاري الاستيراد...';

  @override
  String get searchResult => 'نتيجة البحث';

  @override
  String get searchTitle => 'البحث';

  @override
  String get searchForRecord => 'ابحث عن سجل...';

  @override
  String get matchType => 'نوع المطابقة:';

  @override
  String get exactMatch => 'بحث دقيق';

  @override
  String get containsMatch => 'بحث شامل';

  @override
  String get fuzzyMatch => 'بحث تقريبي';

  @override
  String get pleaseEnterDataToSearch => 'الرجاء إدخال بيانات للبحث';

  @override
  String get noResults => 'لا توجد نتائج';

  @override
  String get themeSettings => 'المظهر';

  @override
  String get system => 'النظام';

  @override
  String get light => 'فاتح';

  @override
  String get dark => 'داكن';

  @override
  String get languageSettings => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get autoLockSettings => 'القفل التلقائي';

  @override
  String get immediately => 'فوراً';

  @override
  String get oneMinute => 'دقيقة واحدة';

  @override
  String get fiveMinutes => '5 دقائق';

  @override
  String get never => 'أبداً';

  @override
  String get resetPassword => 'إعادة تعيين كلمة المرور';

  @override
  String get changeCurrentAppPassword => 'قم بتغيير كلمة مرور التطبيق الحالية.';

  @override
  String get lockAppNow => 'قفل التطبيق الآن';

  @override
  String get clearAllData => 'مسح جميع البيانات';

  @override
  String get allDataWillBeDeletedForever =>
      'سيتم حذف كافة البيانات وكلمات المرور نهائياً.';

  @override
  String get currentPassword => 'كلمة المرور الحالية';

  @override
  String get newPassword => 'كلمة المرور الجديدة';

  @override
  String get passwordChangedSuccessfully => 'تم تغيير كلمة المرور بنجاح';

  @override
  String get save => 'حفظ';

  @override
  String get warningClearAllData => 'تحذير: مسح جميع البيانات';

  @override
  String get confirmClearAllDataText =>
      'هل أنت متأكد أنك تريد مسح كافة البيانات من التطبيق؟ هذا الإجراء لا يمكن التراجع عنه وسيتم تسجيل خروجك من التطبيق فوراً.';

  @override
  String get confirmClear => 'تأكيد المسح';

  @override
  String get appearanceAndLanguage => 'المظهر واللغة';

  @override
  String get security => 'الأمان والحماية';

  @override
  String get dataAndSync => 'البيانات والمزامنة';

  @override
  String get autoUpdateImportedFiles => 'تحديث تلقائي للملفات المستوردة';

  @override
  String get checkForUpdatesOnStartup => 'فحص التحديثات عند بدء التطبيق';

  @override
  String get scanWatchedFolders => 'فحص المجلدات المراقبة';

  @override
  String get autoSearchNewFilesInFolders =>
      'البحث عن ملفات جديدة في المجلدات تلقائياً';

  @override
  String get addFolderToWatch => 'إضافة مجلد للمراقبة';

  @override
  String get advancedManagement => 'إدارة متقدمة';

  @override
  String get currentPasswordIncorrect => 'كلمة المرور الحالية غير صحيحة';

  @override
  String get english => 'English';

  @override
  String get designedBy => 'تم التصميم بواسطة';

  @override
  String get ahmedElKilany => 'النقيب / أحمد الكيلاني';

  @override
  String get sortNewest => 'الأحدث';

  @override
  String get sortOldest => 'الأقدم';

  @override
  String get sortAlphabeticalAsc => 'أبجدياً (أ-ي)';

  @override
  String get sortAlphabeticalDesc => 'أبجدياً (ي-أ)';

  @override
  String get showAllData => 'عرض جميع البيانات';

  @override
  String processedRecordsCount(int count) {
    return 'تم معالجة: $count سجل';
  }

  @override
  String get chooseSpecificFiles => 'اختر ملفات محددة';

  @override
  String get chooseEntireFolder => 'اختر مجلداً كاملاً';

  @override
  String errorOccurred(String error) {
    return 'حدث خطأ: $error';
  }

  @override
  String filesSelected(int count) {
    return 'تم اختيار $count ملف(ات)';
  }

  @override
  String rowNumber(int number) {
    return 'الصف $number';
  }

  @override
  String get stepReferenceRow => 'الصف المرجعي';

  @override
  String get stepColumnSelection => 'اختيار الأعمدة';

  @override
  String get stepReview => 'مراجعة';

  @override
  String get stepImporting => 'جاري الاستيراد...';

  @override
  String autoUpdateSuccess(int count) {
    return 'تم التحديث التلقائي بنجاح. أُضيف $count سجل جديد.';
  }

  @override
  String autoUpdateError(String error) {
    return 'حدث خطأ أثناء التحديث التلقائي: $error';
  }

  @override
  String get updateData => 'تحديث البيانات';

  @override
  String get updateDataSubtitle =>
      'فحص الملفات المستوردة والمجلدات المراقبة بحثاً عن تحديثات';

  @override
  String get exportingWait => 'جاري التصدير...';

  @override
  String get scanningWait => 'جاري الفحص...';

  @override
  String get pleaseWaitAndDoNotClose => 'يرجى الانتظار وعدم إغلاق التطبيق';

  @override
  String get chooseTimeRangeForExport =>
      'اختر النطاق الزمني للبيانات التي تريد تصديرها.';

  @override
  String get allData => 'كل البيانات';

  @override
  String get last24Hours => 'آخر 24 ساعة';

  @override
  String get last7Days => 'آخر 7 أيام';

  @override
  String get customPeriod => 'فترة مخصصة';

  @override
  String get chooseDates => 'اختر التواريخ';

  @override
  String get pleaseSelectTimeRangeFirst => 'الرجاء اختيار فترة زمنية أولاً.';

  @override
  String get exportNow => 'تصدير الآن';

  @override
  String get importDataSubtitle => 'إضافة بيانات جديدة من ملفات Excel';

  @override
  String get exportDataSubtitle => 'تصدير كافة البيانات المسجلة إلى ملف Excel';

  @override
  String recordCountAndDate(int count, String date) {
    return 'عدد السجلات: $count\nالتاريخ: $date';
  }

  @override
  String confirmDeleteImportBatch(String fileName) {
    return 'هل أنت متأكد أنك تريد حذف كافة السجلات المستوردة من الملف \"$fileName\"؟\nهذا الإجراء لا يمكن التراجع عنه.';
  }

  @override
  String recordNumber(int id) {
    return 'رقم السجل: $id';
  }

  @override
  String allDataExportedSuccess(String path) {
    return 'تم تصدير كافة البيانات بنجاح إلى: $path';
  }

  @override
  String dataExportedSuccess(String path) {
    return 'تم تصدير البيانات بنجاح إلى: $path';
  }

  @override
  String get filtersAndSorting => 'التصفية والفرز';

  @override
  String get hideData => 'إخفاء البيانات';

  @override
  String get manageIndexedFiles => 'إدارة الملفات المفهرسة';

  @override
  String get noIndexedFilesFound => 'لم يتم العثور على ملفات مفهرسة';

  @override
  String get delete => 'حذف';

  @override
  String deletedSuccessfully(String fileName) {
    return 'تم حذف $fileName بنجاح';
  }
}
