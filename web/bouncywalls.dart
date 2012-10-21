import 'dart:html';
import 'package:box2d/box2d.dart';

num rotatePos = 0;

void main() {
  query("#text")
    ..text = "More text"
    ..on.click.add(rotateText);
}

void rotateText(Event event) {
  rotatePos += 360;
  query("#text").style
    ..transition = "1s"
    ..transform = "rotate(${rotatePos}deg)";
  print("hello ");
  query("#text").style
    ..transition = "1s"
    ..transform = "rotate(${rotatePos}deg)";
}
