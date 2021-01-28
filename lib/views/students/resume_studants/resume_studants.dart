import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sme_app_aluno/models/student/student.dart';
import 'package:sme_app_aluno/views/data_student/data.dart';
import 'package:sme_app_aluno/views/frequency/frequency.dart';
import 'package:sme_app_aluno/views/not_internet/not_internet.dart';
import 'package:sme_app_aluno/views/notes/expansion.dart';
import 'package:sme_app_aluno/views/widgets/student_info/student_info.dart';
import 'package:sme_app_aluno/utils/conection.dart';
import 'package:sme_app_aluno/utils/date_format.dart';

class ResumeStudants extends StatefulWidget {
  final Student student;
  final int userId;
  final String groupSchool;

  ResumeStudants({@required this.student, this.groupSchool, this.userId});

  @override
  _ResumeStudantsState createState() => _ResumeStudantsState();
}

class _ResumeStudantsState extends State<ResumeStudants> {
  bool abaDados = true;
  bool abaBoletim = false;
  bool abaFrequencia = false;

  content(BuildContext context, double screenHeight, Student data) {
    String dateFormatted =
        DateFormatSuport.formatStringDate(data.dataNascimento, 'dd/MM/yyyy');
    String dateSituacaoMatricula = DateFormatSuport.formatStringDate(
        data.dataSituacaoMatricula, 'dd/MM/yyyy');

    if (abaDados) {
      return Container(
        color: Colors.white,
        padding: EdgeInsets.all(screenHeight * 2.5),
        child: DataStudent(
          dataNasc: dateFormatted,
          codigoEOL: "${data.codigoEol}",
          situacao: dateSituacaoMatricula,
          codigoUe: widget.student.codigoEscola,
          id: widget.userId,
        ),
      );
    }

    if (abaBoletim) {
      return Container(
        padding: EdgeInsets.all(screenHeight * 2.5),
        child: Expansion(
          codigoUe: widget.student.codigoEscola,
          codigoTurma: widget.student.codigoTurma.toString(),
          codigoAluno: widget.student.codigoEol.toString(),
          groupSchool: widget.groupSchool,
        ),
        height: MediaQuery.of(context).size.height - screenHeight * 26,
      );
    }

    if (abaFrequencia) {
      return Frequency(
        student: widget.student,
        userId: widget.userId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    if (connectionStatus == ConnectivityStatus.Offline) {
      // BackgroundFetch.stop().then((int status) {
      //   print('[BackgroundFetch] stop success: $status');
      // });
      return NotInteernet();
    } else {
      var size = MediaQuery.of(context).size;
      var screenHeight =
          (size.height - MediaQuery.of(context).padding.top) / 100;
      return Scaffold(
        backgroundColor: Color(0xffE5E5E5),
        appBar: AppBar(
          title: Text(
            "Informações do estudante",
            style: TextStyle(
                color: Color(0xff333333), fontWeight: FontWeight.w500),
          ),
          backgroundColor: Color(0xffEEC25E),
        ),
        body: SingleChildScrollView(
          child: Container(
            color: Color(0xffE5E5E5),
            width: MediaQuery.of(context).size.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(screenHeight * 2.5),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border(
                              bottom: BorderSide(
                                  color: Color(0xffC5C5C5), width: 0.5))),
                      child: StudentInfo(
                        studentName: widget.student.nomeSocial != null &&
                                widget.student.nomeSocial.isNotEmpty
                            ? widget.student.nomeSocial
                            : widget.student.nome,
                        schoolName: widget.student.escola,
                        schoolType: widget.student.descricaoTipoEscola,
                        dreName: widget.student.siglaDre,
                        studentGrade: widget.student.turma,
                        studentEOL: widget.student.codigoEol,
                      ),
                    ),
                    Container(
                        child: Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              abaDados = true;
                              abaBoletim = false;
                              abaFrequencia = false;
                            });
                          },
                          child: Container(
                            width: (MediaQuery.of(context).size.width / 100) *
                                33.33,
                            padding: EdgeInsets.only(
                                top: screenHeight * 2.2,
                                bottom: screenHeight * 2.2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(
                                      color: abaDados
                                          ? Color(0xffC65D00)
                                          : Color(0xffCECECE),
                                      width: 2)),
                            ),
                            child: Center(
                              child: AutoSizeText(
                                "DADOS",
                                maxFontSize: 16,
                                minFontSize: 14,
                                style: TextStyle(
                                    color: abaDados
                                        ? Color(0xffC65D00)
                                        : Color(0xff9f9f9f),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              abaDados = false;
                              abaBoletim = true;
                              abaFrequencia = false;
                            });
                          },
                          child: Container(
                            width: (MediaQuery.of(context).size.width / 100) *
                                33.33,
                            padding: EdgeInsets.only(
                                top: screenHeight * 2.2,
                                bottom: screenHeight * 2.2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(
                                      color: abaBoletim
                                          ? Color(0xffC65D00)
                                          : Color(0xffCECECE),
                                      width: 2)),
                            ),
                            child: Center(
                              child: AutoSizeText(
                                "BOLETIM",
                                maxFontSize: 16,
                                minFontSize: 14,
                                style: TextStyle(
                                    color: abaBoletim
                                        ? Color(0xffC65D00)
                                        : Color(0xff9f9f9f),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              abaDados = false;
                              abaBoletim = false;
                              abaFrequencia = true;
                            });
                          },
                          child: Container(
                            width: (MediaQuery.of(context).size.width / 100) *
                                33.33,
                            padding: EdgeInsets.only(
                              top: screenHeight * 2.2,
                              bottom: screenHeight * 2.2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border(
                                  bottom: BorderSide(
                                      color: abaFrequencia
                                          ? Color(0xffC65D00)
                                          : Color(0xffCECECE),
                                      width: 2)),
                            ),
                            child: Center(
                              child: AutoSizeText(
                                "FREQUÊNCIA",
                                maxFontSize: 16,
                                minFontSize: 14,
                                style: TextStyle(
                                    color: abaFrequencia
                                        ? Color(0xffC65D00)
                                        : Color(0xff9f9f9f),
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        )
                      ],
                    )),
                    content(context, screenHeight, widget.student)
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}
