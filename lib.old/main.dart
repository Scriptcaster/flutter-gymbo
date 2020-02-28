import 'package:flutter/material.dart';
import 'home.dart';
// import 'home_new.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
      // home: LoginPage(),
      routes: <String, WidgetBuilder>{
      //   // '/task': (BuildContext context) => TaskPage(title: 'Task'),
        // '/home': (BuildContext context) => HomePage(title: 'Home'),
        // '/login': (BuildContext context) => LoginPage(),
      //   // '/register': (BuildContext context) => RegisterPage(),
      }
    );
  }
}

// Version 1.0
// import 'package:flutter/material.dart';
// import 'login.dart';
// void main() => runApp(MyApp());
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Flutter Login',
//       theme: ThemeData(
//         primarySwatch: Colors.red,
//       ),
//       home: Login(),
//       // home: getCurrentUser() != null ? LoginPage() : HomeScreen(),
//     );
//   }
// }