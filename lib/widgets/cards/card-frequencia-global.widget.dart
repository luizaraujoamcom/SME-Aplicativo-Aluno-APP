import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:sme_app_aluno/models/frequency/frequency.dart';

class EACardFrequenciaGlobal extends StatelessWidget {
  final Frequency frequency;

  EACardFrequenciaGlobal({
    @required this.frequency,
  });

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var screenHeight = (size.height - MediaQuery.of(context).padding.top) / 100;
    var frequencyData = frequency.frequencia * 100;
    return Container(
      height: screenHeight * 18,
      padding: EdgeInsets.all(screenHeight * 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(screenHeight * 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: CircularPercentIndicator(
                radius: 67.0,
                lineWidth: 6.0,
                animation: true,
                animationDuration: 3000,
                percent: frequency.frequencia,
                animateFromLastPercent: true,
                center: AutoSizeText(
                  "${frequencyData.toStringAsFixed(0)}%",
                  maxFontSize: 20,
                  minFontSize: 18,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                circularStrokeCap: CircularStrokeCap.round,
                progressColor: HexColor(frequency.corDaFrequencia),
                backgroundColor: Color(0xffF1F0F5),
                reverse: true),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: AutoSizeText(
                "Frequência global do estudante",
                textAlign: TextAlign.left,
                maxFontSize: 22,
                minFontSize: 18,
                maxLines: 2,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
