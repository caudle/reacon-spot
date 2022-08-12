import 'package:dirm/modal/user.dart';
import 'package:dirm/services/data/auth.dart';
import 'package:dirm/services/firebase/auth_service.dart';
import 'package:dirm/services/firebase/exceptions.dart';
import 'package:dirm/services/storage/database_service.dart';
import 'package:dirm/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc(
      {required this.authService,
      required this.auth,
      required this.databaseService})
      : super(const RegisterState()) {
    on<NameChanged>(_onName);
    on<EmailChanged>(_onEmail);
    on<PhoneChanged>(_onPhone);
    on<PasswordChanged>(_onPassword);
    on<ConfirmpasswordChanged>(_onConfirmpassword);
    on<RegisterWithEmailPressed>(_onRegisterWithEmail);
  }
  final AuthService authService;
  final Auth auth;
  final DatabaseService databaseService;

  void _onName(NameChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(
      name: event.name,
      isname: isname(event.name),
      errrorMessage: null,
      issuccess: false,
    ));
  }

  void _onEmail(EmailChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(
      email: event.email,
      isemail: isemail(event.email),
      errrorMessage: null,
      issuccess: false,
    ));
  }

  void _onPhone(PhoneChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(
      phone: event.phone,
      isphone: isphone(event.phone),
      errrorMessage: null,
      issuccess: false,
    ));
  }

  void _onPassword(PasswordChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(
      password: event.password,
      ispassword: ispassword(event.password),
      errrorMessage: null,
      issuccess: false,
    ));
  }

  void _onConfirmpassword(
      ConfirmpasswordChanged event, Emitter<RegisterState> emit) {
    emit(state.copyWith(
      confirmpassword: event.confirmpassword,
      ispasswordMatch: ispasswordMatch(event.confirmpassword),
      errrorMessage: null,
      issuccess: false,
    ));
  }

  void _onRegisterWithEmail(
      RegisterWithEmailPressed event, Emitter<RegisterState> emit) async {
    // loading state
    emit(state.copyWith(
      isloading: true,
      errrorMessage: null,
      issuccess: false,
    ));
    print('error from bloc: ${state.errrorMessage}');
    if (isValid()) {
      try {
        // reg to firebase
        final userCredential = await authService.signUpWithEmail(
            email: state.email!, password: state.password!);
        // create user obj
        User user = createUserObj(userCredential.user!.uid);
        // store user to firestore db
        await auth.createUser(userMap: user.toSnapshotMap(), uid: user.uid);
        // store user to local db
        await databaseService.saveUser(user);
        //emit success state
        // remov loading
        emit(state.copyWith(
          isloading: false,
          issuccess: true,
        ));
      } on SignUpWithEmailAndPasswordFailure catch (e) {
        // error state
        // remov loading
        print(e.message);
        emit(state.copyWith(isloading: false, errrorMessage: e.message));
      } catch (e) {
        print('registration error: ${e.toString()}');
        // error state
        // remov loading
        emit(state.copyWith(isloading: false, errrorMessage: e.toString()));
      }
    } else {
      // error state
      emit(
        state.copyWith(isloading: false, errrorMessage: 'invalid inputs'),
      );
    }
  }

  bool isValid() {
    return isname(state.name!) &&
        isemail(state.email!) &&
        isphone(state.phone!) &&
        ispassword(state.password!) &&
        ispasswordMatch(state.confirmpassword!);
  }

  bool isname(String name) {
    return name.isNotEmpty;
  }

  bool isemail(String email) {
    return RegExp(emailRegex).hasMatch(email);
  }

  bool isphone(String phone) {
    return phone.startsWith('0') && phone.length == 10;
  }

  bool ispassword(String password) {
    // password strength
    return password.length > 5;
  }

  bool ispasswordMatch(String confirmpassword) {
    // match pass
    return confirmpassword == state.password;
  }

  User createUserObj(String uid) {
    return User(
        uid: uid,
        phone: state.phone!,
        email: state.email!,
        name: state.name!,
        password: state.password!,
        dp: '',
        isEmailVerified: false,
        isPhoneVerified: false,
        createdAt: DateTime.now(),
        userType: 'buyer');
  }
}
