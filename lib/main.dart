import 'package:card_app/auth/register_card.dart';
import 'package:card_app/auth/reset-password.dart';
import 'package:card_app/models/insuree.dart';
import 'package:card_app/models/user_location.dart';
import 'package:card_app/theme/dark_theme_provider.dart';
import 'package:card_app/theme/dark_theme_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:card_app/auth/auth.dart';
import 'package:card_app/blocks/auth_block.dart';
import 'package:card_app/services/app_state.dart';
import 'package:card_app/services/linked_card_state.dart';
import 'package:card_app/card/card_page.dart';
import 'package:card_app/ui/splash_screen.dart';
import 'package:card_app/services/bottom_nav_bar_service.dart';
import 'package:card_app/auth/login_card.dart';
import 'package:card_app/card/add_card.dart'; 
import 'package:card_app/profile/profile_main.dart';
import 'package:card_app/profile/pages/profile_info.dart';
import 'card/sync.dart';
import 'package:card_app/auth/validate_otp_card.dart';
import 'package:card_app/services/location_service.dart';

import 'localization/locale_constant.dart';
import 'localization/localizations_delegate.dart';
import 'package:graphql/client.dart';
import 'package:card_app/auth/verify_insuree.dart';
import 'package:card_app/models/insuree.dart';


void main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await HiveStore.openBox;
    runApp(MyApp());
}


//  WidgetsFlutterBinding.ensureInitialized();
//  final Locale locale = Locale('en');
class MyApp extends StatefulWidget {
    static void setLocale(BuildContext context, Locale newLocale) {
        var state = context.findAncestorStateOfType<_MyAppState>();
        state.setLocale(newLocale);
    }
    @override
    _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
    Insuree insuree;
    DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

    Locale _locale;
    GraphQLClient _client;
    void setLocale(Locale locale) {
        setState(() {
            _locale = locale;
        });
    }

    @override
    void didChangeDependencies() async {
        getLocale().then((locale) {
            setState(() {
                _locale = locale;
            });
        });
        super.didChangeDependencies();
    }

    @override
    void initState() {
        super.initState();
        getCurrentAppTheme();
    }

    void getCurrentAppTheme() async {
        themeChangeProvider.darkTheme =
        await themeChangeProvider.darkThemePreference.getTheme();
    }

    @override
    Widget build(BuildContext context) {
        return MultiProvider(
            providers: [
                ChangeNotifierProvider<AuthBlock>.value(value: AuthBlock()),
                ChangeNotifierProvider<AppState>.value(value: AppState()),
                ChangeNotifierProvider<LinkedCardState>.value(value: LinkedCardState()),
                ChangeNotifierProvider<BottomNavigationBarProvider>.value(value: BottomNavigationBarProvider()),
                ChangeNotifierProvider(create: (_) {
                    return themeChangeProvider;
                }),
                 StreamProvider<UserLocation>.value(value: LocationService().locationStream)
            ],
            child: Consumer<DarkThemeProvider>(
                builder: (BuildContext context, value, Widget child) {
                    return MaterialApp(
                        locale: _locale,
                        supportedLocales: [
                            Locale('en', ''),
                            Locale('ar', ''),
                            Locale('hi', '')
                        ],
                        localizationsDelegates: [
                            AppLocalizationsDelegate(),
                            GlobalMaterialLocalizations.delegate,
                            GlobalWidgetsLocalizations.delegate,
                            GlobalCupertinoLocalizations.delegate,
                        ],
                        localeResolutionCallback: (locale, supportedLocales) {
                            for (var supportedLocale in supportedLocales) {
                                if (supportedLocale?.languageCode == locale?.languageCode &&
                                    supportedLocale?.countryCode == locale?.countryCode) {
                                    return supportedLocale;
                                }
                            }
                            return supportedLocales?.first;
                        },
                        // locale: locale,
                        debugShowCheckedModeBanner: false,
                        theme: Styles.themeData(themeChangeProvider.darkTheme, context),
                        initialRoute: '/splash',
                        routes: <String, WidgetBuilder>{
                            '/ggg': (BuildContext context) => Auth(),
                            '/card' :(BuildContext context) => Display(initIndex: null,),
                            '/profile' :(BuildContext context) => ProfilePageView(),
                            '/profileInfo' :(BuildContext context) => ProfileInfo(),
                            '/sync' :(BuildContext context) => Sync(),
                            '/splash':(BuildContext context) => SplashScreen(),
                            '/':(BuildContext context) => LoginScreen(), //OTP this is
                            '/register':(BuildContext context) => RegisterScreen(),
                            '/add_card':(BuildContext context) => AddCard(affiliate_id: null, cardpk: null,),
                            '/otp-verify' :(BuildContext context) => OtpScreen(),
                            '/insuree_verify' :(BuildContext context) => VerifyInsuree(),
                            // SIGN UP
                            '/reset-password':(BuildContext context) => ResetPassword(),
                        },
                    );
                }));
    }
}



// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//         // This makes the visual density adapt to the platform that you run
//         // the app on. For desktop platforms, the controls will be smaller and
//         // closer together (more dense) than on mobile platforms.
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
