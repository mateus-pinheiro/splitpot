import 'dart:async';

import 'package:decimal/decimal.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/network/api_exception.dart';
import '../../domain/entities/user_summary.dart';
import '../../domain/usecases/usecases.dart';

/// Cubit usado pela `AddPlayerView`. Mantém o estado da busca por usuários
/// cadastrados (com debounce) e o status de submissão (guest ou registered).
/// A view gerencia o modo selecionado e os controllers de formulário; o
/// cubit só faz I/O.
class AddPlayerCubit extends Cubit<AddPlayerState> {
  AddPlayerCubit({
    required SearchUsers searchUsers,
    required AddGuestPlayer addGuest,
    required AddRegisteredPlayer addRegistered,
  })  : _searchUsers = searchUsers,
        _addGuest = addGuest,
        _addRegistered = addRegistered,
        super(const AddPlayerState.idle());

  final SearchUsers _searchUsers;
  final AddGuestPlayer _addGuest;
  final AddRegisteredPlayer _addRegistered;

  Timer? _searchDebounce;

  void search(String query) {
    _searchDebounce?.cancel();
    final trimmed = query.trim();
    if (trimmed.length < 2) {
      emit(const AddPlayerState.idle());
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      emit(const AddPlayerState.searching());
      try {
        final results = await _searchUsers(trimmed);
        emit(AddPlayerState.searchResults(results));
      } on ApiException catch (e) {
        emit(AddPlayerState.error(e.failure));
      } on Object catch (e) {
        emit(AddPlayerState.error(Failure.unexpected(message: e.toString())));
      }
    });
  }

  Future<void> submitRegistered({
    required String tableId,
    required String userId,
    Decimal? initialBuyIn,
  }) async {
    if (state is AddPlayerSubmitting) return;
    emit(const AddPlayerState.submitting());
    try {
      final id = await _addRegistered(
        tableId: tableId,
        userId: userId,
        initialBuyIn: initialBuyIn,
      );
      emit(AddPlayerState.added(id));
    } on ApiException catch (e) {
      emit(AddPlayerState.error(e.failure));
    } on Object catch (e) {
      emit(AddPlayerState.error(Failure.unexpected(message: e.toString())));
    }
  }

  Future<void> submitGuest({
    required String tableId,
    required String name,
    required String pixKey,
    Decimal? initialBuyIn,
  }) async {
    if (state is AddPlayerSubmitting) return;
    emit(const AddPlayerState.submitting());
    try {
      final id = await _addGuest(
        tableId: tableId,
        name: name,
        pixKey: pixKey,
        initialBuyIn: initialBuyIn,
      );
      emit(AddPlayerState.added(id));
    } on ApiException catch (e) {
      emit(AddPlayerState.error(e.failure));
    } on Object catch (e) {
      emit(AddPlayerState.error(Failure.unexpected(message: e.toString())));
    }
  }

  void reset() => emit(const AddPlayerState.idle());

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}

sealed class AddPlayerState {
  const AddPlayerState();
  const factory AddPlayerState.idle() = AddPlayerIdle;
  const factory AddPlayerState.searching() = AddPlayerSearching;
  const factory AddPlayerState.searchResults(List<UserSummary> results) =
      AddPlayerSearchResults;
  const factory AddPlayerState.submitting() = AddPlayerSubmitting;
  const factory AddPlayerState.added(String participationId) = AddPlayerAdded;
  const factory AddPlayerState.error(Failure failure) = AddPlayerError;
}

class AddPlayerIdle extends AddPlayerState {
  const AddPlayerIdle();
}

class AddPlayerSearching extends AddPlayerState {
  const AddPlayerSearching();
}

class AddPlayerSearchResults extends AddPlayerState {
  const AddPlayerSearchResults(this.results);
  final List<UserSummary> results;
}

class AddPlayerSubmitting extends AddPlayerState {
  const AddPlayerSubmitting();
}

class AddPlayerAdded extends AddPlayerState {
  const AddPlayerAdded(this.participationId);
  final String participationId;
}

class AddPlayerError extends AddPlayerState {
  const AddPlayerError(this.failure);
  final Failure failure;
}
