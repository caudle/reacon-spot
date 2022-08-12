part of 'register_bloc.dart';

@immutable
class RegisterState extends Equatable {
  final String? name;
  final bool isname;
  final String? email;
  final bool isemail;
  final String? phone;
  final bool isphone;
  final String? password;
  final bool ispassword;
  final String? confirmpassword;
  final bool ispasswordMatch;
  final bool isloading;
  final bool issuccess;
  final String? errrorMessage;
  const RegisterState({
    this.name,
    this.isname = false,
    this.email,
    this.isemail = false,
    this.phone,
    this.isphone = false,
    this.password,
    this.ispassword = false,
    this.confirmpassword,
    this.ispasswordMatch = false,
    this.isloading = false,
    this.issuccess = false,
    this.errrorMessage,
  });

  @override
  List<Object?> get props {
    return [
      name,
      isname,
      email,
      isemail,
      phone,
      isphone,
      password,
      ispassword,
      confirmpassword,
      ispasswordMatch,
      isloading,
      issuccess,
      errrorMessage,
    ];
  }

  RegisterState copyWith({
    String? name,
    bool? isname,
    String? email,
    bool? isemail,
    String? phone,
    bool? isphone,
    String? password,
    bool? ispassword,
    String? confirmpassword,
    bool? ispasswordMatch,
    bool? isloading,
    bool? issuccess,
    String? errrorMessage,
  }) {
    return RegisterState(
      name: name ?? this.name,
      isname: isname ?? this.isname,
      email: email ?? this.email,
      isemail: isemail ?? this.isemail,
      phone: phone ?? this.phone,
      isphone: isphone ?? this.isphone,
      password: password ?? this.password,
      ispassword: ispassword ?? this.ispassword,
      confirmpassword: confirmpassword ?? this.confirmpassword,
      ispasswordMatch: ispasswordMatch ?? this.ispasswordMatch,
      isloading: isloading ?? this.isloading,
      issuccess: issuccess ?? this.issuccess,
      errrorMessage: errrorMessage,
    );
  }
}
