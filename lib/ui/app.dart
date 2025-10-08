import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_ilumina/ui/login/loginpage.dart';
import 'package:smart_ilumina/ui/home/homepage.dart';
import 'package:smart_ilumina/ui/login/registerpage.dart';
import 'package:smart_ilumina/ui/scaner/scanerpage.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Ilumina',
      initialRoute: '/login',
      defaultTransition: Transition.fade,
      getPages: [
        GetPage(
          name: '/login',
          page: () => LoginPage(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: '/home',
          page: () => HomePage(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: '/signup',
          page: () => Registerpage(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 250),
        ),
        GetPage(
          name: '/scaner',
          page: () => ScanerPage(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }
}
