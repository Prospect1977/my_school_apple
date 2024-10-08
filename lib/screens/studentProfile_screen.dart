import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_school/cubits/StudentYearOfStudy_cubit.dart';

import 'package:my_school/cubits/StudentYearOfStudy_states.dart';
import 'package:my_school/models/SchoolTypeYearOfStudy.dart' as sc;
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/studentDashboard_screen.dart';
import 'package:my_school/screens/studentSelectedSubjects_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/styles/colors.dart';

import '../models/SchoolTypeYearOfStudy.dart';
import '../shared/components/functions.dart';
import '../shared/dio_helper.dart';

class StudentProfileScreen extends StatefulWidget {
  final int Id;
  String FullName;
  String Gender;
  int YearOfStudyId;
  int SchoolTypeId;
  String lang = CacheHelper.getData(key: "lang");
  String SchoolTypeName;
  StudentProfileScreen(this.Id,
      {@required this.FullName,
      this.Gender,
      this.YearOfStudyId,
      this.SchoolTypeId});
  List<sc.SchoolType> SchoolTypes = null;

  List<sc.YearOfStudy> YearsOfStudies = null;
  List<sc.YearOfStudy> FilterdYearsOfStudies = null;
  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  List<DropdownMenuItem> SchoolTypesItems;
  List<DropdownMenuItem> YearsOfStudiesItems;
  var formKey = GlobalKey<FormState>();
  var dirty = false;
  void StudyYearsBySchoolTypeId(int SchoolTypeId) {
    setState(() {
      widget.FilterdYearsOfStudies = [...widget.YearsOfStudies]
          .where((e) => e.SchoolTypeId == SchoolTypeId)
          .toList();
      YearsOfStudiesItems = SchoolTypeId == 0
          ? []
          : widget.FilterdYearsOfStudies.map((y) => DropdownMenuItem(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: Colors.white))),
                  alignment: widget.lang == "en"
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  child: Text(
                    widget.lang == "en" ? y.YearOfStudyEng : y.YearOfStudyAra,
                  ),
                ),
                value: y.YearOfStudyId,
              )).toList();
    });
  }

  List<SchoolType> SchoolTypes;
  List<YearOfStudy> YearsOfStudies;
  var lang = CacheHelper.getData(key: "lang");
  var token = CacheHelper.getData(key: "token");
  List<int> test;
  void getData() {
    DioHelper.getData(
            url: 'SchoolTypeYearOfStudy', query: {}, lang: lang, token: token)
        .then((value) {
      print(value.data["schoolTypes"]);
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      setState(() {
        SchoolTypes =
            SchoolTypesAndYearsOfStudies.fromJson(value.data).SchoolTypes;
        SchoolTypes =
            SchoolTypes.where((element) => element.SortIndex < 3).toList();
        YearsOfStudies =
            SchoolTypesAndYearsOfStudies.fromJson(value.data).YearsOfStudies;
        SchoolTypesItems = SchoolTypes.map((t) => DropdownMenuItem(
              child: Container(
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.white))),
                alignment: widget.lang == "en"
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                child: Text(
                  widget.lang == "en" ? t.NameEng : t.NameAra,
                ),
              ),
              value: t.Id,
            )).toList();
        //FullNameField.text = widget.FullName;
        widget.SchoolTypes = SchoolTypes;
        widget.YearsOfStudies = YearsOfStudies;
        if (widget.SchoolTypeId != null) {
          StudyYearsBySchoolTypeId(widget.SchoolTypeId);
        } else {
          YearsOfStudiesItems = [];
        }
        test = SchoolTypes.map((e) => e.Id).toList();
      });
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  bool IsSaving = false;

  void saveData(context, int id, String gender, String fullName,
      int schoolTypeId, int YearOfStudyId) {
    setState(() {
      IsSaving = true;
    });
    DioHelper.postData(
        url: 'SchoolTypeYearOfStudy',
        query: {},
        lang: lang,
        token: token,
        data: {
          "id": id,
          "gender": gender,
          "fullName": fullName,
          "schoolTypeId": schoolTypeId,
          "yearOfStudyId": YearOfStudyId
        }).then((value) {
      print(value.data);
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      }
      CacheHelper.removeData(key: 'studentData');
      CacheHelper.removeData(key: 'studentsList');
      if (value.data["status"] == true) {
        showToast(
            text:
                lang == "en" ? "Saved Successfully!" : "تم حفظ الإعدادات بنجاح",
            state: ToastStates.SUCCESS);
        // setState(() {
        //   IsSaving = false;
        // });
      } else {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
      }
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController FullNameField;
    return Scaffold(
        appBar: appBarComponent(context,
            widget.lang == "en" ? "Profile Settings" : "إعدادات الحساب",
            backButtonPage: StudentDashboardScreen(
              Id: widget.Id,
              FullName: widget.FullName,
              Gender: widget.Gender,
              SchoolTypeId: widget.SchoolTypeId,
              YearOfStudyId: widget.YearOfStudyId,
            )),
        body: (widget.SchoolTypes != null)
            ? Directionality(
                textDirection:
                    widget.lang == "en" ? TextDirection.ltr : TextDirection.rtl,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
                  child: SingleChildScrollView(
                    child: Form(
                      key: formKey,
                      child: Column(
                        children: [
                          defaultFormField(
                              controller: FullNameField,
                              type: TextInputType.text,
                              defaultValue: widget.FullName,
                              onChange: (value) {
                                setState(() {
                                  dirty = true;
                                  widget.FullName = value;
                                });
                              },
                              validate: (String value) {
                                if (value == "" ||
                                    value == null ||
                                    value.trim().split(" ").length < 2) {
                                  return widget.lang == "en"
                                      ? 'please enter your Full Name'
                                      : "من فضلك ادخل الإسم بالكامل";
                                }
                              },
                              label: widget.lang == "en"
                                  ? "Full Name"
                                  : "الإسم بالكامل",
                              prefix: Icons.account_circle_sharp),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 30),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      widget.Gender = "Male";
                                      dirty = true;
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(0),
                                        child: widget.Gender == "Male"
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image.asset(
                                                    "assets/images/boyAvatar.jpg"),
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                                child: Image.asset(
                                                    "assets/images/boyAvatar_grayscale.jpg"),
                                              ),
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                width: 2,
                                                color: widget.Gender != "Male"
                                                    ? Colors.black38
                                                    : defaultColor)),
                                      ),
                                      Text(
                                        widget.lang == "en" ? "Male" : "ذكر",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: widget.Gender == "Male"
                                                ? defaultColor
                                                : Colors.black54),
                                      )
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      widget.Gender = "Female";
                                      dirty = true;
                                    });
                                  },
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(0),
                                        child: ConditionalBuilder(
                                          condition: widget.Gender == "Female",
                                          fallback: (context) => ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.asset(
                                                "assets/images/girlAvatar_grayscale.jpg"),
                                          ),
                                          builder: (context) => ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            child: Image.asset(
                                                "assets/images/girlAvatar.jpg"),
                                          ),
                                        ),
                                        width: 120,
                                        height: 120,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            border: Border.all(
                                                width: 2,
                                                color: widget.Gender == "Female"
                                                    ? defaultColor
                                                    : Colors.black38)),
                                      ),
                                      Text(
                                        widget.lang == "en" ? "Female" : "أنثى",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: widget.Gender == "Female"
                                                ? defaultColor
                                                : Colors.black54),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 0,
                          ),
                          (widget.YearsOfStudies != null)
                              ? Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black38),
                                  ),
                                  child: DropdownButton(
                                    //key: ValueKey(1),
                                    value: widget.SchoolTypeId == null
                                        ? 0
                                        : widget.SchoolTypeId,
                                    items: [
                                      //add items in the dropdown
                                      DropdownMenuItem(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.white))),
                                          alignment: widget.lang == "en"
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                          child: Text(
                                            widget.lang == "en"
                                                ? "Type of Study"
                                                : "نوعية التعليم",
                                          ),
                                        ),
                                        value: 0,
                                      ),
                                      ...SchoolTypesItems,
                                    ],

                                    onChanged: (value) {
                                      setState(() {
                                        widget.SchoolTypeId = value;
                                        widget.YearOfStudyId = null;
                                        StudyYearsBySchoolTypeId(value);
                                        dirty = true;
                                        // widget.SchoolTypeName
                                      });
                                    },
                                    icon: Padding(
                                        //Icon at tail, arrow bottom is default icon
                                        padding: EdgeInsets.all(0),
                                        child: Icon(Icons.keyboard_arrow_down)),
                                    iconEnabledColor:
                                        Colors.black54, //Icon color
                                    style: TextStyle(
                                        //te
                                        color: Colors.black87, //Font color
                                        fontSize:
                                            16 //font size on dropdown button
                                        ),
                                    underline: Container(),

                                    dropdownColor: Colors
                                        .white, //dropdown background color
                                    //remove underline
                                    isExpanded:
                                        true, //make true to make width 100%
                                  ))
                              : Text("unloaded"),
                          SizedBox(
                            height: 15,
                          ),
                          (widget.YearsOfStudies != null)
                              ? Container(
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(color: Colors.black38),
                                  ),
                                  child: DropdownButton(
                                    //key: ValueKey(1),
                                    value: widget.YearOfStudyId == null
                                        ? 0
                                        : widget.YearOfStudyId,
                                    items: [
                                      //add items in the dropdown
                                      DropdownMenuItem(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Colors.white))),
                                          alignment: widget.lang == "en"
                                              ? Alignment.centerLeft
                                              : Alignment.centerRight,
                                          child: Text(
                                            widget.lang == "en"
                                                ? "Year of Study"
                                                : "السنة الدراسية",
                                          ),
                                        ),
                                        value: 0,
                                      ),
                                      ...YearsOfStudiesItems,
                                    ],

                                    onChanged: (value) {
                                      setState(() {
                                        widget.YearOfStudyId = value;
                                        dirty = true;
                                      });
                                    },
                                    icon: Padding(
                                        //Icon at tail, arrow bottom is default icon
                                        padding: EdgeInsets.all(0),
                                        child: Icon(Icons.keyboard_arrow_down)),
                                    iconEnabledColor:
                                        Colors.black54, //Icon color
                                    style: TextStyle(
                                        //te
                                        color: Colors.black87, //Font color
                                        fontSize:
                                            16 //font size on dropdown button
                                        ),
                                    underline: Container(),

                                    dropdownColor: Colors
                                        .white, //dropdown background color
                                    //remove underline
                                    isExpanded:
                                        true, //make true to make width 100%
                                  ))
                              : Text("unloaded"),
                          SizedBox(
                            height: 15,
                          ),
                          Divider(),
                          SizedBox(
                            height: 15,
                          ),
                          IsSaving
                              ? Center(child: CircularProgressIndicator())
                              : defaultButton(
                                  function: dirty == false
                                      ? null
                                      : () {
                                          if (formKey.currentState.validate()) {
                                            if (widget.FullName == "" ||
                                                widget.FullName == null ||
                                                widget.FullName.split(" ")
                                                        .length <
                                                    2) {
                                              showToast(
                                                  text: widget.lang == "en"
                                                      ? "Full Name field is required!"
                                                      : "الإسم بالكامل مطلوب!",
                                                  state: ToastStates.ERROR);
                                              return;
                                            }
                                            if (widget.Gender == null) {
                                              showToast(
                                                  text: widget.lang == "en"
                                                      ? "You haven't selected the gender!"
                                                      : "لم تقم بتحديد الجنس!",
                                                  state: ToastStates.ERROR);
                                              return;
                                            }
                                            if (widget.SchoolTypeId == null) {
                                              showToast(
                                                  text: widget.lang == "en"
                                                      ? "Type of study field is required!"
                                                      : "الحقل نوعية التعليم مطلوب",
                                                  state: ToastStates.ERROR);
                                              return;
                                            }
                                            if (widget.YearOfStudyId == null) {
                                              showToast(
                                                  text: widget.lang == "en"
                                                      ? "Year of study is required!"
                                                      : "السنة الدراسية مطلوبة!",
                                                  state: ToastStates.ERROR);
                                              return;
                                            }

                                            saveData(
                                                context,
                                                widget.Id,
                                                widget.Gender,
                                                widget.FullName,
                                                widget.SchoolTypeId,
                                                widget.YearOfStudyId);
                                            setState(() {
                                              dirty = false;
                                              Navigator.of(context).pop();
                                              // navigateTo(
                                              //     context,
                                              //     StudentSelectedSubjectsScreen(
                                              //         widget.Id)
                                              navigateTo(
                                                  context,
                                                  StudentDashboardScreen(
                                                    Id: widget.Id,
                                                    FullName: widget.FullName,
                                                    Gender: widget.Gender,
                                                    SchoolTypeId:
                                                        widget.SchoolTypeId,
                                                    YearOfStudyId:
                                                        widget.YearOfStudyId,
                                                  ));
                                            });
                                          }
                                        },
                                  text: widget.lang == "en"
                                      ? "Save Changes"
                                      : "حفظ التعديلات",
                                  fontSize: 18,
                                  background: dirty == true
                                      ? Colors.green
                                      : Colors.black45),
                        ],
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                      ),
                    ),
                  ),
                ),
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }
}
