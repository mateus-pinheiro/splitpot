import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../errors/failure.dart';
import 'async_state.dart';

/// Builder padronizado para Cubits que expõem [AsyncState].
///
/// Obriga o consumer a tratar cada ramo da união, evitando UIs incompletas
/// que esquecem do estado de erro/loading.
class AsyncBlocBuilder<C extends StateStreamable<AsyncState<T>>, T> extends StatelessWidget {
  const AsyncBlocBuilder({
    required this.onSuccess,
    this.onInitial,
    this.onLoading,
    this.onError,
    super.key,
  });

  final Widget Function(BuildContext context, T data) onSuccess;
  final Widget Function(BuildContext context)? onInitial;
  final Widget Function(BuildContext context)? onLoading;
  final Widget Function(BuildContext context, Failure failure)? onError;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<C, AsyncState<T>>(
      builder: (context, state) {
        return switch (state) {
          AsyncInitial<T>() => onInitial?.call(context) ?? const SizedBox.shrink(),
          AsyncLoading<T>() => onLoading?.call(context) ?? const _DefaultLoading(),
          AsyncSuccess<T>(:final data) => onSuccess(context, data),
          AsyncError<T>(:final failure) =>
            onError?.call(context, failure) ?? _DefaultError(failure: failure),
        };
      },
    );
  }
}

class _DefaultLoading extends StatelessWidget {
  const _DefaultLoading();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2.5),
      ),
    );
  }
}

class _DefaultError extends StatelessWidget {
  const _DefaultError({required this.failure});

  final Failure failure;

  @override
  Widget build(BuildContext context) {
    final message = switch (failure) {
      UnexpectedFailure(:final message) => message ?? 'Algo deu errado.',
      NetworkFailure(:final message) => message ?? 'Sem conexão.',
      UnauthorizedFailure(:final message) => message ?? 'Não autorizado.',
      NotFoundFailure(:final message) => message ?? 'Não encontrado.',
      ValidationFailure(:final message) => message,
      SignInCancelledFailure() => 'Login cancelado.',
    };
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(message, textAlign: TextAlign.center),
      ),
    );
  }
}
