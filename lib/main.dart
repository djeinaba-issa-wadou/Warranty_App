import 'package:flutter/material.dart';
import 'screens/role_selection_screen.dart';

void main() {
  runApp(WarrantyApp());
}

class WarrantyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Warranty',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: RoleSelectionScreen(),
    );
  }
}