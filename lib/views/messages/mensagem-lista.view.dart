import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:sme_app_aluno/controllers/messages/messages.controller.dart';
import 'package:sme_app_aluno/models/message/message.dart';
import 'package:sme_app_aluno/views/messages/mensagem.view.dart';
import 'package:sme_app_aluno/views/not_internet/not_internet.dart';
import 'package:sme_app_aluno/widgets/widgets.dart';
import 'package:sme_app_aluno/widgets/filters/eaq_filter_page.dart';
import 'package:sme_app_aluno/utils/conection.dart';
import 'package:sme_app_aluno/utils/date_format.dart';
import 'package:sme_app_aluno/utils/string_support.dart';

class MensagemListaView extends StatefulWidget {
  final int codigoGrupo;
  final int codigoAlunoEol;
  final int userId;

  MensagemListaView(
      {@required this.codigoGrupo,
      @required this.codigoAlunoEol,
      @required this.userId});
  _ListMessageState createState() => _ListMessageState();
}

class _ListMessageState extends State<MensagemListaView> {
  MessagesController _messagesController;
  List<Message> listOfmessages;
  bool dreCheck = true;
  bool smeCheck = true;
  bool ueCheck = true;

  @override
  void initState() {
    super.initState();
    _messagesController = MessagesController();
    _loadingMessages();
  }

  _loadingMessages() {
    setState(() {});
    _messagesController = MessagesController();
    _messagesController.loadMessages(widget.codigoAlunoEol, widget.userId);
  }

