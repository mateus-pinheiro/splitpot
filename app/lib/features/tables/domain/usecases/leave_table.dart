import '../repositories/participations_repository.dart';

class LeaveTable {
  const LeaveTable(this._repository);

  final ParticipationsRepository _repository;

  Future<void> call({required String participationId}) =>
      _repository.leaveTable(participationId: participationId);
}
