import 'package:weaco/domain/user/model/user_auth.dart';
import 'package:weaco/domain/user/model/user_profile.dart';

abstract interface class UserAuthRepository {
  Future<void> signIn({required UserAuth userAuth});

  Future<void> signUp({
    required UserAuth userAuth,
    required UserProfile userProfile,
  });

  Future<void> signOut();

  Future<void> logOut();

  String? signInCheck();
}
