import 'package:freezed_annotation/freezed_annotation.dart';

part 'failure.freezed.dart';

/// Erros de negócio/infra expostos ao presentation.
///
/// Toda camada de dados deve converter exceções de baixo nível
/// (Dio, Firebase, Prisma, etc.) em um `Failure` antes de atravessar
/// a fronteira do domain.
@freezed
sealed class Failure with _$Failure {
  const factory Failure.unexpected({String? message}) = UnexpectedFailure;
  const factory Failure.network({String? message}) = NetworkFailure;
  const factory Failure.unauthorized({String? message}) = UnauthorizedFailure;
  const factory Failure.notFound({String? message}) = NotFoundFailure;
  const factory Failure.validation({required String message}) = ValidationFailure;
  const factory Failure.signInCancelled() = SignInCancelledFailure;
}
