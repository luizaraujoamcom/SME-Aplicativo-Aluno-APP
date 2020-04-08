import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sme_app_aluno/screens/login/login.dart';
import 'package:sme_app_aluno/screens/students/list_studants.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var screenHeight = (size.height - MediaQuery.of(context).padding.top) / 100;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(
                      right: screenHeight * 3, bottom: screenHeight * 3),
                  width: screenHeight * 10,
                  height: screenHeight * 10,
                  decoration: BoxDecoration(
                      color: Color(0xffC4C4C4),
                      borderRadius: BorderRadius.circular(screenHeight * 5)),
                  child: Image.asset("assets/images/avatar_estudante.png"),
                ),
                AutoSizeText(
                  "Francisco de Assis Junqueira",
                  maxFontSize: 16,
                  minFontSize: 14,
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500),
                ),
                AutoSizeText(
                  "Usuário Ativo",
                  maxFontSize: 14,
                  minFontSize: 12,
                  style: TextStyle(color: Color(0xffC4C4C4)),
                ),
              ],
            ),
            decoration: BoxDecoration(
              color: Colors.white,
            ),
          ),
          ListTile(
            title: Text('Estudantes'),
            leading: CircleAvatar(
              radius: screenHeight * 2,
              backgroundColor: Color(0xffEA9200),
              child: Icon(
                FontAwesomeIcons.userAlt,
                color: Colors.white,
                size: screenHeight * 2.3,
              ),
            ),
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ListStudants()));
            },
          ),
          ListTile(
            title: Text('Menssagens'),
            leading: CircleAvatar(
              radius: screenHeight * 2,
              backgroundColor: Color(0xffEA9200),
              child: Icon(
                FontAwesomeIcons.envelopeOpen,
                color: Colors.white,
                size: screenHeight * 2.3,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Frequência / Boletim'),
            leading: CircleAvatar(
              radius: screenHeight * 2,
              backgroundColor: Color(0xffEA9200),
              child: Icon(
                FontAwesomeIcons.copy,
                color: Colors.white,
                size: screenHeight * 2.3,
              ),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Sair'),
            leading: CircleAvatar(
              radius: screenHeight * 2,
              backgroundColor: Color(0xffEA9200),
              child: Icon(
                FontAwesomeIcons.signOutAlt,
                color: Colors.white,
                size: screenHeight * 2.5,
              ),
            ),
            onTap: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login()));
            },
          ),
        ],
      ),
    );
  }
}
