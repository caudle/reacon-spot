part of 'register_bloc.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

class NameChanged extends RegisterEvent {
  final String name;
  const NameChanged(this.name);
  @override
  List<Object> get props => [name];
}

class EmailChanged extends RegisterEvent {
  final String email;
  const EmailChanged(this.email);
  @override
  List<Object> get props => [email];
}

class PhoneChanged extends RegisterEvent {
  final String phone;
  const PhoneChanged(this.phone);
  @override
  List<Object> get props => [phone];
}

class PasswordChanged extends RegisterEvent {
  final String password;
  const PasswordChanged(this.password);
  @override
  List<Object> get props => [password];
}

class ConfirmpasswordChanged extends RegisterEvent {
  final String confirmpassword;
  const ConfirmpasswordChanged(this.confirmpassword);
  @override
  List<Object> get props => [confirmpassword];
}

class RegisterWithEmailPressed extends RegisterEvent {}
