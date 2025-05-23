import 'package:flutter/material.dart';
import 'package:flutter_project/views/pages/auth/auth_state.dart';
import 'package:flutter_project/views/pages/home_page.dart';
import 'package:flutter_project/views/pages/profile_page.dart';

List<Widget> pages = [
  HomePage(),
  const ProfilePage(),
];

class WidgetTree extends StatelessWidget {
  const WidgetTree({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AuthState(),
    );
  }
}
