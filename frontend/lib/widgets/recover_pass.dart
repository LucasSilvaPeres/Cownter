import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/constants/constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  static const String id = 'reset_password';
  final void Function() onRecovered;
  const ResetPasswordScreen({Key? key, required this.onRecovered})
      : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _key = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  static final auth = FirebaseAuth.instance;
  static late AuthStatus _status;

  bool loading = false;

  void _onRecovered() {
    widget.onRecovered();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<AuthStatus> resetPassword({required String email}) async {
    await auth
        .sendPasswordResetEmail(email: email)
        .then((value) => _status = AuthStatus.successful)
        .catchError(
            (e) => _status = AuthExceptionHandler.handleAuthException(e));

    return _status;
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      child: Padding(
        padding: const EdgeInsets.all(
          8.0,
        ),
        child: Form(
          key: _key,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Esqueceu a senha?",
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Por favor, entre com seu e-mail para criar outra senha.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'E-mail',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                child: TextFormField(
                  obscureText: false,
                  controller: _emailController,
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains("@")) {
                      return 'E-mail inválido';
                    }
                    return null;
                  },
                  autofocus: false,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey),
                  decoration: const InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30.0))),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          30.0,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          30.0,
                        ),
                      ),
                    ),

                    isDense: true,
                    // fillColor: kPrimaryColor,
                    filled: true,
                    errorStyle: TextStyle(fontSize: 15),
                    hintText: 'E-mail',
                    hintStyle: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: MediaQuery.of(context).size.height / 20,
                child: Material(
                  elevation: 2,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.green,
                  child: !loading
                      ? MaterialButton(
                          onPressed: () async {
                            if (_key.currentState!.validate()) {
                              setState(() {
                                loading = true;
                              });
                              final _status = await resetPassword(
                                  email: _emailController.text.trim());
                              if (_status == AuthStatus.successful) {
                                //your logic
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                      content: Text(
                                        "E-mail de recuperação enviado com sucesso!",
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.white),
                                      ),
                                      backgroundColor: transparent,
                                    ))
                                    .closed
                                    .then((SnackBarClosedReason sc) {
                                  _onRecovered();
                                });
                              } else {
                                //your logic or show snackBar with error message
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                      content: const Text(
                                          "Um erro ocorreu, email inválido ou não encontrado"),
                                      backgroundColor:
                                          Theme.of(context).errorColor,
                                    ))
                                    .closed
                                    .then(
                                      (value) => setState(() {
                                        loading = false;
                                      }),
                                    );
                              }
                            }
                          },
                          minWidth: double.infinity,
                          child: const Text(
                            'Recuperar Senha',
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                fontFamily: 'Poppins'),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [CircularProgressIndicator()],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum AuthStatus {
  successful,
  wrongPassword,
  emailAlreadyExists,
  invalidEmail,
  weakPassword,
  unknown,
}

class AuthExceptionHandler {
  static handleAuthException(FirebaseAuthException e) {
    AuthStatus status;
    switch (e.code) {
      case "invalid-email":
        status = AuthStatus.invalidEmail;
        break;
      case "wrong-password":
        status = AuthStatus.wrongPassword;
        break;
      case "weak-password":
        status = AuthStatus.weakPassword;
        break;
      case "email-already-in-use":
        status = AuthStatus.emailAlreadyExists;
        break;
      default:
        status = AuthStatus.unknown;
    }
    return status;
  }

  static String generateErrorMessage(error) {
    String errorMessage;
    switch (error) {
      case AuthStatus.invalidEmail:
        errorMessage = "Your email address appears to be malformed.";
        break;
      case AuthStatus.weakPassword:
        errorMessage = "Your password should be at least 6 characters.";
        break;
      default:
        errorMessage = "";
        break;
    }
    return errorMessage;
  }
}
