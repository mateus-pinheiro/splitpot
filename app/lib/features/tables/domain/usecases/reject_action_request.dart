import '../repositories/action_requests_repository.dart';

class RejectActionRequest {
  const RejectActionRequest(this._repository);

  final ActionRequestsRepository _repository;

  Future<void> call(String requestId) => _repository.reject(requestId);
}
