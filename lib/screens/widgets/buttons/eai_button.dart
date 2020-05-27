import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class EAIButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final double screenHeight;
  final Function onPress;

  EAIButton(
      {@required this.text,
      @required this.icon,
      @required this.screenHeight,
      @required this.onPress});

  @override
  Widget build(BuildContext context) {
    return Container(
        width: MediaQuery.of(context).size.width,
        height: screenHeight * 6,
        decoration: BoxDecoration(
            color: Color(0xffd06d12),
            borderRadius: BorderRadius.circular(screenHeight * 3)),
        child: FlatButton(
            onPressed: onPress,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                AutoSizeText(
                  text,
                  maxFontSize: 16,
                  minFontSize: 14,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  width: screenHeight * 3,
                ),
                Icon(
                  icon,
                  color: Color(0xffffd037),
                  size: screenHeight * 3,
                )
              ],
            )));
  }
}
