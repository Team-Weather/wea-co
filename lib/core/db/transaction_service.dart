abstract interface class TransactionService {
  Future<void> run(Function callBack);
}
