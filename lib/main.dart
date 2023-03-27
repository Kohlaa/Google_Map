import 'package:flutter/material.dart';

import 'homeScreen.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        homeScreen.routeName: (context) => homeScreen(),
      },
      initialRoute: homeScreen.routeName,
    );
  }
}
