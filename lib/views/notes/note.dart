import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

class Note extends StatelessWidget {
  final String name;
  final String noteValue;
  final String description;
  final bool current;
  final Color color;

  Note({this.name, this.noteValue, this.description, this.current, this.color});
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var screenHeight = (size.height - MediaQuery.of(context).padding.top) / 100;

    viewEvent() {
      return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [Html(data: description)],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("FECHAR"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AutoSizeText(name,
            maxFontSize: 14,
            minFontSize: 12,
            style: TextStyle(color: current ? Color(0xFFC65D00) : Colors.black),
            textAlign: TextAlign.left),
        SizedBox(
          height: screenHeight * 1,
        ),
        InkWell(
          child: Container(
            padding: EdgeInsets.all(screenHeight * 0.8),
            child: AutoSizeText(
              noteValue,
              maxFontSize: 14,
              minFontSize: 12,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            decoration: BoxDecoration(
                border: Border.all(
                    width: current ? screenHeight * 0.3 : 0.0,
                    color: current ? color : Colors.transparent),
                borderRadius:
                    BorderRadius.all(Radius.circular(screenHeight * 1)),
                color: noteValue == '-'
                    ? Color(0xFFEDEDED).withOpacity(0.4)
                    : current
                        ? color.withOpacity(0.4)
                        : Color(0xFFEDEDED)),
            width: screenHeight * 8,
          ),
          onTap: description != null &&
                  description.isNotEmpty &&
                  description.length > 5
              ? () {
                  viewEvent();
                }
              : null,
        )
      ],
    );
  }
}
