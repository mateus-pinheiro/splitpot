import 'dart:async';

import '../../domain/entities/sign_in_outcome.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

/// Implementação mock do [AuthRepository] para testes sem backend.
class MockAuthRepository implements AuthRepository {
  User? _currentUser;
  _PendingProfile? _pending;
  final StreamController<SignInOutcome> _outcomes =
      StreamController<SignInOutcome>.broadcast();

  @override
  Future<User?> getCurrentUser() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return _currentUser;
  }

  @override
  Future<void> startSignIn() async {
    await Future<void>.delayed(const Duration(seconds: 1));
    _pending = const _PendingProfile(
      id: 'mock-user-1',
      email: 'mateus@splitpot.app',
      name: 'Mateus Pinheiro',
    );
    _outcomes.add(const SignInNeedsProfile(suggestedName: 'Mateus Pinheiro'));
  }

  @override
  Stream<SignInOutcome> get signInOutcomes => _outcomes.stream;

  @override
  Future<User> updateProfile({
    required String name,
    required String pixKey,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final pending = _pending;
    if (pending == null) {
      throw StateError('updateProfile chamado sem um login prévio');
    }
    final user = User(
      id: pending.id,
      email: pending.email,
      name: name,
      pixKey: pixKey,
    );
    _currentUser = user;
    _pending = null;
    return user;
  }

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
    _pending = null;
  }
}

class _PendingProfile {
  const _PendingProfile({
    required this.id,
    required this.email,
    required this.name,
  });

  final String id;
  final String email;
  final String name;
}
