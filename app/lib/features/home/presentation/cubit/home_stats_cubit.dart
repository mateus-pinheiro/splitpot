import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../../tables/domain/entities/user_stats.dart';
import '../../../tables/domain/usecases/get_user_stats.dart';

class HomeStatsCubit extends Cubit<HomeStatsState> {
  HomeStatsCubit(this._getUserStats) : super(const HomeStatsState.loading());

  final GetUserStats _getUserStats;

  Future<void> load() async {
    if (state is HomeStatsLoading == false) {
      emit(const HomeStatsState.loading());
    }
    try {
      final stats = await _getUserStats();
      emit(HomeStatsState.loaded(stats));
    } on ApiException catch (e) {
      emit(HomeStatsState.error(e.failure));
    } on Object catch (e) {
      emit(HomeStatsState.error(Failure.unexpected(message: e.toString())));
    }
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
