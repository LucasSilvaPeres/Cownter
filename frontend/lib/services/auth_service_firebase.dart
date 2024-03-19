import 'dart:async';
import '../dtos/user_model.dart';
//import 'api_service_http.dart';
import 'auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthFirebaseService implements AuthService {
  static UserModel? _currentUser;

  static final _userStream = Stream<UserModel?>.multi((controller) async {
    final AuthChanges = FirebaseAuth.instance.authStateChanges();

    await for (final user in AuthChanges) {
      _currentUser = user == null ? null : _toSeniorUser(user);
      controller.add(_currentUser);
    }
  });

  UserModel? get currentUser {
    return _currentUser;
  }

  Stream<UserModel?> get userChanges {
    return _userStream;
  }

  Future<void> signup(
      String nome,
      String email,
      String password,
      String namefazenda,
      String contato,
      String numerocabecas,
      String enderecofazenda,
      String municipiofazenda,
      String estadofazenda) async {
    try {
      final auth = FirebaseAuth.instance;

      // ApiServiceHttp api_service = ApiServiceHttp();

      // bool isValidUser = await api_service.validateUserInSignup(email);

      // if (!isValidUser) {
      //   throw ("Usuário não existe no Cownter");
      // }

      UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return;

      //upload da imagem.

      _currentUser = _toSeniorUser(credential.user!, nome);

      await _saveSeniorUser(_currentUser!, namefazenda, contato, numerocabecas,
              enderecofazenda, municipiofazenda, estadofazenda)
          .then(
            (value) => print('ok usuario'),
          )
          .onError(
            (error, stackTrace) => throw (error.toString()),
          );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw ('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        throw ('The account already exists for that email.');
      } else {
        throw (e.code);
      }
    } catch (error) {
      throw (error.toString());
    }
  }

  Future<void> login(
    String email,
    String password,
  ) async {
    try {
      // ApiServiceHttp apiService = ApiServiceHttp();

      UserCredential credential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String idToken = await credential.user!.getIdToken();
      String idUser = _currentUser!.id;

      print("Firebase Token:  $idToken ");

      //bool isValidUser =
      //    await apiService.validateUserInLogin(idUser, email, idToken);

      // if (!isValidUser) {
      //   await logout();
      //   throw ("Usuário não existe no Cownter");
      // }

      // await _saveSeniorUser(_currentUser!,)
      //     .then(
      //       (value) => {},
      //     )
      //     .onError(
      //       (error, stackTrace) => throw (error.toString()),
      //     );
      _currentUser = _toSeniorUser(credential.user!);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw ('Usuário não encontrado para e eMail informado.');
      } else if (e.code == 'wrong-password') {
        throw ('Senha incorreta.');
      } else {
        throw (e.code);
      }
    } catch (error) {
      throw (error.toString());
    }
  }

  Future<void> logout() async {
    FirebaseAuth.instance.signOut();
  }

  static UserModel _toSeniorUser(User user, [String? name, String? imageURL]) {
    if (name == null) {
      if (user.email != null) {
        if (user.email!.isNotEmpty) {
          if (user.email!.contains('@')) {
            name = user.email!.split('@')[0].toString();
          }
        }
      }
    }

    return UserModel(
      id: user.uid,
      name: name!,
      email: user.email ?? "Sem email",
    );
  }

  Future<void> _saveSeniorUser(
      UserModel user,
      String namefazenda,
      String contato,
      String numerocabecas,
      String enderecofazenda,
      String municipiofazenda,
      String estadofazenda) async {
    final store = FirebaseFirestore.instance;
    final docRef = store.collection('users').doc(user.id);

    return await docRef.get().then((value) {
      if (value.data() == null) {
        docRef.set({
          'name': user.name,
          'email': user.email,
          'admin': [],
          'fazenda': namefazenda,
          'contato': contato,
          'numerocabecas': numerocabecas,
          'enderecofazenda': enderecofazenda,
          'municipiofazenda': municipiofazenda,
          'estadofazenda': estadofazenda
        });
      }
    });
  }
}
