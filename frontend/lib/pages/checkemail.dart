import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../services/auth_service.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({Key? key}) : super(key: key);

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  bool isEmailVerified = false;
  Timer? timer;

  final store = FirebaseFirestore.instance;
  int quantosSegundos = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance.currentUser?.sendEmailVerification();
    timer = Timer.periodic(const Duration(seconds: 3), (_) {
      checkEmailVerified();
      setState(() {
        quantosSegundos++;
      });
    });
  }

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();

    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Email Successfully Verified")));
      timer?.cancel();
      Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
      // final DadosUser_model dadosUser = DadosUser_model();
      // dadosUser.userId = AuthService().currentUser!.id;
      // final docRef = store.collection('users').doc(dadosUser.userId);
      // return await docRef.get().then((value) {
      //   if (value.data() != null) {
      //     docRef.update({
      //       'checkedemail': true,
      //     });
      //     dadosUser.checkedEmail = true;
      //   }
      // });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = AuthService().currentUser!.email;
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: const [
                    Image(
                        image: AssetImage('assets/images/logo.png'),
                        height: 100),
                    SizedBox(
                      height: 10,
                    ),
                    Text("Bem Vindo ao Cownter"),
                  ],
                ),
                const SizedBox(height: 30),
                const Center(
                  child: Text(
                    'Confirme seu Email',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Center(
                    child: Text(
                      'Enviamos um e-mail para: ${FirebaseAuth.instance.currentUser!.email}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Lottie.asset('assets/images/checkemail.json', width: 200),
                const SizedBox(
                  height: 20,
                ),
                // const Center(child: CircularProgressIndicator()),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 32.0),
                  child: Center(
                    child: Text(
                      'Por favor, clique no link enviado para seu e-mail para entrar.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(height: 57),
                quantosSegundos > 5
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: ElevatedButton(
                          child: const Text('Resend'),
                          onPressed: () {
                            try {
                              FirebaseAuth.instance.currentUser
                                  ?.sendEmailVerification();
                            } catch (e) {
                              debugPrint('$e');
                            }
                          },
                        ),
                      )
                    : Container(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
