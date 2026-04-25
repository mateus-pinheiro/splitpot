import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/usecases/get_table.dart';

/// Mantém a mesa ao vivo atualizada com polling em `GET /tables/:id`.
/// Mesma estratégia do QrCubit — quando tivermos WebSocket, é o único
/// arquivo a mexer.
class LiveCubit extends Cubit<LiveState> {
  LiveCubit(this._getTable) : super(const LiveState.loading());

  final GetTable _getTable;
  static const _pollInterval = Duration(seconds: 10);

  Timer? _timer;
  String? _tableId;
  bool _fetching = false;

  void start(String tableId) {
    if (_tableId == tableId && _timer != null) return;
    _tableId = tableId;
    _timer?.cancel();
    emit(const LiveState.loading());
    _fetch();
    _timer = Timer.periodic(_pollInterval, (_) => _fetch());
  }

  Future<void> refresh() => _fetch();

  Future<void> _fetch() async {
    if (_fetching || _tableId == null) return;
    _fetching = true;
    try {
      final table = await _getTable(_tableId!);
      if (isClosed) return;
      emit(LiveState.loaded(table));
    } on ApiException catch (e) {
      if (isClosed) return;
      // Não derruba a UI se já temos dados — apenas mantém o último
      // snapshot até o próximo poll bem-sucedido.
      if (state is! LiveStateLoaded) {
        emit(LiveState.error(e.failure));
      }
    } finally {
      _fetching = false;
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}

sealed class LiveState {
  const LiveState();
  const factory LiveState.loading() = LiveStateLoading;
  const factory LiveState.loaded(PokerTable table) = LiveStateLoaded;
  const factory LiveState.error(Failure failure) = LiveStateError;
}

class LiveStateLoading extends LiveState {
  const LiveStateLoading();
}

class LiveStateLoaded extends LiveState {
  const LiveStateLoaded(this.table);
  final PokerTable table;
}

class LiveStateError extends LiveState {
  const LiveStateError(this.failure);
  final Failure failure;
}
