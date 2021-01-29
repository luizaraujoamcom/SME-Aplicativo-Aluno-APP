import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CheckLine extends StatelessWidget {
  final double screenHeight;
  final String text;
  final bool checked;

  CheckLine(
      {@required this.screenHeight, @required this.text, this.checked = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        checked
            ? Icon(
                FontAwesomeIcons.check,
                color: checked ? Color(0xff00AE6E) : Color(0xff757575),
                size: screenHeight * 2,
              )
            : Icon(
                FontAwesomeIcons.times,
                color: Color(0xffff0000),
                size: screenHeight * 2,
              ),
        SizedBox(
          width: screenHeight * 1,
        ),
        Container(
          width: screenHeight * 36,
          child: AutoSizeText(
            text,
            maxFontSize: 17,
            minFontSize: 15,
            maxLines: 3,
            style: TextStyle(
                color: checked ? Color(0xff00AE6E) : Color(0xffff0000),
                height: screenHeight * 0.2,
                fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
