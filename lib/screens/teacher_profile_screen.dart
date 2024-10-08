import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:my_school/models/teacher-payment-type-model.dart';
import 'package:my_school/models/teacher_profile_model.dart';
import 'package:my_school/screens/login_screen.dart';
import 'package:my_school/screens/teacher_dashboard_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/constants.dart';
import 'package:my_school/shared/components/functions.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:my_school/shared/widgets/teacher_image_input.dart';

class TeacherProfileScreen extends StatefulWidget {
  int teacherId;
  bool readOnly;
  TeacherProfileScreen(
      {@required this.teacherId, @required this.readOnly, Key key})
      : super(key: key);

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  TeacherProfileModel model = null;
  String lang = CacheHelper.getData(key: "lang");
  String token = CacheHelper.getData(key: "token");
  String roles = CacheHelper.getData(key: "roles");
  String bioDirection;
  bool isDirty = false; //indicates whether the teacher edited his data
  bool savingState = false;
  void _selectImage(String pickedImage) {
    setState(() {
      model.photo = pickedImage;
      model.urlSource = "api";
      showChangeProfilePictureControllers = false;
    });
  }

  bool showChangeProfilePictureControllers = false;
  var formKey = GlobalKey<FormState>();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController nationalIdController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  int teacherTransferAccountId = 0;
  List<TeacherPaymentTransferType> TransferTypes = null;
  void getData() async {
    DioHelper.getData(
            url: "TeacherProfile",
            query: {"TeacherId": widget.teacherId},
            token: token,
            lang: lang)
        .then((value) {
      print(value.data);
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      setState(() {
        TransferTypes = (value.data["additionalData"] as List)
            .map((item) => TeacherPaymentTransferType.fromJson(item))
            .toList();

        model = TeacherProfileModel.fromJson(value.data["data"]);
        bioDirection == null ? "rtl" : model.biographyDir;
        fullNameController.text = model.fullName;
        bioController.text = model.biography == null ? "" : model.biography;
        nationalIdController.text =
            model.nationalId == null ? "" : model.nationalId;
        bioDirection = model.biographyDir == null ? "rtl" : model.biographyDir;
        teacherTransferAccountId = model.accountTypeId;
        accountNumberController.text = model.accountNumber;
      });
    }).catchError((err) {
      showToast(text: err.toString(), state: ToastStates.ERROR);
    });
  }

  void _onAccountTransferTypeChanged(int id) {
    setState(() {
      teacherTransferAccountId = id;
      isDirty = true;
    });
  }

  void sendData() async {
    setState(() {
      savingState = true;
    });

    DioHelper.postData(
        url: "TeacherProfile",
        query: {"TeacherId": widget.teacherId},
        token: token,
        lang: lang,
        data: {
          "id": widget.teacherId,
          "fullName": fullNameController.text,
          "biography": bioController.text,
          "biographyDir": bioDirection,
          "nationalId": nationalIdController.text,
          "accountTypeId": teacherTransferAccountId,
          "accountNumber": accountNumberController.text,
        }).then((value) {
      if (value.data["status"] == false &&
          value.data["message"] == "SessionExpired") {
        handleSessionExpired(context);
        return;
      } else if (value.data["status"] == false) {
        showToast(text: value.data["message"], state: ToastStates.ERROR);
        return;
      }
      setState(() {
        savingState = false;
        isDirty = false;
        navigateAndFinish(context, TeacherDashboardScreen());
      });
    }).catchError((error) {
      showToast(text: error.toString(), state: ToastStates.ERROR);
    });
  }

