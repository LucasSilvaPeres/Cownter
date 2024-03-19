import 'package:flutter/material.dart';

import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //color: const Color(0XFF121212),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset('assets/images/loading.json', width: 300),
          const SizedBox(
            height: 20,
          ),
          const CircularProgressIndicator(),
          const SizedBox(
            height: 20,
          ),
          const Text("Carregando...")
        ],
      ),
    );
  }
}
