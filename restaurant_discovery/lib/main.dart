import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'widget_tree.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Color customPrimaryColor = Color(0xFFFF6B6B);
    MaterialColor customSwatch = MaterialColor(
    customPrimaryColor.value,
    <int, Color>{
      50: customPrimaryColor.withOpacity(0.1),
      100: customPrimaryColor.withOpacity(0.2),
      200: customPrimaryColor.withOpacity(0.3),
      300: customPrimaryColor.withOpacity(0.4),
      400: customPrimaryColor.withOpacity(0.5),
      500: customPrimaryColor.withOpacity(0.6),
      600: customPrimaryColor.withOpacity(0.7),
      700: customPrimaryColor.withOpacity(0.8),
      800: customPrimaryColor.withOpacity(0.9),
      900: customPrimaryColor.withOpacity(1.0),
    },
  );
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: customSwatch, 
        backgroundColor: Color(0xFFFFC3A0),
        scaffoldBackgroundColor: Color(0xFFFFC3A0), 
        fontFamily: 'Roboto', 
        textTheme: TextTheme(
          headline6: TextStyle(
            fontSize: 24.0, 
            fontWeight: FontWeight.bold,
          ),
          bodyText2: TextStyle(
            fontSize: 16.0, 
          ),
        ),
      ),
      home: const WidgetTree(),
    );
  }
}



