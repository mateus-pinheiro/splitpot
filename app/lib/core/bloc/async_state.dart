import 'package:freezed_annotation/freezed_annotation.dart';

import '../errors/failure.dart';

part 'async_state.freezed.dart';

/// Estado genérico para Cubits que carregam dados assíncronos.
///
/// Use quando o Cubit só tem o ciclo padrão "nada → carregando → dado|erro".
/// Para ciclos mais ricos (ex.: `AuthCubit` com vários estados de negócio),
/// defina um union próprio do Cubit.
@freezed
sealed class AsyncState<T> with _$AsyncState<T> {
  const factory AsyncState.initial() = AsyncInitial<T>;
  const factory AsyncState.loading() = AsyncLoading<T>;
  const factory AsyncState.success(T data) = AsyncSuccess<T>;
  const factory AsyncState.error(Failure failure) = AsyncError<T>;
}
