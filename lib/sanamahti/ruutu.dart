import 'package:flutter/material.dart';

class Ruutu extends StatefulWidget {
  final GlobalKey key;
  final int index;
  final Color color;
  final letter;
  Ruutu({this.key, this.color, this.letter, this.index});
  @override
  _RuutuState createState() => _RuutuState();
}

class _RuutuState extends State<Ruutu> {
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      key: widget.key,
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
