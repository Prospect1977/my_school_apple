class Lesson {
  int lessonId;
  String lessonName;
  String lessonDescription;
  String parentLessonName;
  String dir;
  DateTime dataDate;
  String subjectName;
  int sessionsCount;
  int yearSubjectId;
  dynamic studentCompleted;
  Lesson.fromJson(Map<String, dynamic> js) {
    lessonId = js["lessonId"];
    lessonName = js["lessonName"];
    lessonDescription = js["lessonDescription"];
    parentLessonName = js["parentLessonName"];
    dir = js["dir"];
    dataDate = DateTime.parse(js["dataDate"]);
    subjectName = js["subjectName"];
    sessionsCount = js["sessionsCount"];
    yearSubjectId = js["yearSubjectId"];
    studentCompleted = js["studentCompleted"];
  }
}

class DailyScheduleItem {
  DateTime dataDate;
  bool isHoliday;
  String holidayName;
  String holidayImage;
  List<Lesson> lessons = [];
  DailyScheduleItem.fromJson(Map<String, dynamic> js) {
    dataDate = DateTime.parse(js["dataDate"]);
    isHoliday = js["isHoliday"];
    holidayName = js["holidayName"];
    holidayImage = js["holidayImage"];

    js['lessons'].forEach((l) {
      lessons.add(Lesson.fromJson(l));
    });
  }
}

class DailySchedule {
  List<DailyScheduleItem> items = [];
  DailySchedule.fromJson(List<Object> js) {
    js.forEach((d) {
      items.add(DailyScheduleItem.fromJson(d));
    });
  }
}
