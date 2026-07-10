import 'package:user_directory/data/api/api_client.dart';
import 'package:user_directory/data/models/user.dart';

class UserRepository {
  const UserRepository(this._apiClient);
  final ApiClient _apiClient;

  Future<List<User>> getUsers() async {
    final json = await _apiClient.get('/users');

    final userJson = json['users'] as List<dynamic>;

    return userJson
        .map((user) => User.fromJson(user as Map<String, dynamic>))
        .toList();
  }

  Future<User> getUserById(int id) async {
    final json = await _apiClient.get('/users/$id');

    return User.fromJson(json);
  }
}
