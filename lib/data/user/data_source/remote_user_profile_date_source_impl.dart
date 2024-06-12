import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:weaco/core/enum/exception_code.dart';
import 'package:weaco/core/exception/internal_server_exception.dart';
import 'package:weaco/core/exception/network_exception.dart';
import 'package:weaco/core/firebase/firebase_auth_service.dart';
import 'package:weaco/core/firebase/firestore_dto_mapper.dart';
import 'package:weaco/data/user/data_source/remote_user_profile_data_source.dart';
import 'package:weaco/domain/user/model/user_profile.dart';

class RemoteUserProfileDataSourceImpl implements RemoteUserProfileDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuthService _firebaseService;

  const RemoteUserProfileDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseAuthService firebaseService,
  })  : _firestore = firestore,
        _firebaseService = firebaseService;

  @override
  Future<void> saveUserProfile({required UserProfile userProfile}) async {
    try {
      await _firestore
          .collection('user_profiles')
          .add(toUserProfileDto(userProfile: userProfile));
    } catch (e) {
      _exceptionHandling(e);
    }
  }

  @override
  Future<UserProfile> getUserProfile({String? email}) async {
    try {
      email = email ?? _firebaseService.firebaseAuth.currentUser!.email;

      QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('user_profiles')
          .where('email', isEqualTo: email)
          .get();

      return toUserProfile(json: snapshot.docs[0].data());
    } catch (e) {
      throw _exceptionHandling(e);
    }
  }

  @override
  Future<void> updateUserProfile({
    required Transaction transaction,
    required UserProfile userProfile,
  }) async {
    try {
      // 기존 프로필 문서를 검색
      final originProfileQuery = await _firestore
          .collection('user_profiles')
          .where('email', isEqualTo: userProfile.email)
          .get();

      if (originProfileQuery.docs.isEmpty) {
        throw Exception('User profile not found');
      }

      final originProfileDocRef = originProfileQuery.docs[0].reference;
      transaction.set(
          originProfileDocRef, toUserProfileDto(userProfile: userProfile));
    } catch (e) {
      _exceptionHandling(e);
    }
  }

  @override
  Future<void> removeUserProfile({String? email}) async {
    try {
      email = email ?? _firebaseService.firebaseAuth.currentUser!.email;

      final originProfileDocument = await _firestore
          .collection('user_profiles')
          .where('email', isEqualTo: email)
          .get();

      await _firestore
          .collection('user_profiles')
          .doc(originProfileDocument.docs[0].reference.id)
          .update({'deleted_at': Timestamp.now()});
    } catch (e) {
      _exceptionHandling(e);
    }
  }

  Exception _exceptionHandling(Object e) {
    switch (e.runtimeType) {
      case FirebaseException _:
        return InternalServerException(
            code: ExceptionCode.internalServerException, message: '서버 내부 오류');
      case DioException _:
        return NetworkException(
            code: ExceptionCode.internalServerException,
            message: '네트워크 오류 : $e');
      default:
        return Exception(e);
    }
  }
}
