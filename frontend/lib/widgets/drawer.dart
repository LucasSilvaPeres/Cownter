import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cownter/constants/constants.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../utils/appRoutes.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(children: [
      Padding(
        padding:
            const EdgeInsets.only(bottom: 20, top: 30, left: 20, right: 20),
        child: SizedBox(
          width: 30,
          child: Image.asset('assets/images/logo300.png',
              width: 70, filterQuality: FilterQuality.high),
        ),
      ),
      const SizedBox(
        height: 40,
      ),
      const Divider(),
      ListTile(
        leading: const Icon(
          (Icons.home),
        ),
        title: const Text("Tela inicial", style: TextStyle(fontSize: 20)),
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.DASHBOARD_PRINCIPAL);
        },
      ),
      const Divider(),
      ListTile(
        leading: const Icon(
          (Icons.add_a_photo),
        ),
        title: const Text("Inserir Fotos", style: TextStyle(fontSize: 20)),
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.FORMFOTOS);
        },
      ),
      const Divider(),
      ListTile(
        leading: const Icon(
          (Icons.map),
        ),
        title: const Text("Piquetes", style: TextStyle(fontSize: 20)),
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.PIQUETES);
        },
      ),
      // ListTile(
      //   leading: Icon(
      //     (Icons.map_outlined),
      //   ),
      //   title: const Text("Mapa", style: TextStyle(fontSize: 20)),
      //   onTap: () {
      //     Navigator.of(context).pushNamed(AppRoutes.APPMAPS);
      //   },
      // ),
      // Divider(),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.arrow_circle_left_outlined),
        title: const Text(
          'Voltar',
          style: TextStyle(fontSize: 20),
        ),
        onTap: (() {
          Navigator.of(context).pop();
        }),
      ),
      const Divider(),
      // const Divider(),
      // ListTile(
      //   leading: Icon(
      //     (Icons.map_outlined),
      //   ),
      //   title: const Text("Mapa", style: TextStyle(fontSize: 20)),
      //   onTap: () {
      //     Navigator.of(context).pushNamed(AppRoutes.APPMAPS);
      //   },
      // ),
      const SizedBox(
        height: 50,
      ),
      const Divider(),
      ListTile(
        leading: const Icon(Icons.logout),
        title: const Text(
          'Sair - Logout',
          style: TextStyle(fontSize: 20),
        ),
        onTap: (() {
          AuthService().logout();
        }),
      ),
      const Divider(),
      const SizedBox(
        height: 50,
      ),
      ElevatedButton.icon(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(transparent),
          ),
          onPressed: () {
            AdaptiveTheme.of(context).setThemeMode(
                !AdaptiveTheme.of(context).mode.isDark
                    ? AdaptiveThemeMode.dark
                    : AdaptiveThemeMode.light);
          },
          label: AdaptiveTheme.of(context).isDefault
              ? const Text("Tema Claro")
              : const Text("Tema Escuro"),
          icon: Icon(AdaptiveTheme.of(context).isDefault
              ? Icons.light_mode
              : Icons.dark_mode)),
      const ListTile(
        leading: Icon(Icons.verified_sharp),
        title: Text(
          'v. 1.0.3',
          style: TextStyle(fontSize: 15),
        ),
      ),
    ]));
  }
}
