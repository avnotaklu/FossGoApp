// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:go/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:go/modules/homepage/homepage_bloc.dart';
import 'package:go/modules/auth/signalr_bloc.dart';
import 'package:go/modules/homepage/home_page.dart';
import 'package:go/modules/auth/log_in_screen.dart';
import 'package:go/modules/auth/sign_up_screen.dart';
import 'package:go/modules/settings/settings_page.dart';
import 'package:go/modules/settings/settings_provider.dart';
import 'package:go/services/api.dart';
import 'package:go/services/local_datasource.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
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
  if (!kIsWeb) {
    final dir = await getApplicationDocumentsDirectory();
    Hive.init(dir.path);
  } else {
    Hive.init(null);
  }

  (await Hive.openBox<String>('stats'));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (context) => Api(),
        builder: (context, child) => ChangeNotifierProvider(
              create: (context) => SignalRProvider(context.read<Api>()),
              builder: (context, child) => MultiProvider(
                providers: [
                  Provider(
                    create: (context) => AuthProvider(
                      context.read<SignalRProvider>(),
                      LocalDatasource(),
                      context.read<Api>(),
                    ),
                  ),
                  ChangeNotifierProvider(
                      create: (context) => SettingsProvider(
                            localDatasource: LocalDatasource(),
                          )..setup()),
                ],
                builder: (context, child) {
                  return FutureBuilder(
                      future: context.read<AuthProvider>().initialAuth.future,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        var res = snapshot.data!;
                        return Consumer<SettingsProvider>(
                          builder: (context, settingsProvider, child) =>
                              MaterialApp(
                            darkTheme: Constants.darkTheme,
                            builder: (context, child) =>
                                responsiveWidgetSetup(context, child),
                            debugShowCheckedModeBanner: false,
                            initialRoute: res.fold(
                              (l) => "/Root",
                              (r) => r == null ? "/Root" : "/HomePage",
                            ),
                            themeMode: settingsProvider.themeSetting.themeMode,
                            theme: Constants.lightTheme,
                            routes: routeConstructor,
                          ),
                        );
                      });
                },
              ),
            ));
  }

  Widget responsiveWidgetSetup(BuildContext context, Widget? child) => SafeArea(
        child: ResponsiveBreakpoints.builder(
          child: Builder(builder: (context) => child!),
          breakpoints: [
            const Breakpoint(start: 0, end: 450, name: MOBILE),
            const Breakpoint(start: 451, end: 800, name: TABLET),
            const Breakpoint(start: 801, end: 1920, name: DESKTOP),
            const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
          ],
        ),
      );

  ThemeData? themeData() {
    return Constants.darkTheme;
  }

  Map<String, WidgetBuilder> get routeConstructor {
    return <String, WidgetBuilder>{
      '/Root': (BuildContext context) {
        return responsiveWidgetSetup(context, const SignIn());
      },
      '/HomePage': (BuildContext context) {
        var widget = MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (context) => HomepageBloc(
                signalRProvider: context.read(),
                authBloc: context.read(),
                api: context.read(),
              ),
            ),
          ],
          builder: (context, child) => const HomePage(),
        );

        return responsiveWidgetSetup(context, widget);
      },
      '/SignUp': (BuildContext context) =>
          responsiveWidgetSetup(context, const SignUpScreen()),
      '/LogIn': (BuildContext context) =>
          responsiveWidgetSetup(context, const LogInScreen()),
      '/Settings': (BuildContext context) =>
          responsiveWidgetSetup(context, const SettingsPage()),
    };
  }
}
