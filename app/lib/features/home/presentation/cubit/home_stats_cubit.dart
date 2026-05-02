import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../../tables/domain/entities/user_stats.dart';
import '../../../tables/domain/usecases/confirm_settlement.dart';
import '../../../tables/domain/usecases/get_user_stats.dart';

class HomeStatsCubit extends Cubit<HomeStatsState> {
  HomeStatsCubit(this._getUserStats, this._confirmSettlement)
      : super(const HomeStatsState.loading());

  final GetUserStats _getUserStats;
  final ConfirmSettlement _confirmSettlement;
  Timer? _pollingTimer;
  bool _isRefreshing = false;

  Future<void> load() => _refresh(showLoading: true);

  Future<void> refreshSilently() => _refresh(showLoading: false);

  void startPolling({Duration interval = const Duration(seconds: 5)}) {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(interval, (_) {
      unawaited(_refresh(showLoading: false));
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  Future<void> _refresh({required bool showLoading}) async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    if (showLoading && state is! HomeStatsLoading) {
      emit(const HomeStatsState.loading());
    }
    try {
      final stats = await _getUserStats();
      emit(HomeStatsState.loaded(stats));
    } on ApiException catch (e) {
      // Em polling silencioso, preserva o último estado carregado em caso de erro.
      if (showLoading || state is! HomeStatsLoaded) {
        emit(HomeStatsState.error(e.failure));
      }
    } on Object catch (e) {
      if (showLoading || state is! HomeStatsLoaded) {
        emit(HomeStatsState.error(Failure.unexpected(message: e.toString())));
      }
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> confirmDebt(String settlementId) async {
    await _confirmSettlement(settlementId);
    await load();
  }

  @override
  Future<void> close() {
    stopPolling();
    return super.close();
  }
}

sealed class HomeStatsState {
  const HomeStatsState();
  const factory HomeStatsState.loading() = HomeStatsLoading;
  const factory HomeStatsState.loaded(UserStats stats) = HomeStatsLoaded;
  const factory HomeStatsState.error(Failure failure) = HomeStatsError;
}

class HomeStatsLoading extends HomeStatsState {
  const HomeStatsLoading();
}

class HomeStatsLoaded extends HomeStatsState {
  const HomeStatsLoaded(this.stats);
  final UserStats stats;
}

class HomeStatsError extends HomeStatsState {
  const HomeStatsError(this.failure);
  final Failure failure;
}
