import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class Test extends StatefulWidget {
  const Test({super.key});

  @override
  State<Test> createState() => _TestState();
}

class _TestState extends State<Test> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: QrImage(
          data: 'Ho Thi My Huyen',
          version: QrVersions.auto,
          size: 320,
          gapless: false,
          ),
        ),
    );
    
  }
}