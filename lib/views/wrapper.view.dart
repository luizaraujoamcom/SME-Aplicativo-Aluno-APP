import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:provider/provider.dart';
import 'package:sme_app_aluno/controllers/auth/authenticate.controller.dart';
import 'package:sme_app_aluno/models/message/message.dart';
import 'package:sme_app_aluno/models/user/user.dart';
import 'package:sme_app_aluno/views/change_email_or_phone/change_email_or_phone.dart';
import 'package:sme_app_aluno/views/login.view.dart';
import 'package:sme_app_aluno/views/messages/mensagem-notificacao.view.dart';
import 'package:sme_app_aluno/views/not_internet/not_internet.dart';
import 'package:sme_app_aluno/services/user.service.dart';
import 'package:sme_app_aluno/utils/conection.dart';
import 'package:sme_app_aluno/utils/navigator.dart';
import 'package:sme_app_aluno/views/views.dart';
import 'package:sme_app_aluno/widgets/widgets.dart';

class WrapperView extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<WrapperView> {
  final UserService _userService = UserService();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  AuthenticateController _authenticateController;

  @override
  initState() {
    super.initState();
    _initPushNotificationHandlers();
    _authenticateController = AuthenticateController();
    loadUsers();
  }

  loadUsers() async {
    await _authenticateController.loadCurrentUser();
  }

  _initPushNotificationHandlers() {
    _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.getToken().then(print);
    _firebaseMessaging.subscribeToTopic("AppAluno");
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        _popUpNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        await _navigateToMessageView(message);
      },
      onResume: (Map<String, dynamic> message) async {
        await _navigateToMessageView(message);
      },
    );
  }

  _popUpNotification(Map<String, dynamic> message) {
    AwesomeDialog(
        context: context,
        headerAnimationLoop: true,
        dialogType: DialogType.SUCCES,
        animType: AnimType.BOTTOMSLIDE,
        title: "NOTIFICAÇÃO - ${message["data"]["categoriaNotificacao"]}",
        desc: "Você acaba de receber uma \n mensagem.",
        btnOkOnPress: () {
          _navigateToMessageView(message);
        },
        btnOkText: "VISUALIZAR")
      ..show();
  }

  _navigateToMessageView(Map<String, dynamic> message) async {
    final List<User> users = await _userService.all();

    var user = users[0];

    Message _message = Message(
      id: int.parse(message["data"]["Id"]),
      titulo: message["data"]["Titulo"],
      mensagem: message["data"]["Mensagem"],
      criadoEm: message["data"]["CriadoEm"],
      codigoEOL: message["data"]["CodigoEOL"] != null
          ? int.parse(message["data"]["CodigoEOL"])
          : 0,
      categoriaNotificacao: message["data"]["categoriaNotificacao"],
    );
    Nav.push(
        context,
        MensagemNotificacaoView(
          message: _message,
          userId: user.id,
        ));
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
      return Observer(builder: (context) {
        if (_authenticateController.user == null) {
          return Scaffold(
              backgroundColor: Colors.white,
              body: _authenticateController.isLoading ? EALoader() : Login());
        } else {
          if (_authenticateController.user.primeiroAcesso) {
            return PrimeiroAcessoView(
              id: _authenticateController.user.id,
              cpf: _authenticateController.user.cpf,
            );
          } else if (_authenticateController.user.informarCelularEmail) {
            return ChangeEmailOrPhone(
              cpf: _authenticateController.user.cpf,
              userId: _authenticateController.user.id,
            );
          } else {
            return EstudanteListaView(
              userId: _authenticateController.user.id,
            );
          }
        }
      });
    }
  }
}
