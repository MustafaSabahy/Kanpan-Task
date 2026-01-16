// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'تطبيق تتبع الوقت';

  @override
  String get board => 'اللوحة';

  @override
  String get history => 'السجل';

  @override
  String get statistics => 'الإحصائيات';

  @override
  String get toDo => 'المهام';

  @override
  String get inProgress => 'قيد التنفيذ';

  @override
  String get done => 'منتهي';

  @override
  String get newTask => 'مهمة جديدة';

  @override
  String get createNewTask => 'إنشاء مهمة جديدة';

  @override
  String get taskTitle => 'عنوان المهمة';

  @override
  String get enterTaskTitle => 'أدخل عنوان المهمة';

  @override
  String get description => 'الوصف';

  @override
  String get enterTaskDescription => 'أدخل وصف المهمة';

  @override
  String get create => 'إنشاء';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get editTask => 'تعديل المهمة';

  @override
  String get deleteTask => 'حذف المهمة';

  @override
  String get refresh => 'تحديث';

  @override
  String get enableDarkMode => 'تفعيل الوضع الداكن';

  @override
  String get disableDarkMode => 'تعطيل الوضع الداكن';

  @override
  String get clearAllTasks => 'حذف جميع المهام';

  @override
  String get clearTasksFromColumn => 'حذف المهام من العمود';

  @override
  String get areYouSureDeleteAll =>
      'هل أنت متأكد أنك تريد حذف جميع المهام؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get clearAll => 'حذف الكل';

  @override
  String get timeTracker => 'متتبع الوقت';

  @override
  String get timerRunning => 'العداد يعمل...';

  @override
  String get totalTimeSpent => 'إجمالي الوقت';

  @override
  String get startTimer => 'بدء العداد';

  @override
  String get stopTimer => 'إيقاف العداد';

  @override
  String get timerDisabledForCompleted => 'العداد معطل للمهام المكتملة';

  @override
  String get comments => 'التعليقات';

  @override
  String get addComment => 'أضف تعليقاً...';

  @override
  String get noCommentsYet => 'لا توجد تعليقات بعد';

  @override
  String get dropTaskHere => 'أسقط المهمة هنا';

  @override
  String get noTrackedTimeYet => 'لم يتم تتبع الوقت بعد';

  @override
  String get startTrackingTime => 'ابدأ في تتبع الوقت للمهام لرؤية الإحصائيات';

  @override
  String get overallSummary => 'الملخص العام';

  @override
  String get totalTime => 'إجمالي الوقت';

  @override
  String get completed => 'مكتمل';

  @override
  String get avgPerTask => 'المتوسط لكل مهمة';

  @override
  String get sessions => 'الجلسات';

  @override
  String get timeByStatus => 'الوقت حسب الحالة';

  @override
  String get timeByTask => 'الوقت حسب المهمة';

  @override
  String get timeOverTime => 'الوقت عبر الزمن';

  @override
  String get filters => 'المرشحات';

  @override
  String get dateRange => 'نطاق التاريخ';

  @override
  String get allDates => 'جميع التواريخ';

  @override
  String get task => 'المهمة';

  @override
  String get allTasks => 'جميع المهام';

  @override
  String get status => 'الحالة';

  @override
  String get allStatuses => 'جميع الحالات';

  @override
  String get selectTask => 'اختر المهمة';

  @override
  String get selectStatus => 'اختر الحالة';

  @override
  String get noDataMatchesFilters => 'لا توجد بيانات تطابق المرشحات';

  @override
  String get tryAdjustingFilters => 'حاول تعديل المرشحات لرؤية الإحصائيات';

  @override
  String get noTimeTrackedYet => 'لم يتم تتبع الوقت بعد';

  @override
  String get noTasksWithTrackedTime => 'لا توجد مهام مع وقت متتبع';

  @override
  String get noTimeDataAvailable => 'لا توجد بيانات وقت متاحة';

  @override
  String get timeHistory => 'سجل الوقت';

  @override
  String session(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count جلسات',
      one: 'جلسة واحدة',
    );
    return '$_temp0';
  }

  @override
  String get noTimeHistoryYet => 'لا يوجد سجل وقت بعد';

  @override
  String get started => 'بدأ';

  @override
  String get paused => 'متوقف';

  @override
  String get movedToTodo => 'نقل إلى المهام';

  @override
  String get reopened => 'إعادة فتح';

  @override
  String get resumedAfterRestart => 'استئناف بعد إعادة التشغيل';

  @override
  String get appClosed => 'تم إغلاق التطبيق';

  @override
  String get sessionLabel => 'جلسة';

  @override
  String get errorLoadingTasks => 'خطأ في تحميل المهام';

  @override
  String get errorLoadingHistory => 'خطأ في تحميل السجل';

  @override
  String get errorLoadingStatistics => 'خطأ في تحميل الإحصائيات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noCompletedTasksYet => 'لا توجد مهام مكتملة بعد';

  @override
  String get completeTasksToSee => 'أكمل المهام لرؤيتها هنا';

  @override
  String get timeSpent => 'الوقت المستغرق: ';

  @override
  String get searchTasks => 'البحث في المهام...';

  @override
  String get language => 'اللغة';

  @override
  String get selectLanguage => 'اختر اللغة';

  @override
  String get english => 'الإنجليزية';

  @override
  String get german => 'الألمانية';

  @override
  String get arabic => 'العربية';
}
