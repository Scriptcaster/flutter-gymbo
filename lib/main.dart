import 'package:flutter/material.dart';
import 'package:flutter_gymbo/home.dart';
import 'login_page.dart';
import 'sign_in.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      // home: LoginPage(),
      home: getCurrentUser() != null ? LoginPage() : HomeScreen(),
    );
  }
}