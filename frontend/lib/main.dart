import 'package:flutter/material.dart';

void main() {
  runApp(const CxShieldApp());
}

class CxShieldApp extends StatelessWidget {
  const CxShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'CX-SHIELD',
      debugShowCheckedModeBanner: false,
      home: Scaffold(backgroundColor: Colors.white),
    );
  }
}
