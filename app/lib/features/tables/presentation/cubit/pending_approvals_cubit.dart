import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/usecases/usecases.dart';

class PendingApprovalsCubit extends Cubit<PendingApprovalsState> {
  PendingApprovalsCubit({
    required ApproveActionRequest approveActionRequest,
    required RejectActionRequest rejectActionRequest,
  })  : _approve = approveActionRequest,
        _reject = rejectActionRequest,
        super(const PendingApprovalsState.idle());

  final ApproveActionRequest _approve;
  final RejectActionRequest _reject;

  Future<void> approve(String requestId) async {
    emit(PendingApprovalsState.loading(requestId));
    try {
      await _approve(requestId);
      emit(PendingApprovalsState.done(requestId));
    } on ApiException catch (e) {
      emit(PendingApprovalsState.error(requestId, e.failure));
    }
  }

  Future<void> reject(String requestId) async {
    emit(PendingApprovalsState.loading(requestId));
    try {
      await _reject(requestId);
      emit(PendingApprovalsState.done(requestId));
    } on ApiException catch (e) {
      emit(PendingApprovalsState.error(requestId, e.failure));
    }
  }

  void reset() => emit(const PendingApprovalsState.idle());
}

sealed class PendingApprovalsState {
  const PendingApprovalsState();
  const factory PendingApprovalsState.idle() = PendingApprovalsIdle;
  const factory PendingApprovalsState.loading(String requestId) =
      PendingApprovalsLoading;
  const factory PendingApprovalsState.done(String requestId) =
      PendingApprovalsDone;
  const factory PendingApprovalsState.error(String requestId, Failure failure) =
      PendingApprovalsError;
}

class PendingApprovalsIdle extends PendingApprovalsState {
  const PendingApprovalsIdle();
}

class PendingApprovalsLoading extends PendingApprovalsState {
  const PendingApprovalsLoading(this.requestId);
  final String requestId;
}

class PendingApprovalsDone extends PendingApprovalsState {
  const PendingApprovalsDone(this.requestId);
  final String requestId;
}

class PendingApprovalsError extends PendingApprovalsState {
  const PendingApprovalsError(this.requestId, this.failure);
  final String requestId;
  final Failure failure;
}