  void _onChange() {
    setState(() {
      isDirty = true;
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
    return Scaffold(
      appBar: appBarComponent(context, model == null ? "" : model.fullName),
      body: RefreshIndicator(
        onRefresh: () async {
          getData();
        },
        child: model == null
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding: EdgeInsets.all(8),
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 5,
                        ),
                        Center(
                          //-----------------------------------------------------------------------Avatar
                          child: CircleAvatar(
                            radius: 62,
                            backgroundColor: Colors.black.withOpacity(.26),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: Stack(
                                  alignment: Alignment.bottomCenter,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(120),
                                      child: model.photo == null
                                          ? Image.asset(
                                              'assets/images/Teacher.jpg',
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network(
                                              model.urlSource == "web" ||
                                                      model.urlSource == "Web"
                                                  ? '${webUrl}images/Profiles/${model.photo}'
                                                  : '${baseUrl0}Assets/ProfileImages/${model.photo}',
                                              fit: BoxFit.cover,
                                              width: 120,
                                              height: 120,
                                            ),
                                    ),
                                    widget.readOnly == false
                                        ? Positioned(
                                            bottom: 0,
                                            right: 0,
                                            child: Container(
                                              width: 40,
                                              height: 40,
                                              decoration: BoxDecoration(
                                                  color: Colors.deepPurple
                                                      .withOpacity(0.75),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          30)),
                                              child: IconButton(
                                                  onPressed: () {
                                                    setState(() {
                                                      showChangeProfilePictureControllers =
                                                          true;
                                                    });
                                                  },
                                                  icon: Icon(
                                                    Icons.camera_alt_rounded,
                                                    /* shadows: [
                                                    Shadow(
                                                        color: Colors.black87,
                                                        blurRadius: 15)
                                                  ],*/
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                  )),
                                            ),
                                          )
                                        : Container(),
                                  ]),
                            ),
                          ),
                        ),
                        //---------------------------------------------------------------------End of avatar
                        showChangeProfilePictureControllers == true
                            ? SizedBox(
                                height: 10,
                              )
                            : Container(),
                        showChangeProfilePictureControllers == true
                            ? Stack(
                                children: [
                                  TeacherImageInput(
                                      _selectImage, model.photo != null),
                                  Positioned(
                                    right: 0,
                                    child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showChangeProfilePictureControllers =
                                                false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.black38,
                                          size: 17,
                                        )),
                                  ),
                                  Positioned(
                                    right: 0,
                                    child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            showChangeProfilePictureControllers =
                                                false;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.square_outlined,
                                          color: Colors.black38,
                                          size: 20,
                                        )),
                                  )
                                ],
                              )
                            : Container(),
                        SizedBox(
                          height: 10,
                        ),
                        widget.readOnly == true
                            ? Text(
                                model.fullName,
                                style: TextStyle(fontSize: 20),
                              )
                            : Directionality(
                                textDirection: lang == "en"
                                    ? TextDirection.ltr
                                    : TextDirection.rtl,
                                child: defaultFormField(
                                  controller: fullNameController,
                                  type: TextInputType.text,
                                  onChange: (value) {
                                    setState(() {
                                      isDirty = true;
                                    });
                                  },
                                  validate: (String value) {
                                    if (value.isEmpty) {
                                      return lang == "en"
                                          ? 'please enter your full name'
                                          : "من فضلك أدخل الإسم بالكامل";
                                    }
                                  },
                                  label: lang == "en"
                                      ? 'Full Name'
                                      : "الإسم بالكامل",
                                  prefix: Icons.account_circle,
                                ),
                              ),
                        SizedBox(
                          height: 10,
                        ),
                        widget.readOnly == false
                            ? defaultFormField(
                                controller: nationalIdController,
                                type: TextInputType.number,
                                onChange: (value) {
                                  setState(() {
                                    isDirty = true;
                                  });
                                },
                                validate: (String value) {
                                  if (value.isEmpty) {
                                    return lang == "en"
                                        ? 'please enter your National Id'
                                        : "من فضلك أدخل الرقم القومي";
                                  }
                                },
                                label: lang == "en"
                                    ? 'National Id'
                                    : "الرقم القومي",
                                prefix: Icons.credit_card,
                              )
                            : Container(),

                        widget.readOnly == false
                            ? SizedBox(
                                height: 10,
                              )
                            : Container(),
                        model.views > 0
                            ? RatingBarIndicator(
                                rating:
                                    double.parse(model.rate.toStringAsFixed(2)),
                                itemBuilder: (context, index) => Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                itemCount: 5,
                                itemSize: 25.0,
                                direction: Axis.horizontal,
                                itemPadding:
                                    EdgeInsets.symmetric(horizontal: 0),
                              )
                            : Container(),
                        model.views > 0
                            ? SizedBox(
                                height: 5,
                              )
                            : Container(),
                        model.views > 0
                            ? Text(
                                '${model.views} ${lang == "en" ? "Views" : model.views > 10 ? "مشاهدة" : "مشاهدات"}',
                                textDirection: lang == "en"
                                    ? TextDirection.ltr
                                    : TextDirection.rtl,
                              )
                            : Container(),
                        model.views > 0
                            ? SizedBox(
                                height: 10,
                              )
                            : Container(),
                        //------------------------------------------------Start of Bio
                        widget.readOnly
                            ? Directionality(
                                textDirection: bioDirection == "ltr"
                                    ? TextDirection.ltr
                                    : TextDirection.rtl,
                                child: Text(
                                  model.biography == null
                                      ? ""
                                      : model.biography,
                                  style: TextStyle(
                                      fontSize: 18, color: Colors.black54),
                                ))
                            : Stack(children: [
                                Directionality(
                                  textDirection: bioDirection == "ltr"
                                      ? TextDirection.ltr
                                      : TextDirection.rtl,
                                  child: defaultFormField(
                                    onChange: (value) {
                                      setState(() {
                                        isDirty = true;
                                      });
                                    },
                                    maximumLines: 6,
                                    controller: bioController,
                                    type: TextInputType.multiline,
                                    label:
                                        lang == "en" ? 'Brief' : "نبذة مختصرة",
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  left: bioDirection == "rtl" ? 2 : null,
                                  right: bioDirection == "ltr" ? 2 : null,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            bioDirection = "rtl";
                                          });
                                        },
                                        child: Container(
                                            width: 30,
                                            height: 20,
                                            decoration: BoxDecoration(
                                                color: bioDirection == "rtl"
                                                    ? Colors.purple
                                                    : Colors.white),
                                            child: Center(
                                              child: Text(
                                                "Ar",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: bioDirection == "rtl"
                                                        ? Colors.white
                                                        : Colors.black54),
                                              ),
                                            )),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            bioDirection = "ltr";
                                          });
                                        },
                                        child: Container(
                                            width: 30,
                                            height: 20,
                                            decoration: BoxDecoration(
                                                color: bioDirection == "ltr"
                                                    ? Colors.purple
                                                    : Colors.white),
                                            child: Center(
                                              child: Text(
                                                "En",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: bioDirection == "ltr"
                                                        ? Colors.white
                                                        : Colors.black45),
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                )
                              ]),
                        //------------------------------------------------end of Bio
                        if (widget.readOnly == false)
                          SizedBox(
                            height: 10,
                          ),
                        if (widget.readOnly == false)
                          dropDownTransferAccountType(
                              lang: lang,
                              TransferTypes: TransferTypes,
                              onChanged: _onAccountTransferTypeChanged,
                              selectedItem: model.accountTypeId),
                        if (widget.readOnly == false)
                          SizedBox(
                            height: 10,
                          ),
                        if (widget.readOnly == false)
                          Directionality(
                            textDirection: lang == "en"
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                            child: defaultFormField(
                              controller: accountNumberController,
                              type: TextInputType.text,
                              onChange: (value) {
                                setState(() {
                                  isDirty = true;
                                });
                              },
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return lang == "en"
                                      ? 'please enter your account number'
                                      : "من فضلك أدخل رقم الحساب";
                                }
                              },
                              label: lang == "en"
                                  ? 'Account Number'
                                  : "رقم الحساب",
                            ),
                          ),
                        SizedBox(
                          height: 10,
                        ),
                        isDirty
                            ? savingState
                                ? Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : defaultButton(
                                    function: () {
                                      if (formKey.currentState.validate()) {
                                        sendData();
                                      }
                                    },
                                    text: lang == "en"
                                        ? "Save Changes"
                                        : "حفظ التعديلات")
                            : Container()
                      ],
                    ),
                  ),
                )),
      ),
    );
  }
}
