import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier();
});

class AuthNotifier extends StateNotifier<User?> {
  AuthNotifier() : super(null);

  Future<bool> login(String username, String password) async {
    final user = await DatabaseService().getUser(username, password);
    if (user != null) {
      state = user;
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String password, {String? imagePath}) async {
    final exists = await DatabaseService().userExists(username);
    if (!exists) {
      final id = await DatabaseService().createUser(
        User(username: username, password: password, imagePath: imagePath),
      );
      if (id > 0) {
        state = User(id: id, username: username, password: password, imagePath: imagePath);
        return true;
      }
    }
    return false;
  }

  void logout() {
    state = null;
  }
}
