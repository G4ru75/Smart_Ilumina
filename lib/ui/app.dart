import 'package:flutter/material.dart';
import 'package:smart_ilumina/ui/login/loginpage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Ilumina',
      home: LoginPage(),
    );
  }
}
