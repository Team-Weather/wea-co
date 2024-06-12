import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:weaco/core/db/transaction_service.dart';

class MockFirestoreServiceImpl implements TransactionService {
  final _fakeFirestore = FakeFirebaseFirestore();

  @override
  Future<void> run(Function callBack) async {
    await _fakeFirestore.runTransaction<void>((transaction) async {
      await callBack(transaction);
    }).then(
      (value) {
        return;
      },
      onError: (e) {
        // throw Exception('피드 업로드에 실패 하였습니다.');
        throw Exception('mockFireStore: $e');
      },
    );
  }
}
