import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:user_directory/provider/api_provider.dart';

import '../../data/models/user.dart';

class UserSearchController extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  void updateQuery(String query) {
    state = query;
  }

  void clear() {
    state = '';
  }
}

final userSearchControllerProvider =
    NotifierProvider<UserSearchController, String>(UserSearchController.new);

final filteredUsersProvider = Provider<List<User>>((ref) {
  final query = ref.watch(userSearchControllerProvider);

  final usersState = ref.watch(userControllerProvider);

  final users = usersState.value ?? [];

  final normalizedQuery = query.trim().toLowerCase();

  if (normalizedQuery.isEmpty) {
    return users;
  }

  return users.where((user) {
    final fullName = '${user.firstName} ${user.lastName}'.toLowerCase();

    final username = user.username.toLowerCase();
    final email = user.email.toLowerCase();

    return fullName.contains(normalizedQuery) ||
        username.contains(normalizedQuery) ||
        email.contains(normalizedQuery);
  }).toList();
});
