import 'package:dirm/application/register/register_bloc.dart';
import 'package:dirm/screen/auth/register/phone_verification.dart';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterForm extends StatelessWidget {
  const RegisterForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<RegisterBloc, RegisterState>(
      listener: (context, state) {
        // error snackbar
        if (state.errrorMessage != null) {
          print(state.errrorMessage);
          final snackBar = SnackBar(
            content:
                Text('Registration failed, try again: ${state.errrorMessage}'),
            duration: const Duration(seconds: 40),
            action: SnackBarAction(
              label: 'DELETE',
              onPressed: () =>
                  ScaffoldMessenger.of(context)..removeCurrentSnackBar(),
            ),
          );
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);
        }
        if (state.issuccess) {
          // go to phone verf page
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) => PhoneVerificationPage(
                      phoneNumber: state.phone!,
                      route: '/bottom-nav-bar',
                    )),
              ));
        }
      },
      child: SingleChildScrollView(
        child: Align(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: Column(
            children: [
              SizedBox(height: 50),
              _NameInput(),
              SizedBox(height: 20),
              _EmailInput(),
              SizedBox(height: 20),
              _PhoneInput(),
              SizedBox(height: 20),
              _PasswordInput(),
              SizedBox(height: 20),
              _ConfirmpasswordInput(),
              SizedBox(height: 30),
              _RegisterButton(),
              SizedBox(height: 25),
              _LoginButton(),
            ],
          ),
        )),
      ),
    );
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: ((previous, current) => current.name != previous.name),
      builder: (context, state) {
        return TextField(
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
              labelText: "full name",
              prefixIcon: Icon(
                Icons.perm_identity,
                color: Theme.of(context).iconTheme.color,
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColorLight)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColorLight)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              errorText: state.name == null
                  ? null
                  : state.isname
                      ? null
                      : 'enter valid name',
              errorStyle: const TextStyle(color: Colors.red)),
          cursorColor: Theme.of(context).primaryColorDark,
          onChanged: ((value) =>
              context.read<RegisterBloc>().add(NameChanged(value))),
        );
      },
    );
  }
}

class _PhoneInput extends StatelessWidget {
  const _PhoneInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return TextFormField(
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: "phone",
            prefixIcon: Icon(
              Icons.phone,
              color: Theme.of(context).iconTheme.color,
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            errorText: state.phone == null
                ? null
                : state.isphone
                    ? null
                    : 'enter valid phone numbe',
          ),
          cursorColor: Theme.of(context).primaryColorDark,
          onChanged: (value) {
            context.read<RegisterBloc>().add(PhoneChanged(value));
          },
        );
      },
    );
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return TextFormField(
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
              labelText: "email",
              prefixIcon: Icon(
                Icons.email,
                color: Theme.of(context).iconTheme.color,
              ),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColorLight)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide:
                      BorderSide(color: Theme.of(context).primaryColorLight)),
              focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.red)),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              errorText: state.email == null
                  ? null
                  : state.isemail
                      ? null
                      : 'enter valid email address'),
          cursorColor: Theme.of(context).primaryColorDark,
          onChanged: (value) {
            context.read<RegisterBloc>().add(EmailChanged(value));
          },
        );
      },
    );
  }
}

class _PasswordInput extends StatelessWidget {
  const _PasswordInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) => previous.password != current.password,
      builder: (context, state) {
        return TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: "password",
            prefixIcon: Icon(
              Icons.lock,
              color: Theme.of(context).iconTheme.color,
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            errorText: state.password == null
                ? null
                : state.ispassword
                    ? null
                    : 'weak password',
          ),
          cursorColor: Theme.of(context).primaryColorDark,
          onChanged: (value) {
            context.read<RegisterBloc>().add(PasswordChanged(value));
          },
        );
      },
    );
  }
}

class _ConfirmpasswordInput extends StatelessWidget {
  const _ConfirmpasswordInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(
      buildWhen: (previous, current) =>
          previous.confirmpassword != current.confirmpassword,
      builder: (context, state) {
        return TextFormField(
          obscureText: true,
          decoration: InputDecoration(
            labelText: "confirm password",
            prefixIcon: Icon(
              Icons.lock,
              color: Theme.of(context).iconTheme.color,
            ),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColorLight)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red)),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
            errorText: state.confirmpassword == null
                ? null
                : state.ispasswordMatch
                    ? null
                    : 'password do not match',
          ),
          cursorColor: Theme.of(context).primaryColorDark,
          onChanged: (value) {
            context.read<RegisterBloc>().add(ConfirmpasswordChanged(value));
          },
        );
      },
    );
  }
}

class _RegisterButton extends StatelessWidget {
  const _RegisterButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RegisterBloc, RegisterState>(builder: (context, state) {
      return state.isloading
          ? const CircularProgressIndicator()
          : ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                primary: Theme.of(context).primaryColorDark,
                fixedSize: Size(MediaQuery.of(context).size.width, 60),
              ),
              onPressed: state.isname &&
                      state.isemail &&
                      state.isphone &&
                      state.ispassword &&
                      state.ispasswordMatch
                  ? () => context
                      .read<RegisterBloc>()
                      .add(RegisterWithEmailPressed())
                  : null,
              child: const Text('Register'),
            );
    });
  }
}

class _LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextButton(
      onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
      child: Text(
        'LOG IN',
        style: TextStyle(color: theme.primaryColorLight),
      ),
    );
  }
}
