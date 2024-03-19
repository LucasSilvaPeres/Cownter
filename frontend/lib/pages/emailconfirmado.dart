import 'package:cownter/widgets/start_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:html/parser.dart';
import 'package:lottie/lottie.dart';

import '../services/auth_service.dart';

class EmailConfirmado extends StatefulWidget {
  const EmailConfirmado({super.key});

  @override
  State<EmailConfirmado> createState() => _EmailConfirmadoState();
}

class _EmailConfirmadoState extends State<EmailConfirmado> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // do something
    Future.delayed(
        const Duration(milliseconds: 10000), () => AuthService().logout());
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
                    'Obrigado pelo seu cadastro, seu email foi confirmado!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Center(
                    child: Text(
                      'Entraremos em contato para finalizar seu cadastro.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Lottie.asset('assets/images/loading.json', width: 200),
                const SizedBox(
                  height: 20,
                ), // const Center(child: CircularProgressIndicator()),
                // Padding(
                //   padding: const EdgeInsets.symmetric(horizontal: 32.0),
                //   child: Center(
                //       child: StartButton(
                //     title: "Efetuar logoff do sistema!",
                //     action: () => AuthService().logout(),
                //     color: Colors.black,
                //   )),
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
