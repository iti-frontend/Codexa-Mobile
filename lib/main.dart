import 'package:codexa_mobile/Ui/home_page/home_page/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}


// login
// register
// splash screen + on boarding
// landing page  => bottom navbar ==> home - courses - community - settings (theme - lanaguage - payment - history) (profile-screen - notifications - search-textfeild - chat-screen)
// 7-10-2025 ==> 11:59 pm