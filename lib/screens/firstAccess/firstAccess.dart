import 'package:auto_size_text/auto_size_text.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_ip/get_ip.dart';
import 'package:getflutter/getflutter.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sme_app_aluno/controllers/auth/authenticate.controller.dart';
import 'package:sme_app_aluno/controllers/auth/first_access.controller.dart';
import 'package:sme_app_aluno/controllers/terms/terms.controller.dart';
import 'package:sme_app_aluno/screens/change_email_or_phone/change_email_or_phone.dart';
import 'package:sme_app_aluno/screens/terms/terms_view.dart';

import 'package:sme_app_aluno/screens/widgets/buttons/eabutton.dart';
import 'package:sme_app_aluno/screens/widgets/check_line/check_line.dart';
import 'package:sme_app_aluno/screens/widgets/info_box/info_box.dart';

class FirstAccess extends StatefulWidget {
  final int id;
  final String cpf;

  FirstAccess({@required this.id, @required this.cpf});

  @override
  _FirstAccessState createState() => _FirstAccessState();
}

class _FirstAccessState extends State<FirstAccess> {
  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  final numeric = RegExp(r"[0-9]");
  final symbols = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  final upperCaseChar = RegExp(r"[A-Z]");
  final lowCaseChar = RegExp(r"[a-z]");
  final accentLowcase = RegExp(r'[à-ú]');
  final accentUppercase = RegExp(r'[À-Ú]');
  final spaceNull = RegExp(r"[/\s/]");

  FirstAccessController _firstAccessController;

  TermsController _termsController;
  AuthenticateController _authenticateController;
  String _ip = 'Unknown';
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  ReactionDisposer _disposer;

  bool _showPassword = true;
  bool _busy = false;
  bool _passwordIsError = false;
  String _password = '';
  String _confirmPassword = '';
  bool _statusTerm = false;

  loading() async {
    _firstAccessController = FirstAccessController();
    _termsController = TermsController();
    _authenticateController = AuthenticateController();
    _termsController.fetchVerifyTerm(widget.cpf);
  }

  @override
  void initState() {
    super.initState();
    loading();
  }

  _navigateToScreen() {
    if (_firstAccessController.data.ok) {
      Navigator.of(context).pushReplacement(CupertinoPageRoute(
          builder: (_) => ChangeEmailOrPhone(
                cpf: widget.cpf,
                password: _password,
                userId: widget.id,
              )));
    } else {
      onError();
    }
  }

  Future<void> initPlatformState() async {
    String ipAddress;
    try {
      ipAddress = await GetIp.ipAddress;
    } on PlatformException {
      ipAddress = 'Failed to get ipAddress.';
    }
    if (!mounted) return;
    setState(() {
      _ip = ipAddress;
    });
  }

  _register() async {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    print('Running on ${androidInfo.id}');

    // IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    // print('Running on ${iosInfo.utsname.machine}');

    String deviceId = androidInfo.id;
    // Platform.isAndroid ? androidInfo.id : iosInfo.utsname.machine;

    await _termsController.registerTerms(_termsController.term.id, widget.cpf,
        deviceId, _ip, _termsController.term.versao);
  }

  _registerNewPassword(String password) async {
    setState(() {
      _busy = true;
    });
    await _firstAccessController.changeNewPassword(widget.id, password);
    _navigateToScreen();
    setState(() {
      _busy = false;
    });
  }

