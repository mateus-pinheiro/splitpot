import '../repositories/action_requests_repository.dart';

class ApproveActionRequest {
  const ApproveActionRequest(this._repository);

  final ActionRequestsRepository _repository;

  Future<void> call(String requestId) => _repository.approve(requestId);
}
