import 'package:dirm/services/api/rest_api.dart';

import 'package:dirm/services/storage/database_service.dart';
import 'package:dirm/util/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this.restApi, this.databaseService) : super(const LoginState());

  final RestApi restApi;
  final DatabaseService databaseService;

  void emailChanged(String email) {
    emit(state.copyWith(
        email: email, errorMessage: '', isloading: false, issuccess: false));
  }

  void passwordChanged(String password) {
    emit(state.copyWith(
        password: password,
        errorMessage: '',
        isloading: false,
        issuccess: false));
  }

  void loginWithCredentials() async {
    // validate email n pass
    if (!(isemail(state.email) && isPassword(state.password))) return;
    emit(state.copyWith(isloading: true, issuccess: false, errorMessage: ''));
    try {
      // log in to api
      final resultMap =
          await restApi.login(email: state.email, password: state.password);
      // store user to local db
      await databaseService.saveUser(resultMap['user']);
      // store user token to db
      await databaseService.saveToken(resultMap['token']);
      emit(state.copyWith(isloading: false, issuccess: true, errorMessage: ''));
    } catch (e) {
      print('log in error: ${e.toString()}');
      emit(state.copyWith(
          isloading: false, errorMessage: e.toString(), issuccess: false));
    }
  }
}

bool isemail(String e) {
  return RegExp(emailRegex).hasMatch(e);
}

bool isPassword(String pass) {
  return pass.isNotEmpty ? true : false;
}
