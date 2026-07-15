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
  String get noExcelFilesFound => 'لم يتم العثور على ملفات إكسل أو CSV مدعومة';

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
  String get english => 'الإنجليزية';

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
  String get importDataSubtitle => 'إضافة بيانات جديدة من ملفات إكسل أو CSV';

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

  @override
  String get removePassword => 'إزالة كلمة المرور';

  @override
  String get removePasswordSubtitle => 'إزالة كلمة المرور من التطبيق بالكامل.';

  @override
  String get confirmRemovePassword =>
      'هل أنت متأكد أنك تريد إزالة كلمة المرور؟';

  @override
  String get passwordRemovedSuccessfully => 'تم إزالة كلمة المرور بنجاح';

  @override
  String get remove => 'إزالة';

  @override
  String get useFaceId => 'استخدام Face ID';

  @override
  String get useFingerprint => 'استخدام البصمة';

  @override
  String get faceId => 'Face ID';

  @override
  String get fingerprint => 'البصمة';

  @override
  String get useFaceIdToUnlock => 'استخدام Face ID للفتح';

  @override
  String get useFingerprintToUnlock => 'استخدام البصمة للفتح';

  @override
  String get viewAndDeleteSpecificFileRecords => 'عرض وحذف سجلات ملفات محددة';

  @override
  String get selectSheets => 'اختر الأوراق للاستيراد';

  @override
  String get scanForDuplicates => 'فحص التكرارات';

  @override
  String get findAndRemoveDuplicates => 'البحث وحذف السجلات المكررة';

  @override
  String get noDuplicatesFound => 'لا توجد سجلات مكررة!';

  @override
  String duplicatesFound(int count) {
    return 'تم العثور على $count مجموعة تكرار';
  }

  @override
  String get keepFirst => 'الاحتفاظ بالأول';

  @override
  String totalRedundantEntries(int count) {
    return 'إجمالي السجلات الزائدة: $count';
  }

  @override
  String copiesCount(int count) {
    return '$count نسخ';
  }

  @override
  String get keepBadge => 'احتفاظ';

  @override
  String get duplicateBadge => 'مكرر';

  @override
  String get payload => 'بيانات السجل';

  @override
  String get confirmDeleteDuplicateCopy =>
      'هل أنت متأكد أنك تريد حذف هذه النسخة المكررة؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get advancedFilters => 'فلاتر متقدمة';

  @override
  String get allFiles => 'جميع الملفات';

  @override
  String selectedFiles(int count) {
    return '$count ملف(ات) محددة';
  }

  @override
  String get fileScope => 'نطاق الملف';

  @override
  String get addFilter => 'إضافة فلتر';

  @override
  String get field => 'الحقل';

  @override
  String get operator => 'العملية';

  @override
  String get contains => 'يحتوي على';

  @override
  String get doesNotContain => 'لا يحتوي على';

  @override
  String get equalTo => 'يساوي';

  @override
  String get notEqualTo => 'لا يساوي';

  @override
  String get greaterThan => 'أكبر من';

  @override
  String get lessThan => 'أصغر من';

  @override
  String get betweenLabel => 'بين';

  @override
  String get copied => 'تم النسخ';

  @override
  String get copy => 'نسخ';

  @override
  String get selectAll => 'تحديد الكل';

  @override
  String get clear => 'مسح';

  @override
  String get manualEntriesOnly => 'الإدخالات اليدوية فقط';

  @override
  String get fieldRequired => 'هذا الحقل مطلوب';

  @override
  String get invalidFilterValue => 'أدخل قيمة صالحة لهذا الفلتر';

  @override
  String get discardChangesTitle => 'تجاهل التغييرات؟';

  @override
  String get discardChangesMessage =>
      'لديك بيانات غير محفوظة. هل تريد المغادرة دون حفظها؟';

  @override
  String get discard => 'تجاهل';

  @override
  String get secureStorageErrorTitle => 'التخزين الآمن غير متاح';

  @override
  String get secureStorageErrorMessage =>
      'تعذر على دكستر قراءة وحدة التخزين الآمنة. أعد تشغيل التطبيق أو تحقق من إعدادات أمان الجهاز قبل المتابعة.';

  @override
  String get authenticateToUnlock => 'استخدم المصادقة لفتح دكستر';

  @override
  String get authenticateToEnableBiometrics =>
      'استخدم المصادقة لتفعيل المصادقة الحيوية';

  @override
  String get passwordTooShort => 'يجب ألا تقل كلمة المرور عن 4 أحرف';

  @override
  String get showPassword => 'إظهار كلمة المرور';

  @override
  String get hidePassword => 'إخفاء كلمة المرور';

  @override
  String lockedOutSeconds(int seconds) {
    return 'محاولات فاشلة كثيرة. حاول مرة أخرى بعد $seconds ثانية.';
  }

  @override
  String get exportReady => 'التصدير جاهز';

  @override
  String get matchContains => 'يحتوي على';

  @override
  String get matchExact => 'مطابقة تامة';

  @override
  String get matchStartsWith => 'يبدأ بـ';

  @override
  String get matchFuzzy => 'مطابقة تقريبية';

  @override
  String get anyField => 'أي حقل';

  @override
  String get recordId => 'معرّف السجل';

  @override
  String get profileId => 'معرّف الملف التعريفي';

  @override
  String get sourceFile => 'الملف المصدر';

  @override
  String get importBatch => 'دفعة الاستيراد';

  @override
  String get createdAt => 'تاريخ الإنشاء';

  @override
  String get updatedAt => 'تاريخ التحديث';

  @override
  String get startsWith => 'يبدأ بـ';

  @override
  String get doesNotStartWith => 'لا يبدأ بـ';

  @override
  String get endsWith => 'ينتهي بـ';

  @override
  String get doesNotEndWith => 'لا ينتهي بـ';

  @override
  String get containsAllWords => 'يحتوي على كل الكلمات';

  @override
  String get containsAnyWord => 'يحتوي على أي كلمة';

  @override
  String get containsNoWords => 'لا يحتوي على أي من الكلمات';

  @override
  String get containsCaseSensitive => 'يحتوي على (مع مراعاة حالة الأحرف)';

  @override
  String get equalCaseSensitive => 'يساوي (مع مراعاة حالة الأحرف)';

  @override
  String get notEqualCaseSensitive => 'لا يساوي (مع مراعاة حالة الأحرف)';

  @override
  String get inList => 'موجود في القائمة';

  @override
  String get notInList => 'غير موجود في القائمة';

  @override
  String get greaterThanOrEqual => 'أكبر من أو يساوي';

  @override
  String get lessThanOrEqual => 'أصغر من أو يساوي';

  @override
  String get notBetween => 'ليس بين';

  @override
  String get isNumeric => 'قيمة رقمية';

  @override
  String get isNotNumeric => 'قيمة غير رقمية';

  @override
  String get dateBefore => 'التاريخ قبل';

  @override
  String get dateAfter => 'التاريخ بعد';

  @override
  String get dateIs => 'التاريخ يوافق';

  @override
  String get dateIsNot => 'التاريخ لا يوافق';

  @override
  String get dateBetween => 'التاريخ بين';

  @override
  String get dateToday => 'التاريخ هو اليوم';

  @override
  String get dateInLastDays => 'التاريخ ضمن الأيام الأخيرة';

  @override
  String get lengthEqual => 'الطول يساوي';

  @override
  String get lengthGreaterThan => 'الطول أكبر من';

  @override
  String get lengthLessThan => 'الطول أصغر من';

  @override
  String get lengthBetween => 'الطول بين';

  @override
  String get fieldExists => 'الحقل موجود';

  @override
  String get fieldMissing => 'الحقل غير موجود';

  @override
  String get isEmpty => 'فارغ';

  @override
  String get isNotEmpty => 'غير فارغ';

  @override
  String get valueLabel => 'القيمة';

  @override
  String get minValue => 'القيمة الصغرى';

  @override
  String get maxValue => 'القيمة الكبرى';

  @override
  String get dateLabel => 'التاريخ';

  @override
  String get startDate => 'تاريخ البداية';

  @override
  String get endDate => 'تاريخ النهاية';

  @override
  String get characters => 'عدد الأحرف';

  @override
  String get minCharacters => 'الحد الأدنى للأحرف';

  @override
  String get maxCharacters => 'الحد الأقصى للأحرف';

  @override
  String get days => 'الأيام';

  @override
  String get separateWordsWithSpaces => 'افصل الكلمات بمسافات';

  @override
  String get listValueHint =>
      'افصل العناصر بفواصل أو فاصلة منقوطة أو أسطر جديدة';

  @override
  String get dateFormatHint => 'سنة-شهر-يوم';

  @override
  String get pickDate => 'اختر التاريخ';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get statisticsSubtitle => 'استكشف اتجاهات البيانات المفهرسة وتوزيعها';

  @override
  String get last30Days => 'آخر 30 يوماً';

  @override
  String get allTime => 'كل الوقت';

  @override
  String get manualRecords => 'السجلات اليدوية';

  @override
  String get indexedFiles => 'الملفات المفهرسة';

  @override
  String get profiles => 'الملفات التعريفية';

  @override
  String get recordsOverTime => 'السجلات عبر الزمن';

  @override
  String get breakdown => 'التوزيع';

  @override
  String get bySourceFile => 'حسب الملف المصدر';

  @override
  String get byProfile => 'حسب الملف التعريفي';

  @override
  String get noStatisticsData => 'لا توجد بيانات متاحة لهذه الفترة';

  @override
  String get manualSource => 'إدخالات يدوية';

  @override
  String recordsCount(int count) {
    return '$count سجل';
  }

  @override
  String get refresh => 'تحديث';

  @override
  String get timeRange => 'النطاق الزمني';

  @override
  String get noIndexedSourceFilesFound => 'لا توجد ملفات مصدر مفهرسة';

  @override
  String get scanningDuplicateEntries => 'جارٍ فحص السجلات المكررة...';

  @override
  String settingsLoadError(String error) {
    return 'تعذر تحميل الإعدادات: $error';
  }

  @override
  String importCount(int count) {
    return '$count عملية استيراد';
  }
}
