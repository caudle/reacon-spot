import 'package:dirm/application/login/login_cubit.dart';
import 'package:dirm/screen/auth/login/widgets/login_form.dart';
import 'package:dirm/services/firebase/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: BlocProvider(
          create: (_) => LoginCubit(AuthService()),
          child: const LoginForm(),
        ),
      ),
    );
  }
}
