import 'package:dirm/services/firebase/auth_service.dart';
import 'package:dirm/services/firebase/exceptions.dart';
import 'package:dirm/util/constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:equatable/equatable.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authService) : super(const LoginState());

  final AuthService _authService;

  void emailChanged(String email) {
    emit(state.copyWith(email: email));
  }

  void passwordChanged(String password) {
    emit(
      state.copyWith(password: password),
    );
  }

  void loginWithCredentials() async {
    // validate email n pass
    if (!(isemail(state.email) && isPassword(state.password))) return;
    emit(state.copyWith(isloading: true, issuccess: false, errorMessage: ''));
    // log in user
    try {
      await _authService.logInWithEmailAndPassword(
          email: state.email, password: state.password);
      emit(state.copyWith(isloading: false, issuccess: true, errorMessage: ''));
    } on LogInWithEmailAndPasswordFailure catch (e) {
      emit(
        state.copyWith(
            isloading: false, errorMessage: e.message, issuccess: false),
      );
    } catch (e) {
      emit(state.copyWith(
          isloading: false, errorMessage: e.toString(), issuccess: false));
    }
  }

  void loginWithGoogle() async {
    emit(state.copyWith(isloading: true, issuccess: false, errorMessage: ''));
    // try log in user
    try {
      await _authService.logInWithGoogle();
      emit(state.copyWith(isloading: false, issuccess: true, errorMessage: ''));
    } on LogInWithGoogleFailure catch (e) {
      emit(state.copyWith(
          isloading: false, errorMessage: e.toString(), issuccess: false));
    } catch (e) {
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
