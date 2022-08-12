import 'package:dirm/application/register/register_bloc.dart';

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
          Navigator.pushNamed(context, '/register/phone-verification');
        }
      },
      child: SingleChildScrollView(
        child: Align(
            child: Column(
          children: const [
            _NameInput(),
            SizedBox(height: 10),
            _EmailInput(),
            SizedBox(height: 10),
            _PhoneInput(),
            SizedBox(height: 10),
            _PasswordInput(),
            SizedBox(height: 10),
            _ConfirmpasswordInput(),
            _RegisterButton(),
          ],
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
        return TextFormField(
          keyboardType: TextInputType.name,
          decoration: InputDecoration(
            labelText: "full name",
            prefixIcon: Icon(
              Icons.phone,
              color: Theme.of(context).iconTheme.color,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            errorText: state.name == null
                ? ''
                : state.isname
                    ? ''
                    : 'enter valid name',
          ),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            errorText: state.phone == null
                ? ''
                : state.isphone
                    ? ''
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
                Icons.phone,
                color: Theme.of(context).iconTheme.color,
              ),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              focusedBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              errorBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              errorText: state.email == null
                  ? ''
                  : state.isemail
                      ? ''
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
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "password",
            prefixIcon: Icon(
              Icons.phone,
              color: Theme.of(context).iconTheme.color,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            errorText: state.password == null
                ? ''
                : state.ispassword
                    ? ''
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
          keyboardType: TextInputType.visiblePassword,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "confirm password",
            prefixIcon: Icon(
              Icons.phone,
              color: Theme.of(context).iconTheme.color,
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            errorBorder:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
            errorText: state.confirmpassword == null
                ? ''
                : state.ispasswordMatch
                    ? ''
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
                  borderRadius: BorderRadius.circular(30),
                ),
                primary: const Color(0xFFFFD600),
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
