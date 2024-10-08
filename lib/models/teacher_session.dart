class TeacherSessionDetail {
  int id;
  String title;
  String videoCover;
  String videoUrl;
  dynamic aspectRatio;
  String documentUrl;
  bool active;
  String type;
  int videoId;
  int quizId;
  int documentId;
  String urlSource;
  String coverUrlSource;
  int duration;
  bool isQuizLimited;
  TeacherSessionDetail.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    videoCover = json['videoCover'];
    videoUrl = json['videoUrl'];
    try {
      aspectRatio = json['width'] / json['height'];
    } catch (e) {
      aspectRatio = 1.0;
    }

    documentUrl = json['documentUrl'];
    active = json['active'];
    type = json['type'];
    videoId = json['videoId'];
    quizId = json['quizId'];
    documentId = json['documentId'];
    urlSource = json['urlSource'];
    coverUrlSource = json['coverUrlSource'];
    duration = json['duration'];
    isQuizLimited = json['isQuizLimited'];
  }
}

class TeacherSession {
  int id;
  bool isFree;
  dynamic price;
  bool active;
  String lessonDescription;
  List<TeacherSessionDetail> teacherSessionDetails;
  TeacherSession.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    isFree = json['isFree'];
    price = json['price'];
    active = json['active'];
    lessonDescription = json['lessonDescription'];
    List<Object> sessionDetails = json['teacherSessionDetails'];
    teacherSessionDetails = [];
    sessionDetails.forEach((element) {
      teacherSessionDetails.add(TeacherSessionDetail.fromJson(element));
    });
  }
}
