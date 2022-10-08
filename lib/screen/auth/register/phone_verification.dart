import 'dart:async';

import 'package:dirm/modal/user.dart';
import 'package:dirm/services/api/rest_api.dart';
import 'package:dirm/services/storage/database_service.dart';
import 'package:dirm/util/shared.dart';
import 'package:flutter/material.dart';

class PhoneVerificationPage extends StatefulWidget {
  const PhoneVerificationPage({
    required this.phoneNumber,
    required this.route,
    this.user,
    Key? key,
  }) : super(key: key);
  final String phoneNumber;
  final String route;
  final User? user;

  @override
  State<PhoneVerificationPage> createState() => _PhoneVerificationPageState();
}

class _PhoneVerificationPageState extends State<PhoneVerificationPage> {
  TextEditingController smsCodeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final databaseService = DatabaseService();
  final restApi = RestApi();
  late Timer timer;
  int startTime = 60;
  bool isloading = false;

  @override
  void initState() {
    // fetch otp
    fetchOtp(
      user: widget.user,
      dbClient: databaseService,
      restApi: restApi,
    ).then(
      (_) => startTimer(),
      onError: (error) => showSnackBar(
        context: context,
        message: error.toString(),
      ),
    );
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            const Text('Phone Verification'),
            const SizedBox(height: 20),
            const Text('Enter SMS code'),
            const SizedBox(height: 10),
            TextFormField(
              controller: smsCodeController,
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            Text(
              "If you have not received code, press resend in ${startTime.toString()} seconds",
              textAlign: TextAlign.justify,
            ),
            Offstage(
              offstage: isloading,
              child: Row(
                children: [
                  TextButton(
                    onPressed: startTime != 60
                        ? null
                        : () {
                            //start loading
                            setState(() => isloading = true);
                            fetchOtp(
                              user: widget.user,
                              dbClient: databaseService,
                              restApi: restApi,
                            ).then((_) {
                              // remov loading
                              setState(() => isloading = false);
                              startTimer();
                            }, onError: (error) {
                              setState(() => isloading = false);
                              showSnackBar(
                                  context: context, message: error.toString());
                            });
                          },
                    child: const Text('Resend'),
                  ),
                  ElevatedButton(
                    onPressed: smsCodeController.value.text.length != 4
                        ? null
                        : () {
                            setState(() => isloading = true);
                            final otp = smsCodeController.value.text.trim();
                            verifyOtp(
                                    user: widget.user,
                                    otp: otp,
                                    dbClient: databaseService,
                                    restApi: restApi)
                                .then((value) {
                              // remov loading
                              setState(() => isloading = false);
                              Navigator.pushNamedAndRemoveUntil(
                                  context, widget.route, (route) => false,
                                  arguments: widget.user!);
                            }, onError: (error) {
                              // remov loading
                              setState(() => isloading = false);
                              showSnackBar(
                                  context: context, message: error.toString());
                            });
                          },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            if (isloading) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  // timer
  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (startTime == 0) {
        timer.cancel();
        setState(() {
          startTime = 60;
        });
      } else {
        final time = startTime - 1;
        setState(() {
          startTime = time;
        });
      }
    });
  }
}

Future<String> fetchOtp({
  User? user,
  required DatabaseService dbClient,
  required RestApi restApi,
}) async {
  try {
    // if user is null get user frm db
    user ??= await dbClient.getUser();
    // format pjhone nmb to 255
    final formattedPhone = user!.phone.replaceFirst('0', '255');
    print('phone: $formattedPhone');
    if (formattedPhone.length != 12) {
      throw Exception('phone number is wrongly formatted');
    }
    final otp =
        await restApi.fetchOtp(userId: user.userId, phone: formattedPhone);
    return otp;
  } catch (e) {
    print('error: ${e.toString()}');
    throw Exception(e);
  }
}

Future<void> verifyOtp({
  User? user,
  required String otp,
  required DatabaseService dbClient,
  required RestApi restApi,
}) async {
  try {
    // if user is null get user frm db
    user ??= await dbClient.getUser();
    // verify
    await restApi.verifyOtp(userId: user!.userId, otp: otp);
  } catch (e) {
    throw Exception(e);
  }
}
