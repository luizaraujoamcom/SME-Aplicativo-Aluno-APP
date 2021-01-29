import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sme_app_aluno/controllers/messages/messages.controller.dart';
import 'package:sme_app_aluno/models/message/message.dart';
import 'package:sme_app_aluno/models/user/user.dart';
import 'package:sme_app_aluno/views/not_internet/not_internet.dart';
import 'package:sme_app_aluno/views/views.dart';
import 'package:sme_app_aluno/utils/utils.dart';
import 'package:sme_app_aluno/widgets/widgets.dart';
import 'package:sme_app_aluno/services/user.service.dart';
import 'package:url_launcher/url_launcher.dart';

class MensagemNotificacaoView extends StatefulWidget {
  final Message message;
  final int userId;

  MensagemNotificacaoView({@required this.message, @required this.userId});

  @override
  _ViewMessageNotificationState createState() =>
      _ViewMessageNotificationState();
}

class _ViewMessageNotificationState extends State<MensagemNotificacaoView> {
  MessagesController _messagesController;
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  bool messageIsRead = true;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _messagesController = MessagesController();
    _viewMessageUpdate(false, false);
  }

  _viewMessageUpdate(bool isNotRead, bool action) async {
    if (action) {
      _messagesController.updateMessage(
          notificacaoId: widget.message.id,
          usuarioId: widget.userId,
          codigoAlunoEol: widget.message.codigoEOL ?? 0,
          mensagemVisualia: false);
    } else {
      _messagesController.updateMessage(
          notificacaoId: widget.message.id,
          usuarioId: widget.userId,
          codigoAlunoEol: widget.message.codigoEOL ?? 0,
          mensagemVisualia: true);
    }
  }

  _navigateToListMessage() async {
    final User user = await _userService.find(widget.userId);

    Nav.push(
        context,
        EstudanteListaView(
          userId: user.id,
        ));
  }

  Future<bool> _confirmNotReadeMessage(int id, scaffoldKey) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Atenção"),
            content: Text(
                "Você tem certeza que deseja marcar esta mensagem como não lida?"),
            actions: <Widget>[
              FlatButton(
                  child: Text("SIM"),
                  onPressed: () {
                    _viewMessageUpdate(true, true);
                    Navigator.of(context).pop(false);
                    var snackbar = SnackBar(
                        content: Text("Mensagem marcada como não lida"));
                    scaffoldKey.currentState.showSnackBar(snackbar);
                    setState(() {
                      messageIsRead = !messageIsRead;
                    });
                  }),
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

  _launchURL(url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(context);

    if (connectionStatus == ConnectivityStatus.Offline) {
      return NotInteernet();
    } else {
      var size = MediaQuery.of(context).size;
      var screenHeight =
          (size.height - MediaQuery.of(context).padding.top) / 100;
      return Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xffE5E5E5),
        appBar: AppBar(
          title: Text("Mensagens"),
          backgroundColor: Color(0xffEEC25E),
          leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                _navigateToListMessage();
              }),
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.all(screenHeight * 2.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: screenHeight * 2.5,
                ),
                AutoSizeText(
                  "MENSAGEM",
                  style: TextStyle(
                      color: Color(0xffDE9524), fontWeight: FontWeight.w500),
                ),
                EACardMensagem(
                  headerTitle: widget.message.categoriaNotificacao,
                  categoriaNotificacao: widget.message.categoriaNotificacao,
                  headerIcon: false,
                  recentMessage: false,
                  content: <Widget>[
                    Container(
                      width: screenHeight * 39,
                      child: AutoSizeText(
                        widget.message.titulo,
                        maxFontSize: 16,
                        minFontSize: 14,
                        maxLines: 5,
                        style: TextStyle(
                            color: Color(0xff666666),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 1.8,
                    ),
                    Container(
                      width: screenHeight * 39,
                      child: Html(
                        data: widget.message.mensagem,
                        onLinkTap: (url) => _launchURL(url),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 3,
                    ),
                    AutoSizeText(
                      DateFormatSuport.formatStringDate(
                          widget.message.criadoEm, 'dd/MM/yyyy'),
                      maxFontSize: 16,
                      minFontSize: 14,
                      maxLines: 2,
                      style: TextStyle(
                          color: Color(0xff666666),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                  footer: true,
                  footerContent: <Widget>[
                    Container(
                      child: Row(
                        children: <Widget>[
                          SizedBox(
                            width: screenHeight * 2,
                          ),
                          Visibility(
                            visible: messageIsRead,
                            child: EAButtonIcone(
                                iconBtn: Icon(
                                  FontAwesomeIcons.envelope,
                                  color: Color(0xffC65D00),
                                ),
                                screenHeight: screenHeight,
                                onPress: () => _confirmNotReadeMessage(
                                    widget.message.id, scaffoldKey)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      child: Container(
                        height: screenHeight * 6,
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: Color(0xffC65D00), width: 1),
                          borderRadius: BorderRadius.all(
                            Radius.circular(screenHeight * 3),
                          ),
                        ),
                        child: FlatButton(
                          onPressed: () async {
                            _navigateToListMessage();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              AutoSizeText(
                                "VOLTAR",
                                maxFontSize: 16,
                                minFontSize: 14,
                                style: TextStyle(
                                    color: Color(0xffC65D00),
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                width: screenHeight * 1,
                              ),
                              Icon(
                                FontAwesomeIcons.angleLeft,
                                color: Color(0xffffd037),
                                size: screenHeight * 4,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
