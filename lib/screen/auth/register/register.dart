import 'package:dirm/application/register/register_bloc.dart';
import 'package:dirm/screen/auth/register/widgets/register_form.dart';
import 'package:dirm/services/api/rest_api.dart';
import 'package:dirm/services/storage/database_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({Key? key}) : super(key: key);

  // TODO
  /// make phone number unique

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: BlocProvider(
          create: ((context) => RegisterBloc(
              restApi: RestApi(), databaseService: DatabaseService())),
          child: const RegisterForm(),
        ),
      ),
    );
  }
}