  onError() {
    var snackbar = SnackBar(
        backgroundColor: Colors.red,
        content: _firstAccessController.data != null
            ? Text(_firstAccessController.data.erros[0])
            : Text("Erro de serviço"));

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  howModalBottomSheetTerm() {
    return showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(25), topLeft: Radius.circular(25)),
              color: Colors.white),
          height: MediaQuery.of(context).size.height - 100,
          child: TermsView(
            button: true,
            changeStatusTerm: () => changeStatusTerm(),
            cpf: widget.cpf,
          )),
    );
  }

  changeStatusTerm() {
    setState(() {
      _statusTerm = true;
      print(_statusTerm);
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var screenHeight = (size.height - MediaQuery.of(context).padding.top) / 100;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenHeight * 2.5),
          child: Column(
            children: <Widget>[
              Container(
                child: Column(
                  children: <Widget>[
                    Container(
                      width: screenHeight * 36,
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(
                          top: screenHeight * 8, bottom: screenHeight * 2),
                      child: Image.asset("assets/images/Logo_escola_aqui.png"),
                    ),
                    Container(
                        margin: EdgeInsets.only(bottom: screenHeight * 3),
                        child: AutoSizeText(
                          "Primeiro Acesso! Cadastre uma nova senha",
                          maxFontSize: 18,
                          minFontSize: 16,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff757575)),
                        )),
                    Form(
                      key: _formKey,
                      autovalidate: true,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: screenHeight * 2),
                              decoration: BoxDecoration(
                                color: Color(0xfff0f0f0),
                                border: Border(
                                    bottom: BorderSide(
                                        color: _passwordIsError
                                            ? Colors.red
                                            : Color(0xffD06D12),
                                        width: screenHeight * 0.39)),
                              ),
                              child: TextFormField(
                                  obscureText: _showPassword,
                                  style: TextStyle(
                                      color: Color(0xff333333),
                                      fontWeight: FontWeight.w600),
                                  onChanged: (value) {
                                    setState(() {
                                      _password = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value.isNotEmpty) {
                                      if (spaceNull.hasMatch(value)) {
                                        return "Senha não pode ter espaço em branco";
                                      }
                                    }

                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    labelText: 'Nova senha',
                                    labelStyle:
                                        TextStyle(color: Color(0xff8e8e8e)),
                                    errorStyle:
                                        TextStyle(fontWeight: FontWeight.w700),
                                    // hintText: "Data de nascimento do aluno",
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.text),
                            ),
                            SizedBox(
                              height: screenHeight * 1,
                            ),
                            Container(
                              margin: EdgeInsets.only(top: screenHeight * 5),
                              padding: EdgeInsets.only(left: screenHeight * 2),
                              decoration: BoxDecoration(
                                color: Color(0xfff0f0f0),
                                border: Border(
                                    bottom: BorderSide(
                                        color: _passwordIsError
                                            ? Colors.red
                                            : Color(0xffD06D12),
                                        width: screenHeight * 0.39)),
                              ),
                              child: TextFormField(
                                style: TextStyle(
                                    color: Color(0xff333333),
                                    fontWeight: FontWeight.w600),
                                obscureText: _showPassword,
                                onChanged: (value) {
                                  setState(() {
                                    _confirmPassword = value;
                                  });
                                },
                                decoration: InputDecoration(
                                  suffixIcon: IconButton(
                                    icon: _showPassword
                                        ? Icon(FontAwesomeIcons.eye)
                                        : Icon(FontAwesomeIcons.eyeSlash),
                                    color: Color(0xff6e6e6e),
                                    iconSize: screenHeight * 3.0,
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                  ),

                                  labelText: 'Confirmar a nova senha',
                                  labelStyle:
                                      TextStyle(color: Color(0xff8e8e8e)),
                                  errorStyle:
                                      TextStyle(fontWeight: FontWeight.w700),
                                  // hintText: "Data de nascimento do aluno",
                                  border: InputBorder.none,
                                ),
                                validator: (value) {
                                  if (value.isNotEmpty) {
                                    if (value != _password) {
                                      return "Senhas não correspondem";
                                    }
                                  }

                                  return null;
                                },
                                keyboardType: TextInputType.text,
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 1,
                            ),
                            InfoBox(
                              icon: FontAwesomeIcons.exclamationTriangle,
                              content: <Widget>[
                                AutoSizeText(
                                  "Requisitos para sua nova senha!",
                                  maxFontSize: 18,
                                  minFontSize: 16,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xff717171)),
                                ),
                                SizedBox(
                                  height: screenHeight * 2,
                                ),
                                CheckLine(
                                    screenHeight: screenHeight,
                                    text: "Uma letra maiúscula",
                                    checked: upperCaseChar.hasMatch(_password)),
                                CheckLine(
                                    screenHeight: screenHeight,
                                    text: "Uma letra minúscula",
                                    checked: lowCaseChar.hasMatch(_password)),
                                CheckLine(
                                  screenHeight: screenHeight,
                                  text:
                                      "Um algarismo (número) ou um símbolo (caractere especial)",
                                  checked: (numeric.hasMatch(_password) ||
                                      symbols.hasMatch(_password)),
                                ),
                                CheckLine(
                                  screenHeight: screenHeight,
                                  text:
                                      "Não pode permitir caracteres acentuados",
                                  checked: _password.length > 0 &&
                                      !accentUppercase.hasMatch(_password) &&
                                      !accentLowcase.hasMatch(_password),
                                ),
                                CheckLine(
                                    screenHeight: screenHeight,
                                    text:
                                        "Deve ter no mínimo 8 e no máximo 12 caracteres.",
                                    checked: _password.length >= 8 &&
                                        _password.length <= 12),
                              ],
                            ),
                            Visibility(
                              child: GestureDetector(
                                  child: InfoBox(
                                    icon: FontAwesomeIcons.exclamationTriangle,
                                    content: <Widget>[
                                      AutoSizeText(
                                        "Você precisa aceitar os Termos de Uso",
                                        maxFontSize: 18,
                                        minFontSize: 16,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff717171)),
                                      ),
                                      SizedBox(
                                        height: screenHeight * 2,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Wrap(
                                            children: [
                                              AutoSizeText(
                                                "Ler termos de uso",
                                                maxFontSize: 16,
                                                minFontSize: 14,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xff717171)),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(FontAwesomeIcons.fileAlt,
                                                  size: 16,
                                                  color: Color(0xff717171)),
                                            ],
                                          ),
                                          _statusTerm
                                              ? Icon(
                                                  Icons.check_box,
                                                  color: Color(0xffd06d12),
                                                )
                                              : Icon(
                                                  Icons.check_box_outline_blank,
                                                  color: Color(0xff8e8e8e))
                                        ],
                                      )
                                    ],
                                  ),
                                  onTap: () => howModalBottomSheetTerm()),
                              visible: !_termsController.isTerm,
                              replacement: GFLoader(
                                type: GFLoaderType.square,
                                loaderColorOne: Color(0xffDE9524),
                                loaderColorTwo: Color(0xffC65D00),
                                loaderColorThree: Color(0xffC65D00),
                                size: GFSize.LARGE,
                              ),
                            ),
                            SizedBox(height: screenHeight * 3),
                            !_busy
                                ? EAButton(
                                    text: "CADASTRAR",
                                    icon: FontAwesomeIcons.chevronRight,
                                    iconColor: Color(0xffffd037),
                                    btnColor: Color(0xffd06d12),
                                    desabled: (_password.isNotEmpty &&
                                            _confirmPassword.isNotEmpty &&
                                            !spaceNull.hasMatch(_password)) &&
                                        (_confirmPassword == _password),
                                    // && (_termsController.isTerm == false || _statusTerm == true),
                                    onPress: () async {
                                      await _registerNewPassword(_password);
                                      await _register();
                                    },
                                  )
                                : GFLoader(
                                    type: GFLoaderType.square,
                                    loaderColorOne: Color(0xffDE9524),
                                    loaderColorTwo: Color(0xffC65D00),
                                    loaderColorThree: Color(0xffC65D00),
                                    size: GFSize.LARGE,
                                  ),
                          ]),
                    ),
                  ],
                ),
              ),
              Container(
                height: screenHeight * 6,
                margin: EdgeInsets.only(top: 70),
                child: Image.asset("assets/images/logo_sme.png",
                    fit: BoxFit.cover),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _disposer();
    super.dispose();
  }
}
