import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_chat/data/repositories/authentication/index.dart';
import 'package:flutter_chat/services/http/index.dart';
import 'package:meta/meta.dart';

part 'event.dart';
part 'state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc({
    @required this.email,
    @required this.authenticationRepository,
  })  : assert(email != null),
        assert(authenticationRepository != null),
        super(const RegisterState());

  final String email;
  final AuthenticationRepository authenticationRepository;

  @override
  Stream<RegisterState> mapEventToState(RegisterEvent event) async* {
    if (event is RegisterPasswordChanged) {
      yield state.copyWith(password: event.password);
    } else if (event is RegisterSubmitted) {
      yield* _mapLoginSubmittedToState(state);
    }
  }

  Stream<RegisterState> _mapLoginSubmittedToState(RegisterState state) async* {
    if (state.password.isEmpty) {
      yield state.copyWith(status: RegisterStatus.initial);
      return;
    }

    yield state.copyWith(status: RegisterStatus.loading);
    try {
      await authenticationRepository.register(
        email: email,
        password: state.password,
      );
      yield state.copyWith(status: RegisterStatus.success);
    } on BadRequestException catch (e) {
      // final error = e.model as LoginBadRequest;
      // print(
      //     'kir to requestet ba ina ${error.email ?? error.password ?? error.nonFieldErrors}');
      yield state.copyWith(status: RegisterStatus.failure);
    } on SocketException catch (_) {
      print('kir to netet');
      yield state.copyWith(status: RegisterStatus.failure);
    } on Exception catch (_) {
      yield state.copyWith(status: RegisterStatus.failure);
    }
  }
}
