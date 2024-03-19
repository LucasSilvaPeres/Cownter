import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/auth_form.dart';
import '/services/auth_service_firebase.dart';
import 'splash_screen.dart';

import '../dtos/auth_models.dart';
import '../services/auth_service.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLoading = false;
  Future<void> _handleSubmit(AuthFormData formData) async {
    try {
      setState(() => isLoading = true);

      if (formData.isLogin) {
        await AuthService().login(formData.email, formData.password);
      } else {
        try {
          await AuthService().signup(
              formData.name,
              formData.email,
              formData.password,
              formData.namefazenda,
              formData.contato,
              formData.numerocabecas,
              formData.enderecofazenda,
              formData.municipiofazenda,
              formData.estadofazenda);
        } catch (e) {
          _showErrorDialog("Usuário Inválido para cadastro");
          Timer(Duration(seconds: 2), () {
            setState(() => isLoading = false);
          });
        }
      }
      //tratar o erro
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      //  setState(() => isLoading = false);
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/', (route) => false);
                    },
                    child: const Text('Fechar'))
              ],
              title: const Text('Ocorreu um Erro:'),
              content: Text(
                msg,
                style: const TextStyle(color: Colors.black),
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Theme.of(context).colorScheme.primary,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
              Color.fromRGBO(243, 108, 0, 1),
              Color.fromARGB(255, 169, 169, 169),
            ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
          ),
          SingleChildScrollView(
            child: (isLoading)
                ? const SplashScreen()
                : Column(
                    children: [
                      const Image(
                          image: AssetImage('assets/images/logo500.png'),
                          height: 100),
                      const SizedBox(
                        height: 10,
                      ),
                      //const Text("Administração Cownter"),
                      AuthForm(
                        onSubmit: _handleSubmit,
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
