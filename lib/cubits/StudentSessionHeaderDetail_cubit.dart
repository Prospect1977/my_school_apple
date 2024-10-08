// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:my_school/cubits/StudentSessionHeaderDetail_states.dart';
// import 'package:my_school/models/StudentLessonSessions_model.dart';
// import 'package:my_school/models/StudentLessonsByYearSubjectId_model.dart';
// import 'package:my_school/models/StudentSessionHeaderDetail.dart';
// import 'package:my_school/shared/cache_helper.dart';
// import 'package:my_school/shared/components/components.dart';
// import 'package:my_school/shared/components/functions.dart';
// import 'package:my_school/shared/dio_helper.dart';

// class StudentSessionHeaderDetailCubit
//     extends Cubit<StudentSessionHeaderDetailStates> {
//   StudentSessionHeaderDetailCubit() : super(InitialState());
//   static StudentSessionHeaderDetailCubit get(context) =>
//       BlocProvider.of(context);
//   AllData StudentSessionHeaderDetailsCollection;

//   var lang = CacheHelper.getData(key: "lang");
//   var token = CacheHelper.getData(key: "token");

//   void postRate(context, StudentId, SessionHeaderId, Rate) {
//     emit(SavingRateState());
//     DioHelper.postData(
//             url: 'StudentSessionRate',
//             data: {},
//             query: {
//               'StudentId': StudentId,
//               'SessionHeaderId': SessionHeaderId,
//               "Rate": Rate
//             },
//             lang: lang,
//             token: token)
//         .then((value) {
//       print(value.data["data"]);
//       if (value.data["status"] == false &&
//           value.data["message"] == "SessionExpired") {
//         handleSessionExpired(context);
//       }

//       emit(RatingSavedState());
//     }).catchError((error) {
//       showToast(text: error.toString(), state: ToastStates.ERROR);
//     });
//   }

//   void postPurchase(context, StudentId, SessionHeaderId) {
//     DioHelper.postData(
//             url: 'StudentPurchaseSession',
//             data: {},
//             query: {
//               'StudentId': StudentId,
//               'SessionHeaderId': SessionHeaderId,
//               'DataDate': DateTime.now(),
//             },
//             lang: lang,
//             token: token)
//         .then((value) {
//       print(value.data["data"]);
//       if (value.data["status"] == false) {}

//       emit(PurchaseDoneState());
//     }).catchError((error) {
//       showToast(text: error.toString(), state: ToastStates.ERROR);
//     });
//   }

//   void UpdateLessonProgress(StudentId, SessionHeaderId) {
//     DioHelper.postData(
//             url: 'StudentSessionHeaderDetails',
//             query: {
//               'StudentId': StudentId,
//               'SessionHeaderId': SessionHeaderId,
//               "DataDate": DateTime.now()
//             },
//             lang: lang,
//             data: {},
//             token: token)
//         .then((value) {
//       print(value.data["data"]);
//     }).catchError((error) {
//       showToast(text: error.toString(), state: ToastStates.ERROR);
//     });
//   }
// }
