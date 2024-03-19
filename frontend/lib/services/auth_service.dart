import '/dtos/user_model.dart';

import 'auth_service_firebase.dart';

abstract class AuthService {
  UserModel? get currentUser;

  Stream<UserModel?> get userChanges; // monitorar o login, logout, secao, etc.

  Future<void> signup(
      String nome,
      String email,
      String password,
      String namefazenda,
      String contato,
      String numerocabecas,
      String enderecofazenda,
      String municipiofazenda,
      String estadofazenda);

  Future<void> login(
    String email,
    String password,
  );

  Future<void> logout();

  factory AuthService() {
    return AuthFirebaseService();
    //return AuthMockService();
  }
}
