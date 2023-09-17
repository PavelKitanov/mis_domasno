import 'package:flutter/material.dart';

import 'pages/home_page.dart';
import 'pages/login_register_page.dart';
import 'services/authentication.dart';




class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MyHomePage(title: "Restaurants");
        } else {
          return const LoginPage();
        }
      },
    );
  }
}