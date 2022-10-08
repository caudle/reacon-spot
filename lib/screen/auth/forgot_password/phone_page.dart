import 'package:dirm/modal/user.dart';
import 'package:dirm/util/shared.dart';
import 'package:flutter/material.dart';

import '../../../services/api/rest_api.dart';
import '../register/phone_verification.dart';

class PhonePage extends StatefulWidget {
  const PhonePage({Key? key}) : super(key: key);

  @override
  State<PhonePage> createState() => _PhonePageState();
}

class _PhonePageState extends State<PhonePage> {
  final _formKey = GlobalKey<FormState>();
  final restApi = RestApi();
  TextEditingController phoneController = TextEditingController();
  bool isloading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot password')),
      body: Align(
        alignment: Alignment.center,
        child: Form(
          autovalidateMode: AutovalidateMode.onUserInteraction,
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Enter Phone number'),
                const SizedBox(height: 26),
                TextFormField(
                  keyboardType: TextInputType.phone,
                  controller: phoneController,
                  onChanged: ((value) => setState(() {})),
                  validator: (phone) {
                    if (phone!.length != 10) {
                      return 'Enter valid phone number';
                    } else {
                      return null;
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'phone number',
                    prefixIcon: Icon(
                      Icons.phone,
                      color: Theme.of(context).iconTheme.color,
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColorLight)),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: Theme.of(context).primaryColorLight)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red)),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.red)),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 15),
                  ),
                ),
                const SizedBox(height: 40),
                Offstage(
                  offstage: isloading,
                  child: ElevatedButton(
                    onPressed: phoneController.value.text.length != 10
                        ? null
                        : () {
                            setState(() => isloading = true);
                            final phone = phoneController.value.text.trim();
                            onPressed(restApi, phone).then((user) {
                              //remv loadng
                              setState(() => isloading = false);
                              print(user);
                              // go to phone verf page
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: ((context) =>
                                        PhoneVerificationPage(
                                          phoneNumber: phone,
                                          route: '/forgot-password',
                                          user: user,
                                        )),
                                  ));
                            }, onError: (error) {
                              setState(() => isloading = false);
                              showSnackBar(
                                  context: context, message: error.toString());
                            });
                          },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      primary: Theme.of(context).primaryColorDark,
                      fixedSize: Size(MediaQuery.of(context).size.width, 60),
                    ),
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
    );
  }
}

Future<User> onPressed(RestApi api, String phone) async {
  // check phn
  return await api.checkPhone(phone);
}
