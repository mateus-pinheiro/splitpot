import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/poker_table.dart';
import '../../domain/usecases/get_table.dart';

/// Mantém a mesa atualizada enquanto o host espera os convidados — faz
/// polling simples em `GET /tables/:id` a cada 2 s. Quando o backend
/// tiver push/WebSocket, esse cubit é o único lugar a tocar.
class QrCubit extends Cubit<QrState> {
  QrCubit(this._getTable) : super(const QrState.loading());

  final GetTable _getTable;
  static const _pollInterval = Duration(seconds: 2);

  Timer? _timer;
  String? _tableId;
  bool _fetching = false;

  void start(String tableId) {
    if (_tableId == tableId && _timer != null) return;
    _tableId = tableId;
    _timer?.cancel();
    emit(const QrState.loading());
    _fetch();
    _timer = Timer.periodic(_pollInterval, (_) => _fetch());
  }

  Future<void> _fetch() async {
    if (_fetching || _tableId == null) return;
    _fetching = true;
    try {
      final table = await _getTable(_tableId!);
      if (isClosed) return;
      emit(QrState.loaded(table));
    } on ApiException catch (e) {
      if (isClosed) return;
      // Se já temos dados, não derruba a UI — mantém o último loaded.
      if (state is! QrStateLoaded) {
        emit(QrState.error(e.failure));
      }
    } finally {
      _fetching = false;
    }
  }

  @override
  Future<void> close() async {
    _timer?.cancel();
    return super.close();
  }
}

sealed class QrState {
  const QrState();
  const factory QrState.loading() = QrStateLoading;
  const factory QrState.loaded(PokerTable table) = QrStateLoaded;
  const factory QrState.error(Failure failure) = QrStateError;
}

class QrStateLoading extends QrState {
  const QrStateLoading();
}

class QrStateLoaded extends QrState {
  const QrStateLoaded(this.table);
  final PokerTable table;
}

class QrStateError extends QrState {
  const QrStateError(this.failure);
  final Failure failure;
}
