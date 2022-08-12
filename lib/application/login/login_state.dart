// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'login_cubit.dart';

class LoginState extends Equatable {
  final String email;
  final String password;
  final bool isloading;
  final bool issuccess;
  final String errorMessage;
  const LoginState({
    this.email = '',
    this.password = '',
    this.errorMessage = '',
    this.isloading = false,
    this.issuccess = false,
  });

  @override
  List<Object> get props =>
      [email, password, errorMessage, isloading, issuccess];

  LoginState copyWith({
    String? email,
    String? password,
    String? errorMessage,
    bool? isloading,
    bool? issuccess,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      errorMessage: errorMessage ?? this.errorMessage,
      isloading: isloading ?? this.isloading,
      issuccess: issuccess ?? this.issuccess,
    );
  }
}
