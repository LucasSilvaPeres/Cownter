import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '/constants/constants.dart';

class LoadingPage extends StatefulWidget {
  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // CircularProgressIndicator(
        //   value: 1,
        //   backgroundColor: Theme.of(context).colorScheme.primary,
        // ),
        const SizedBox(
          height: 10,
        ),
        Lottie.asset('assets/images/loading.json', width: 300),
        Text(
          'Carregando...',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        )
      ],
    ));
  }
}
