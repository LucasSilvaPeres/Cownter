import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:cownter/controllers/contagens_voo_modal_controller.dart';
import 'package:cownter/controllers/dashboard_controller.dart';
import 'package:cownter/controllers/dashboard_principal_controller.dart';
import 'package:cownter/controllers/form_fotos_controller.dart';
import 'package:cownter/pages/auth_or_home.dart';
import 'package:cownter/pages/dashboard_page.dart';
import 'package:cownter/pages/dashboard_principal_page.dart';
import 'package:cownter/pages/form_fotos.dart';
import 'package:cownter/pages/maps.dart';
import 'package:cownter/utils/appRoutes.dart';
import 'package:cownter/utils/custom_route.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants/constants.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load();
  
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  GetIt getIt = GetIt.I;

  getIt.registerSingleton<DashboardController>(DashboardController(),
      signalsReady: true);
  getIt.registerSingleton<FormFotosController>(FormFotosController(),
      signalsReady: true);
  getIt.registerSingleton<DashboardPrincipalController>(DashboardPrincipalController(),
      signalsReady: true);
  getIt.registerSingleton<ContagensVooModalController>(ContagensVooModalController(), signalsReady: true);

  FlutterNativeSplash.remove();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AdaptiveTheme(
      light: ThemeData.light().copyWith(
          scaffoldBackgroundColor: creamColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.black),
          canvasColor: snowColor,
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: primaryColor,
            tertiary: tertiaryColor,
            onPrimary: Colors.white,
            secondary: secondaryColor,
            onSecondary: Colors.black,
            error: Colors.red,
            onError: Colors.red,
            background: snowColor,
            onBackground: Colors.black,
            surface: Colors.orange,
            onSurface: Colors.orange,
          )),
      dark: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgColor,
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
            .apply(bodyColor: Colors.white),
        canvasColor: secondaryColor,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: primaryColor,
          tertiary: tertiaryColor,
          onPrimary: Colors.white,
          secondary: secondaryColor,
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.red,
          background: Colors.black,
          onBackground: snowColor,
          surface: Colors.orange,
          onSurface: Colors.orange,
        ),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CustomPageTransitionsBuilder(),
          TargetPlatform.iOS: CustomPageTransitionsBuilder(),
          TargetPlatform.windows: CustomPageTransitionsBuilder(),
        }),
      ),
      initial: AdaptiveThemeMode.light,
      builder: (theme, darkTheme) => MaterialApp(
        title: 'Cownter',
        theme: theme,
        darkTheme: darkTheme,
        debugShowCheckedModeBanner: false,
        //home:
        routes: {
          AppRoutes.AUTH_OR_HOME: (context) => const AuthOrHome(),
          AppRoutes.PIQUETES: (context) => const DashboardPage(),
          AppRoutes.FORMFOTOS: (context) => EnvioFotosScreen(),
          AppRoutes.APPMAPS: (context) => const AppMaps(),
          AppRoutes.DASHBOARD_PRINCIPAL: (contxt) => const DashboardPrincipalPage()
          // AppRoutes.EsqueceuSenha: (context) => const ResetPasswordScreen(),
        },
      ),
    );
  }
}
