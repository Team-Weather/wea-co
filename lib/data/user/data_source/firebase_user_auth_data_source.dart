import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/core/firebase/firebase_auth_service.dart';
import 'package:weaco/data/user/data_source/user_auth_data_source.dart';

class FirebaseUserAuthDataSourceImpl implements UserAuthDataSource {
  final FirebaseAuthService _firebaseService;

  const FirebaseUserAuthDataSourceImpl({
    required FirebaseAuthService firebaseService,
  }) : _firebaseService = firebaseService;

  // 회원가입
  @override
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseService.signUp(email: email, password: password);
    } catch (e) {
      log(e.toString(), name: 'FirebaseUserAuthDataSource.signUp()');
      throw _exceptionHandling(e);
    }
  }

  // 로그인
  @override
  Future<void> signIn({required String email, required String password}) async {
    try {
      await _firebaseService.signIn(email: email, password: password);
    } catch (e) {
      log(e.toString(), name: 'FirebaseUserAuthDataSource.signIn()');
      throw _exceptionHandling(e);
    }
  }

  // 로그아웃
  @override
  Future<void> logOut() async {
    try {
      await _firebaseService.logOut();
    } catch (e) {
      log(e.toString(), name: 'FirebaseUserAuthDataSource.logOut()');
      throw _exceptionHandling(e);
    }
  }

  // 회원탈퇴
  @override
  Future<void> signOut() async {
    try {
      await _firebaseService.signOut();
    } catch (e) {
      log(e.toString(), name: 'FirebaseUserAuthDataSource.signOut()');
      throw _exceptionHandling(e);
    }
  }

  @override
  String? signInCheck() {
    try {
      return _firebaseService.user?.email;
    } catch (e) {
      throw _exceptionHandling(e);
    }
  }

  ExceptionCode _exceptionHandling(Object e) {
    return switch (e) {
      FirebaseException fb => ExceptionCode.fromStatus(fb.code),
      DioException _ => ExceptionCode.internalServerException,
      _ => ExceptionCode.unknownException,
    };
  }
}
