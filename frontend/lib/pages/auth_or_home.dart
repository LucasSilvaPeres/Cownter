import 'package:cownter/pages/dashboard_page.dart';
import 'package:cownter/pages/dashboard_principal_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../dtos/user_model.dart';
import '../services/auth_service.dart';
import 'checkemail.dart';
import 'auth_page.dart';
import 'emailconfirmado.dart';
import 'loading_page.dart';

class AuthOrHome extends StatefulWidget {
  const AuthOrHome({Key? key}) : super(key: key);

  @override
  State<AuthOrHome> createState() => _AuthOrHomeState();
}

class _AuthOrHomeState extends State<AuthOrHome> {
  final whiteList = [
    "mauricioiacovone@usinadecodigos.com.br",
    "valter.bortolin@coopercitrus.com.br",
    "iacovone50@gmail.com",
    "erika.olimpio@usinadecodigos.com.br",
    "paulo.apoloni@usinadecodigos.com.br",
    "lucas.peres@usinadecodigos.com.br",
    "vitor.gripa98@gmail.com",
    "vitor.silva@usinadecodigos.com.br",
    "kleberberti@gmail.com"
  ];
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<UserModel?>(
      stream: AuthService().userChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingPage();
        } else {
          return !snapshot.hasData
              ? const AuthPage()
              : !FirebaseAuth.instance.currentUser!.emailVerified
                  ? const EmailVerificationScreen()
                  : whiteList.contains(AuthService().currentUser!.email)
                      ? const DashboardPrincipalPage()
                      : const EmailConfirmado();
        }
      },
    );
  }
}
