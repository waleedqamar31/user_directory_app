import 'dart:async';

import 'package:user_directory/data/api/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_directory/data/models/user.dart';
import 'package:user_directory/data/repository/user_repository.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);

  return UserRepository(apiClient);
});

final userControllerProvider =
    AsyncNotifierProvider<UserController, List<User>>(UserController.new);

class UserController extends AsyncNotifier<List<User>> {
  @override
  FutureOr<List<User>> build() async {
    final repository = ref.read(userRepositoryProvider);

    return repository.getUsers();
  }

  Future<void> refresh() async {
    final repository = ref.read(userRepositoryProvider);

    state = await AsyncValue.guard(repository.getUsers);
  }

  Future<void> retry() async {
    final repository = ref.read(userRepositoryProvider);

    state = const AsyncLoading();

    state = await AsyncValue.guard(repository.getUsers);
  }
}

final profileControllerProvider =
    AsyncNotifierProvider.family<ProfileController, User, int>(
      ProfileController.new,
    );

class ProfileController extends AsyncNotifier<User> {
  ProfileController(this.id);
  final int id;

  @override
  FutureOr<User> build() async {
    final repository = ref.read(userRepositoryProvider);

    return repository.getUserById(id);
  }

  Future<void> retry() async {
    ref.invalidateSelf();
  }
}
