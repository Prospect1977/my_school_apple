import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:my_school/providers/StudentLessonSessionsProvider.dart';
import 'package:my_school/providers/WalletProvider.dart';
import 'package:my_school/screens/studentSessionDetails_screen.dart';
import 'package:my_school/shared/cache_helper.dart';
import 'package:my_school/shared/components/components.dart';
import 'package:my_school/shared/components/paymob.dart';
import 'package:my_school/shared/dio_helper.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../shared/components/functions.dart';

class PaymobCreditCardScreen extends StatefulWidget {
  PaymobCreditCardScreen(
      {@required this.ChargeWalletMode,
      this.StudentId,
      this.SessionHeaderId,
      this.Payment,
      this.LessonName,
      this.LessonDescription,
      this.dir,
      this.TeacherName,
      Key key})
      : super(key: key);
  final bool ChargeWalletMode;

  int StudentId;
  int SessionHeaderId;
  dynamic Payment;
  String LessonName;
  String LessonDescription;
  String dir;
  String TeacherName;

  @override
  State<PaymobCreditCardScreen> createState() => _PaymobCreditCardScreenState();
}

class _PaymobCreditCardScreenState extends State<PaymobCreditCardScreen> {
  bool isResponseRecieved = false;
  WebViewController webViewController;
  var lang = CacheHelper.getData(key: "lang");
  var fullName = CacheHelper.getData(key: "fullName");
  String phoneNumber = CacheHelper.getData(key: "phoneNumber");
  var email = CacheHelper.getData(key: "email");
  // var email = "langara5000@hotmail.com";
  bool isLoaded = false;
  var token = CacheHelper.getData(key: "token");
  int OrderId = 0;
  int lessonId;
  void postPurchase(StudentId, SessionHeaderId) {
    if (widget.ChargeWalletMode) {
      DioHelper.postData(
              url: 'wallet/RechargeWallet',
              data: {},
              query: {
                'Amount': widget.Payment,
                'OrderId': OrderId,
                'Source': "iframe",
                'DataDate': DateTime.now(),
                'UserId': CacheHelper.getData(key: 'userId')
              },
              lang: lang,
              token: token)
          .then((value) {
        print(value.data["data"]);

        if (value.data["status"] == false &&
            value.data["message"] == "SessionExpired") {
          handleSessionExpired(context);
          return;
        } else if (value.data["status"] == false) {
          showToast(text: value.data["message"], state: ToastStates.ERROR);
          return;
        }
      }).catchError((error) {
        showToast(text: error.toString(), state: ToastStates.ERROR);
        //emit(ErrorState(error.toString()));
      });
    } else {
      DioHelper.postData(
              url: 'StudentPurchaseSession',
              data: {},
              query: {
                'StudentId': StudentId,
                'SessionHeaderId': SessionHeaderId,
                'OrderId': OrderId,
                'DataDate': DateTime.now(),
                'Source': "iframe",
              },
              lang: lang,
              token: token)
          .then((value) {
        print(value.data["data"]);

        if (value.data["status"] == false &&
            value.data["message"] == "SessionExpired") {
          handleSessionExpired(context);
          return;
        } else if (value.data["status"] == false) {
          showToast(text: value.data["message"], state: ToastStates.ERROR);
          return;
        }
        setState(() {
          lessonId = value.data["data"];
        });
      }).catchError((error) {
        showToast(text: error.toString(), state: ToastStates.ERROR);
        //emit(ErrorState(error.toString()));
      });
    }
  }

  Future<void> Request1() async {
    DioHelper.postData(
        url: '$base_paymob_url/auth/tokens',
        data: {"api_key": api_key}).then((value) {
      print('token_first:' + value.data['token']);
      token_first = value.data['token'];
      Request2();
    });
  }

