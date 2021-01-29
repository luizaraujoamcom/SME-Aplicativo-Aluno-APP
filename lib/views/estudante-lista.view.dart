import 'package:auto_size_text/auto_size_text.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sme_app_aluno/controllers/students/students.controller.dart';
import 'package:sme_app_aluno/controllers/background_fetch/background_fetch.controller.dart';
import 'package:sme_app_aluno/models/student/student.dart';
import 'package:sme_app_aluno/models/models.dart';
import 'package:sme_app_aluno/views/dashboard.view.dart';
import 'package:sme_app_aluno/views/login.view.dart';
import 'package:sme_app_aluno/widgets/widgets.dart';
import 'package:sme_app_aluno/widgets/tag/tag_custom.dart';
import 'package:sme_app_aluno/services/user.service.dart';
import 'package:sme_app_aluno/utils/auth.util.dart';
import 'package:sme_app_aluno/utils/global-config.util.dart';
import 'package:sme_app_aluno/utils/navigator.util.dart';

class EstudanteListaView extends StatefulWidget {
  final int userId;

  EstudanteListaView({@required this.userId});

  @override
  _ListStudantsState createState() => _ListStudantsState();
}

class _ListStudantsState extends State<EstudanteListaView> {
  final UserService _userService = UserService();

  StudentsController _studentsController;
  BackgroundFetchController _backgroundFetchController;

  @override
  void initState() {
    super.initState();
    _studentsController = StudentsController();
    _backgroundFetchController = BackgroundFetchController();
    _loadingAllStudents();
    _backgroundFetchController.initPlatformState(
      _onBackgroundFetch,
      "${env['BUNDLE_IDENTIFIER']}.verificaSeUsuarioTemAlunoVinculado",
      10000,
    );
  }

  void _onBackgroundFetch(String taskId) async {
    bool responsibleHasStudent = await _backgroundFetchController
        .checkIfResponsibleHasStudent(widget.userId);
    print(
        '[BackgroundFetch] - INIT -> ${env['BUNDLE_IDENTIFIER']}.verificaSeUsuarioTemAlunoVinculado');
    if (responsibleHasStudent == false) {
      Auth.logout(context, widget.userId, true);
    }

    BackgroundFetch.finish(taskId);
  }

  _logoutUser() async {
    List<Usuario> findUsers = await _userService.all();
    await Auth.logout(context, findUsers[0].id, true);
  }

  Widget _itemCardStudent(BuildContext context, Student model,
      String groupSchool, int codigoGrupo, int userId) {
    return EACardEstuante(
      name: model.nomeSocial != null && model.nomeSocial.isNotEmpty
          ? model.nomeSocial
          : model.nome,
      schoolName: model.escola,
      studentGrade: model.turma,
      codigoEOL: model.codigoEol,
      schooType: model.descricaoTipoEscola,
      dreName: model.siglaDre,
      onPress: () {
        Nav.push(
            context,
            DashboardView(
                userId: widget.userId,
                student: model,
                groupSchool: groupSchool,
                codigoGrupo: codigoGrupo));
      },
    );
  }

  Widget _listStudents(List<Student> students, BuildContext context,
      String groupSchool, int codigoGrupo, int userId) {
    List<Widget> list = new List<Widget>();
    for (var i = 0; i < students.length; i++) {
      list.add(_itemCardStudent(
          context, students[i], groupSchool, codigoGrupo, userId));
    }
    return new Column(children: list);
  }

  Future<bool> _onBackPress() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Atenção"),
            content: Text("Deseja sair do aplicativo?"),
            actions: <Widget>[
              FlatButton(
                child: Text("SIM"),
                onPressed: () {
                  Auth.logout(context, widget.userId, false);
                  Nav.pushReplacement(context, Login());
                },
              ),
              FlatButton(
                child: Text("NÃO"),
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
              )
            ],
          );
        });
  }

  _loadingAllStudents() async {
    final Usuario user = await _userService.find(widget.userId);
    await _studentsController.loadingStudents(user.cpf, user.id);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var screenHeight = (size.height - MediaQuery.of(context).padding.top) / 100;
    return Scaffold(
      backgroundColor: Color(0xffE5E5E5),
      appBar: AppBar(
        title: Text("Estudantes"),
        backgroundColor: Color(0xffEEC25E),
        automaticallyImplyLeading: false,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Auth.logout(context, widget.userId, false);
            },
            icon: Icon(
              FontAwesomeIcons.signOutAlt,
              size: screenHeight * 2,
            ),
          ),
        ],
      ),
      body: WillPopScope(
        onWillPop: _onBackPress,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(screenHeight * 2.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: screenHeight * 2.5,
                ),
                AutoSizeText(
                  "ALUNOS CADASTRADOS PARA O RESPONSÁVEL",
                  maxFontSize: 16,
                  minFontSize: 14,
                  style: TextStyle(
                      color: Color(0xffDE9524), fontWeight: FontWeight.w500),
                ),
                SizedBox(
                  height: screenHeight * 3.5,
                ),
                Container(
                    width: MediaQuery.of(context).size.width,
                    height: screenHeight * 74,
                    child: Observer(builder: (context) {
                      if (_studentsController.isLoading ||
                          _studentsController.dataEstudent == null) {
                        return EALoader();
                      } else {
                        if (_studentsController.dataEstudent.data == null &&
                            widget.userId != null) {
                          _logoutUser();
                          return Container();
                        } else {
                          return ListView.builder(
                            itemCount:
                                _studentsController.dataEstudent.data.length,
                            itemBuilder: (context, index) {
                              final dados =
                                  _studentsController.dataEstudent.data;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  TagCustom(
                                    text: "${dados[index].grupo}",
                                    color: Color(0xffC65D00),
                                  ),
                                  SizedBox(
                                    height: screenHeight * 2,
                                  ),
                                  _listStudents(
                                    dados[index].students,
                                    context,
                                    dados[index].grupo,
                                    dados[index].codigoGrupo,
                                    widget.userId,
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                    }))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
