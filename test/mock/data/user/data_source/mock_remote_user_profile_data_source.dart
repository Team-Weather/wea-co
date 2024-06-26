import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:weaco/data/user/data_source/remote_user_profile_data_source.dart';
import 'package:weaco/domain/user/model/user_profile.dart';

class MockRemoteUserProfileDataSourceImpl
    implements RemoteUserProfileDataSource {
  int getUserProfileMethodCallCount = 0;
  int updateUserProfileMethodCallCount = 0;
  int saveUserProfileMethodCallCount = 0;
  int removeUserProfileMethodCallCount = 0;
  UserProfile? getUserProfileResult;
  bool isRemoved = false;
  bool isSaved = false;
  bool isUpdated = false;

  UserProfile? methodUserProfileParameter;
  String? methodEmailParameter;

  void initMockData() {
    getUserProfileMethodCallCount = 0;
    updateUserProfileMethodCallCount = 0;
    saveUserProfileMethodCallCount = 0;
    removeUserProfileMethodCallCount = 0;
    getUserProfileResult = null;
    isRemoved = false;
    isSaved = false;
    isUpdated = false;
    methodUserProfileParameter = null;
    methodEmailParameter = null;
  }

  @override
  Future<UserProfile> getUserProfile({String? email}) {
    getUserProfileMethodCallCount++;
    methodEmailParameter = email;
    return Future.value(getUserProfileResult);
  }

  @override
  Future<bool> updateUserProfile({
    required Transaction transaction,
    UserProfile? userProfile,
  }) async {
    updateUserProfileMethodCallCount++;
    methodUserProfileParameter = userProfile;
    return isUpdated;
  }

  @override
  Future<bool> saveUserProfile({required UserProfile userProfile}) async {
    saveUserProfileMethodCallCount++;
    methodUserProfileParameter = userProfile;
    return isSaved;
  }

  @override
  Future<bool> removeUserProfile({String? email}) async {
    removeUserProfileMethodCallCount++;
    methodEmailParameter = email;
    return isRemoved;
  }
}
