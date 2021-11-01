import 'package:flutter/material.dart';
import 'sanamahti/sanamahtiBoard.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Center(child: Text('Sanamahti')),
        ),
        body: SanamahtiBoard(),
      ),
    );
  }
}
