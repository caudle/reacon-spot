import 'package:dirm/modal/user.dart';
import 'package:dirm/services/api/rest_api.dart';
import 'package:dirm/services/storage/database_service.dart';
import 'package:dirm/util/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({required this.restApi, required this.databaseService})
      : super(const RegisterState()) {
    on<NameChanged>(_onName);
    on<EmailChanged>(_onEmail);
    on<PhoneChanged>(_onPhone);
    on<PasswordChanged>(_onPassword);
    on<ConfirmpasswordChanged>(_onConfirmpassword);
    on<RegisterWithEmailPressed>(_onRegisterWithEmail);
  }

  final RestApi restApi;
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

    if (isValid()) {
      try {
        // create user obj
        User user = createUserObj();
        // reg to api
        final resultMap = await restApi.register(user);

        // store user to local db
        await databaseService.saveUser(resultMap['user']);
        // store user token to db
        await databaseService.saveToken(resultMap['token']);
        //emit success state
        // remov loading
        emit(state.copyWith(
          isloading: false,
          issuccess: true,
        ));
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

  User createUserObj() {
    return User(
        userId: '',
        phone: state.phone!,
        email: state.email!,
        name: state.name!,
        password: state.password!,
        dp: '',
        isemailVerified: false,
        isphoneVerified: false,
        createdAt: DateTime.now(),
        type: 'buyer');
  }
}
