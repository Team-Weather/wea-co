import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weaco/domain/user/model/user_profile.dart';

/// firebase에서 유저 프로필 정보를 읽고 쓰기 위한 데이터 소스
abstract interface class RemoteUserProfileDataSource {
  /// 유저 프로필 요청
  Future<UserProfile> getUserProfile({String email});

  /// 유저 프로필 업데이트 (피드 갯수 수정 할 때 주로 쓰임)
  Future<void> updateUserProfile({
    required Transaction transaction,
    required UserProfile userProfile,
  });

  /// 유저 프로필 저장
  Future<void> saveUserProfile({required UserProfile userProfile});

  /// 유저 프로필 삭제
  Future<void> removeUserProfile({String? email});
}
