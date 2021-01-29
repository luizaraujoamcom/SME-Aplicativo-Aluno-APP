import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:sme_app_aluno/controllers/terms/terms.controller.dart';
import 'package:sme_app_aluno/views/views.dart';
import 'package:sme_app_aluno/widgets/widgets.dart';

class TermosUsoView extends StatefulWidget {
  @override
  _TermsUseState createState() => _TermsUseState();
}

class _TermsUseState extends State<TermosUsoView> {
  TermsController _termsController;

  @override
  void initState() {
    super.initState();
    _termsController = TermsController();
    _termsController.fetchTermoCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffFFFFFF),
      appBar: AppBar(
        title: Text("Termos de Uso"),
        backgroundColor: Color(0xffEEC25E),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        // child: TermsView(term: _termsController.term),
        child: Observer(builder: (context) {
          if (_termsController.term != null &&
              _termsController.term.termosDeUso != null) {
            return TermosView(term: _termsController.term, showBtn: false);
          } else {
            return EALoader();
          }
        }),
      ),
    );
  }
}
