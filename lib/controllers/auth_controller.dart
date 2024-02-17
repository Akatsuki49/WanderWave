import '/models/user_model.dart';

//will use firebase
class AuthController {
  Future<UserModel?> login(String email, String password) async {
    // Implement login logic
    // Return UserModel on successful login, null otherwise
    // For simplicity, return a hardcoded user for now
    return UserModel(id: '1', email: email);
  }

  Future<void> logout() async {
    // Implement logout logic
  }
}