  Future<bool> _confirmDeleteMessage(int id) async {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Atenção"),
            content: Text("Você tem certeza que deseja excluir esta mensagem?"),
            actions: <Widget>[
              FlatButton(
                  child: Text("SIM"),
                  onPressed: () {
                    _removeMesageToStorage(
                      widget.codigoAlunoEol,
                      id,
                      widget.userId,
                    );

                    Navigator.of(context).pop(true);
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

  _removeMesageToStorage(int codigoEol, int idNotificacao, int userId) async {
    await _messagesController.deleteMessage(codigoEol, idNotificacao, userId);
  }

  _navigateToMessage(BuildContext context, Message message) {
    Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => ViewMessage(
                    userId: widget.userId,
                    message: message,
                    codigoAlunoEol: widget.codigoAlunoEol)))
        .whenComplete(() => _loadingMessages());
  }

  Widget _listCardsMessages(
    List<Message> messages,
    BuildContext context,
    double screenHeight,
  ) {
    return new Column(
        children: messages
            .where((e) => e.id != _messagesController.messages[0].id)
            .toList()
            .map((item) => GestureDetector(
                  onTap: () {
                    _navigateToMessage(context, item);
                  },
                  child: EACardMensagem(
                    headerTitle: item.categoriaNotificacao,
                    headerIcon: true,
                    recentMessage: !item.mensagemVisualizada,
                    categoriaNotificacao: item.categoriaNotificacao,
                    content: <Widget>[
                      Container(
                        width: screenHeight * 39,
                        child: AutoSizeText(
                          item.titulo,
                          maxFontSize: 16,
                          minFontSize: 14,
                          maxLines: 2,
                          style: TextStyle(
                              color: Color(0xff42474A),
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 1.8,
                      ),
                      Container(
                        width: screenHeight * 39,
                        child: AutoSizeText(
                          StringSupport.parseHtmlString(
                              StringSupport.truncateEndString(
                                  item.mensagem, 250)),
                          maxFontSize: 16,
                          minFontSize: 14,
                          maxLines: 10,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: Color(0xff929292),
                              height: screenHeight * 0.240),
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 3,
                      ),
                      AutoSizeText(
                        DateFormatSuport.formatStringDate(
                            item.criadoEm, 'dd/MM/yyyy'),
                        maxFontSize: 16,
                        minFontSize: 14,
                        maxLines: 2,
                        style: TextStyle(
                            color: Color(0xff929292),
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                    footer: true,
                    footerContent: <Widget>[
                      Visibility(
                        visible: item.mensagemVisualizada,
                        child: GestureDetector(
                          onTap: () async {
                            await _confirmDeleteMessage(item.id);
                          },
                          child: Container(
                            width: screenHeight * 6,
                            height: screenHeight * 6,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xffC65D00), width: 1),
                              borderRadius: BorderRadius.all(
                                Radius.circular(screenHeight * 3),
                              ),
                            ),
                            child: Icon(
                              FontAwesomeIcons.trashAlt,
                              color: Color(0xffC65D00),
                              size: screenHeight * 2.5,
                            ),
                          ),
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
                            onPressed: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          ViewMessage(
                                            message: item,
                                            codigoAlunoEol:
                                                widget.codigoAlunoEol,
                                            userId: widget.userId,
                                          )))
                                  .whenComplete(() => _loadingMessages());
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                AutoSizeText(
                                  "LER MENSAGEM",
                                  maxFontSize: 16,
                                  minFontSize: 14,
                                  style: TextStyle(
                                      color: Color(0xffC65D00),
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  width: screenHeight * 2,
                                ),
                                Icon(
                                  FontAwesomeIcons.envelopeOpen,
                                  color: Color(0xffffd037),
                                  size: 16,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))
            .toList());
  }

  Widget _buildListMessages(BuildContext context, num screenHeight) {
    return Observer(builder: (context) {
      if (_messagesController.isLoading) {
        return EALoader();
      } else {
        // _messagesController.loadMessagesNotDeleteds();
        _messagesController.loadMessageToFilters(dreCheck, smeCheck, ueCheck);
        if (_messagesController.messages == null ||
            _messagesController.messages.isEmpty) {
          return Container(
              margin: EdgeInsets.only(top: screenHeight * 2.5),
              child: Visibility(
                visible: _messagesController.messages != null &&
                    _messagesController.messages.isEmpty,
                child: Column(
                  children: <Widget>[
                    AutoSizeText(
                      "Nenhuma mensagem está disponível para este aluno",
                      maxFontSize: 18,
                      minFontSize: 16,
                    ),
                    Divider(
                      color: Color(0xffcecece),
                    )
                  ],
                ),
              ));
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                height: screenHeight * 3,
              ),
              AutoSizeText(
                "MENSAGEM MAIS RECENTE",
                maxFontSize: 18,
                minFontSize: 16,
                style: TextStyle(
                    color: Color(0xffDE9524), fontWeight: FontWeight.w500),
              ),
              GestureDetector(
                onTap: () {
                  _navigateToMessage(
                      context, _messagesController.messages.first);
                },
                child: EACardMensagem(
                  headerTitle:
                      _messagesController.messages.first.categoriaNotificacao,
                  headerIcon: true,
                  recentMessage:
                      !_messagesController.messages.first.mensagemVisualizada,
                  categoriaNotificacao:
                      _messagesController.messages.first.categoriaNotificacao,
                  content: <Widget>[
                    Container(
                      width: screenHeight * 39,
                      child: AutoSizeText(
                        _messagesController.messages.first.titulo,
                        maxFontSize: 16,
                        minFontSize: 14,
                        maxLines: 2,
                        style: TextStyle(
                            color: Color(0xff42474A),
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 1.8,
                    ),
                    Container(
                      width: screenHeight * 39,
                      child: AutoSizeText(
                        StringSupport.parseHtmlString(
                            _messagesController.messages.first.mensagem),
                        maxFontSize: 16,
                        minFontSize: 14,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Color(0xff929292),
                          height: screenHeight * 0.240,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: screenHeight * 3,
                    ),
                    AutoSizeText(
                      DateFormatSuport.formatStringDate(
                          _messagesController.messages.first.criadoEm,
                          'dd/MM/yyyy'),
                      maxFontSize: 16,
                      minFontSize: 14,
                      maxLines: 2,
                      style: TextStyle(
                          color: Color(0xff929292),
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                  footer: true,
                  footerContent: <Widget>[
                    Visibility(
                      visible: _messagesController
                          .messages.first.mensagemVisualizada,
                      child: GestureDetector(
                        onTap: () async {
                          await _confirmDeleteMessage(
                                  _messagesController.messages.first.id)
                              .whenComplete(() => _loadingMessages());
                        },
                        child: Container(
                          width: screenHeight * 6,
                          height: screenHeight * 6,
                          decoration: BoxDecoration(
                            border:
                                Border.all(color: Color(0xffC65D00), width: 1),
                            borderRadius: BorderRadius.all(
                              Radius.circular(screenHeight * 3),
                            ),
                          ),
                          child: Icon(
                            FontAwesomeIcons.trashAlt,
                            color: Color(0xffC65D00),
                          ),
                        ),
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
                          onPressed: () {
                            _navigateToMessage(
                                context, _messagesController.messages.first);
                          },
                          child: Row(
                            children: <Widget>[
                              AutoSizeText(
                                "LER MENSAGEM",
                                maxFontSize: 16,
                                minFontSize: 14,
                                style: TextStyle(
                                    color: Color(0xffC65D00),
                                    fontWeight: FontWeight.w700),
                              ),
                              SizedBox(
                                width: screenHeight * 2,
                              ),
                              Icon(
                                FontAwesomeIcons.envelopeOpen,
                                color: Color(0xffffd037),
                                size: 16,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: screenHeight * 5,
              ),
              _messagesController.messages.length == 1
                  ? Container()
                  : AutoSizeText(
                      (_messagesController.messages.length - 1) == 1
                          ? "${_messagesController.messages.length - 1} MENSAGEM ANTIGA"
                          : "${_messagesController.messages.length - 1} MENSAGENS ANTIGAS",
                      maxFontSize: 18,
                      minFontSize: 16,
                      style: TextStyle(
                          color: Color(0xffDE9524),
                          fontWeight: FontWeight.w500),
                    ),
              EAQFilterPage(
                items: <Widget>[
                  AutoSizeText(
                    "Filtro:",
                    maxFontSize: 14,
                    minFontSize: 12,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xff666666)),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        smeCheck = !smeCheck;
                      });
                      _messagesController.filterItems(
                          dreCheck, smeCheck, ueCheck);
                    },
                    child: Chip(
                      backgroundColor:
                          smeCheck ? Color(0xffEFA2FC) : Color(0xffDADADA),
                      avatar: smeCheck
                          ? Icon(
                              FontAwesomeIcons.check,
                              size: screenHeight * 2,
                            )
                          : null,
                      label: AutoSizeText("SME",
                          style: TextStyle(color: Color(0xff42474A))),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        dreCheck = !dreCheck;
                      });
                      _messagesController.filterItems(
                          dreCheck, smeCheck, ueCheck);
                    },
                    child: Chip(
                      backgroundColor:
                          dreCheck ? Color(0xffC5DBA0) : Color(0xffDADADA),
                      avatar: dreCheck
                          ? Icon(
                              FontAwesomeIcons.check,
                              size: screenHeight * 2,
                            )
                          : null,
                      label: AutoSizeText(
                        "DRE",
                        style: TextStyle(color: Color(0xff42474A)),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        ueCheck = !ueCheck;
                      });
                      _messagesController.filterItems(
                          dreCheck, smeCheck, ueCheck);
                    },
                    child: Chip(
                      backgroundColor:
                          ueCheck ? Color(0xffC7C7FF) : Color(0xffDADADA),
                      avatar: ueCheck
                          ? Icon(
                              FontAwesomeIcons.check,
                              size: screenHeight * 2,
                            )
                          : null,
                      label: AutoSizeText("UE",
                          style: TextStyle(color: Color(0xff42474A))),
                    ),
                  )
                ],
              ),
              Observer(builder: (context) {
                // !dreCheck && !smeCheck && !ueCheck
                if (_messagesController.filteredList != null &&
                    _messagesController.filteredList.isNotEmpty) {
                  return _listCardsMessages(
                      _messagesController.filteredList, context, screenHeight);
                } else if (!dreCheck && !smeCheck && !ueCheck) {
                  return Container(
                    padding: EdgeInsets.all(screenHeight * 2.5),
                    margin: EdgeInsets.only(top: screenHeight * 2.5),
                    child: AutoSizeText(
                      "Selecione uma categoria para visualizar as mensagens.",
                      textAlign: TextAlign.center,
                      minFontSize: 14,
                      maxFontSize: 16,
                      style: TextStyle(
                        color: Color(0xff727374),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                } else {
                  return Container(
                    padding: EdgeInsets.all(screenHeight * 4),
                    margin: EdgeInsets.only(top: screenHeight * 2.5),
                    child: AutoSizeText(
                      "Não foi encontrada nenhuma mensagem para este filtro",
                      textAlign: TextAlign.center,
                      minFontSize: 14,
                      maxFontSize: 16,
                      style: TextStyle(
                        color: Color(0xff727374),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }
              }),
            ],
          );
        }
      }
    });
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
          title: Text("Mensagens"),
          backgroundColor: Color(0xffEEC25E),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop(true);
            },
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await _messagesController.loadMessages(
                widget.codigoAlunoEol, widget.userId);
          },
          child: SingleChildScrollView(
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(
                  horizontal: screenHeight * 2.5, vertical: screenHeight * 2.5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _buildListMessages(context, screenHeight),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
