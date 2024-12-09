// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:go/firebase_options.dart';
import 'package:go/modules/homepage/homepage_bloc.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/homepage/home_page.dart';
import 'package:go/modules/auth/log_in_screen.dart';
import 'package:go/modules/auth/sign_up_screen.dart';
import 'package:responsive_framework/responsive_framework.dart';
// import 'package:/share/share.dart';
import 'constants/constants.dart' as Constants;
import 'package:flutter/material.dart';
import 'package:go/modules/auth/auth_provider.dart';
import 'package:go/modules/auth/sign_in_screen.dart';
import 'package:provider/provider.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_database/firebase_database.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SignalRProvider(),
      builder: (context, child) => MultiProvider(
        providers: [
          Provider(
              create: (context) =>
                  AuthProvider(context.read<SignalRProvider>())),
        ],
        builder: (context, child) => MaterialApp(
          builder: (context, child) => responsiveWidgetSetup(context, child),
          debugShowCheckedModeBanner: false,
          home: initialPage(),
          theme: themeData(),
          routes: routeConstructor,
        ),
      ),
    );
  }

  Widget initialPage() => const SignIn();

  Widget responsiveWidgetSetup(BuildContext context, Widget? child) =>
      SafeArea(
        child: ResponsiveBreakpoints.builder(
          child: child!,
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
      );

  ThemeData? themeData() {
    return Constants.lightTheme;
    // return ThemeData.light();
    // return null;
    // return ThemeData(
    //   // Define the default brightness and colors.
    //   brightness: Brightness.dark,
    //   primaryColor: Colors.red[800],

    //   textButtonTheme: TextButtonThemeData(
    //     style: ButtonStyle(
    //       foregroundColor: WidgetStateProperty.all<Color>(
    //           Constants.defaultTheme.mainTextColor),
    //     ),
    //   ),

    //   buttonTheme: ButtonThemeData(
    //     buttonColor: Constants.defaultTheme.mainHighlightColor,
    //   ),
    // );
  }

  Map<String, WidgetBuilder> get routeConstructor {
    return <String, WidgetBuilder>{
      '/HomePage': (BuildContext context) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => HomepageBloc(
                  signalRProvider: context.read(), authBloc: context.read()),
            ),
            // ChangeNotifierProvider(create: (context) => signalR),
          ],
          builder: (context, child) => const HomePage(),
        );
      },
      '/SignUp': (BuildContext context) => const SignUpScreen(),
      '/LogIn': (BuildContext context) => const LogInScreen(),
      // '/CreateGame': (BuildContext context) => MultiProvider(
      //       providers: [
      //         ChangeNotifierProvider(
      //             create: (context) => context.read<SignalRProvider>()),
      //         Provider(
      //           create: (context) => CreateGameProvider(),
      //         ),
      //       ],
      //       builder: (context, child) => CreateGameScreen(),
      //     ),
    };
  }
}