  Future<void> Request2() async {
    print('assure token_first:' + token_first);
    DioHelper.postPaymobData(url: '$base_paymob_url/ecommerce/orders', data: {
      "auth_token": token_first,
      "delivery_needed": "false",
      "amount_cents": widget.Payment.toString(),
      "currency": "EGP",
//  "merchant_order_id": 5,
      "items": []
    }).then((value) {
      print('order id: ${value.data['id']}');
      print('response2: ${value.data}');
      setState(() {
        OrderId = value.data['id'];
      });

      Request3();
    });
  }

  Future<void> Request3() async {
    DioHelper.postPaymobData(
        url: '$base_paymob_url/acceptance/payment_keys',
        data: {
          "auth_token": token_first,
          "amount_cents": widget.Payment.toString(),
          "expiration": 3600,
          "order_id": OrderId.toString(),
          "billing_data": {
            "apartment": "NA",
            "email": email,
            "floor": "NA",
            "first_name": fullName.split(' ')[0],
            "street": "NA",
            "building": "NA",
            "phone_number": phoneNumber == null ? "01032351422" : phoneNumber,
            "shipping_method": "NA",
            "postal_code": "NA",
            "city": "NA",
            "country": "Egypt",
            "last_name": fullName.split(' ').length == 1
                ? "null"
                : fullName.split(' ')[1],
            "state": "NA"
          },
          "currency": "EGP",
          "integration_id": integration_id, // very important
          "lock_order_when_paid": "false",
          "items": []
        }).then((t) {
      token_second = t.data['token'];
      print('token_second: ${t.data['token']}');
      postPurchase(
        widget.StudentId,
        widget.SessionHeaderId,
      );
      setState(() {
        isLoaded = true;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Request1();
  }

  @override
  Widget build(BuildContext context) {
    // if (isResponseRecieved && widget.ChargeWalletMode) {}
    return Scaffold(
      appBar: appBarComponent(
          context, lang == "en" ? "Complete Payment" : "إستكمال الدفع"),
      body: isLoaded == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Stack(children: [
              WebView(
                onPageStarted: (url) async {
                  print(
                      '------------------------------------------------------------url:' +
                          url);
                  if (url.contains('PaymobResponse.html')) {
                    setState(() {
                      isResponseRecieved = true;
                    });

                    if (widget.ChargeWalletMode) {
                      // showToast(text: lang=="en"?"Wallet charged successfully!":"تم شحن المحفظة بنجاح!", state: ToastStates.SUCCESS)
                      await Provider.of<WalletProvider>(context, listen: false)
                          .getData(context);

                      // Navigator.of(context).pop();
                    } else {
                      Provider.of<StudentLessonSessionsProvider>(context,
                              listen: false)
                          .getSessions(context, widget.StudentId, lessonId);
                    }
                  }
                },
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                javascriptMode: JavascriptMode.unrestricted,
                initialUrl:
                    'https://accept.paymob.com/api/acceptance/iframes/760844?payment_token=$token_second',
              ),
              isResponseRecieved
                  ? Align(
                      alignment: AlignmentDirectional.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: defaultButton(
                            function: () {
                              Navigator.of(context).pop();
                              if (!widget.ChargeWalletMode) {
                                navigateTo(
                                    context,
                                    StudentSessionDetailsScreen(
                                        SessionHeaderId: widget.SessionHeaderId,
                                        LessonName: widget.LessonName,
                                        LessonDescription:
                                            widget.LessonDescription,
                                        dir: widget.dir,
                                        StudentId: widget.StudentId,
                                        TeacherName: widget.TeacherName));
                              }
                            },
                            text: widget.ChargeWalletMode
                                ? lang == "en"
                                    ? "<<Back"
                                    : "<<رجوع"
                                : lang == "en"
                                    ? "Back to Lesson"
                                    : "العودة إلى الدرس",
                            background: Colors.green,
                            foregroundColor: Colors.white),
                      ),
                    )
                  : Container(),
            ]),
    );
  }
}
