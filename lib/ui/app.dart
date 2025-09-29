import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/ui/login/loginpage.dart';
import 'package:smart_ilumina/ui/home/homepage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Ilumina',
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginPage()),
        GetPage(name: '/home', page: () => const HomePage()),
      ],
    );
  }
}
