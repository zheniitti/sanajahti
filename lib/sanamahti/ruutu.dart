import 'package:flutter/material.dart';

class Ruutu extends StatefulWidget {
  final GlobalKey key;
  final int location;
  final Color color;
  final letter;
  Ruutu({this.key, this.color, this.letter, this.location});
  @override
  _RuutuState createState() => _RuutuState();
}

class _RuutuState extends State<Ruutu> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: widget.key,
      margin: EdgeInsets.all(0.0),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15), color: widget.color),
      child: Center(
          child: Expanded(
        child: Text(
          widget.letter,
          style: TextStyle(fontSize: 20),
        ),
      )),
      curve: Curves.easeInOutBack,
      duration: Duration(milliseconds: 1000),
    );
  }
}
