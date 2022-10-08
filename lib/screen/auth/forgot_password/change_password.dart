import 'package:dirm/modal/user.dart';
import 'package:flutter/material.dart';

import '../../../services/api/rest_api.dart';
import '../../../util/shared.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();
  final restApi = RestApi();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    final user = ModalRoute.of(context)!.settings.arguments as User;
    return WillPopScope(
      onWillPop: () async => false,
      child: SafeArea(
        child: Scaffold(
          body: Align(
            alignment: Alignment.center,
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Change your password'),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: passwordController,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (value!.length < 6) {
                        return "Weak password";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: confirmController,
                    onChanged: (_) => setState(() {}),
                    validator: (value) {
                      if (value != passwordController.value.text) {
                        return "Password mismatch";
                      } else {
                        return null;
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  Offstage(
                    offstage: isloading,
                    child: ElevatedButton(
                      onPressed: passwordController.value.text.length < 6 &&
                              confirmController.value.text !=
                                  passwordController.value.text
                          ? null
                          : () {
                              // start loadng
                              setState(() => isloading = true);
                              final password =
                                  passwordController.value.text.trim();
                              changePassword(
                                user: user,
                                password: password,
                                restApi: restApi,
                              ).then((_) {
                                // remov loading
                                setState(() => isloading = false);
                                // go to login
                                Navigator.pushNamedAndRemoveUntil(
                                    context, '/login', (route) => false);
                              }, onError: (error) {
                                // remov loading
                                setState(() => isloading = false);
                                showSnackBar(
                                    context: context,
                                    message: error.toString());
                              });
                            },
                      child: const Text('Send'),
                    ),
                  ),
                  Offstage(
                    offstage: !isloading,
                    child: const CircularProgressIndicator(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> changePassword({
  required User user,
  required String password,
  required RestApi restApi,
}) async {
  try {
    await restApi.changePassword(userId: user.userId, password: password);
  } catch (e) {
    throw Exception(e);
  }
}
