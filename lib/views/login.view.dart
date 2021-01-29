import 'package:auto_size_text/auto_size_text.dart';
import 'package:brasil_fields/brasil_fields.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sme_app_aluno/controllers/auth/authenticate.controller.dart';
import 'package:sme_app_aluno/models/models.dart';
import 'package:sme_app_aluno/views/change_email_or_phone/change_email_or_phone.dart';
import 'package:sme_app_aluno/views/recover_password/recover_password.dart';
import 'package:sme_app_aluno/widgets/buttons/button.widget.dart';
import 'package:sme_app_aluno/services/user.service.dart';
import 'package:sme_app_aluno/utils/navigator.util.dart';
import 'package:sme_app_aluno/themes/app.theme.dart';
import 'package:sme_app_aluno/widgets/widgets.dart';
import 'package:sme_app_aluno/views/views.dart';

class Login extends StatefulWidget {
  final String notice;

  Login({this.notice});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  AuthenticateController _authenticateController;
  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();
  final scaffoldKey = new GlobalKey<ScaffoldState>();

  bool _showPassword = true;
  bool _cpfIsError = false;
  bool _passwordIsError = false;

  String _cpf = '';
  String _cpfRaw = '';
  String _password = '';

  @override
  void initState() {
    super.initState();
    _authenticateController = AuthenticateController();
  }

  _handleSignIn(
    String cpf,
    String password,
  ) async {
    await _authenticateController.authenticateUser(cpf, password);
    _navigateToScreen();
  }

  _navigateToScreen() async {
    if (_authenticateController.currentUser.data != null) {
      Usuario user =
          await _userService.find(_authenticateController.currentUser.data.id);
      if (_authenticateController.currentUser.data.primeiroAcesso) {
        Nav.push(
            context,
            PrimeiroAcessoView(
              id: _authenticateController.currentUser.data.id,
              cpf: _authenticateController.currentUser.data.cpf,
            ));
      } else if (user.informarCelularEmail) {
        Nav.push(
            context,
            ChangeEmailOrPhone(
              cpf: _authenticateController.currentUser.data.cpf,
              userId: _authenticateController.currentUser.data.id,
            ));
      } else {
        Nav.push(
            context,
            EstudanteListaView(
              userId: user.id,
            ));
      }
    } else {
      onError();
    }
  }

  onError() {
    var snackbar = SnackBar(
        backgroundColor: Colors.red,
        content: _authenticateController.currentUser != null
            ? Text(_authenticateController.currentUser.erros[0])
            : Text("Erro de serviço"));

    scaffoldKey.currentState.showSnackBar(snackbar);
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    var screenHeight = (size.height - MediaQuery.of(context).padding.top) / 100;

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: Colors.white,
      body: WillPopScope(
        onWillPop: () async => false,
        child: SingleChildScrollView(
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
                            top: screenHeight * 8, bottom: screenHeight * 6),
                        child: Image.asset(assetLogoEscolaAqui),
                      ),
                      Form(
                        autovalidate: true,
                        key: _formKey,
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              widget.notice != null
                                  ? Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(screenHeight * 1.5),
                                        ),
                                      ),
                                      padding: EdgeInsets.all(screenHeight * 2),
                                      child: AutoSizeText(
                                        widget.notice,
                                        maxFontSize: 18,
                                        minFontSize: 16,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )
                                  : SizedBox.shrink(),
                              SizedBox(
                                height: screenHeight * 4,
                              ),
                              Container(
                                padding:
                                    EdgeInsets.only(left: screenHeight * 2),
                                decoration: BoxDecoration(
                                  color: corCinzaClaro,
                                  border: Border(
                                      bottom: BorderSide(
                                          color: _cpfIsError
                                              ? Colors.red
                                              : corLaranja,
                                          width: screenHeight * 0.39)),
                                ),
                                child: TextFormField(
                                  style: TextStyle(
                                      color: corCinzaEscuro,
                                      fontWeight: FontWeight.w600),
                                  decoration: InputDecoration(
                                    labelText: 'Usuário',
                                    labelStyle: TextStyle(color: corCinzaMedio),
                                    errorStyle:
                                        TextStyle(fontWeight: FontWeight.w700),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _cpf = CPFValidator.strip(value);
                                    });

                                    setState(() {
                                      _cpfRaw = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value.isNotEmpty) {
                                      if (!CPFValidator.isValid(_cpf)) {
                                        return 'CPF inválido';
                                      }
                                    }

                                    return null;
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    CpfInputFormatter(),
                                  ],
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 1,
                              ),
                              AutoSizeText(
                                "Digite o CPF do responsável",
                                maxFontSize: 14,
                                minFontSize: 12,
                                style: TextStyle(color: corCinzaMedio2),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: screenHeight * 5),
                                padding:
                                    EdgeInsets.only(left: screenHeight * 2),
                                decoration: BoxDecoration(
                                  color: corCinzaClaro,
                                  border: Border(
                                      bottom: BorderSide(
                                          color: _passwordIsError
                                              ? Colors.red
                                              : corLaranja,
                                          width: screenHeight * 0.39)),
                                ),
                                child: TextFormField(
                                  style: TextStyle(
                                      color: corCinzaEscuro,
                                      fontWeight: FontWeight.w600),
                                  obscureText: _showPassword,
                                  onChanged: (value) {
                                    setState(() {
                                      _password = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value.isNotEmpty) {
                                      if (value.length <= 7) {
                                        return 'Sua senha deve conter no mínimo 8 caracteres';
                                      }
                                    }

                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    suffixIcon: IconButton(
                                      icon: _showPassword
                                          ? Icon(FontAwesomeIcons.eye)
                                          : Icon(FontAwesomeIcons.eyeSlash),
                                      color: corCinzaMedio3,
                                      iconSize: screenHeight * 3.0,
                                      onPressed: () {
                                        setState(() {
                                          _showPassword = !_showPassword;
                                        });
                                      },
                                    ),
                                    labelText: 'Senha',
                                    labelStyle: TextStyle(color: corCinzaMedio),
                                    errorStyle:
                                        TextStyle(fontWeight: FontWeight.w700),
                                    // hintText: "Data de nascimento do aluno",
                                    border: InputBorder.none,
                                  ),
                                  keyboardType: TextInputType.text,
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 1,
                              ),
                              AutoSizeText(
                                "Digite a sua senha. Caso você ainda não tenha uma senha pessoal informe a data de nascimento do aluno no padrão ddmmaaaa.",
                                maxFontSize: 14,
                                minFontSize: 12,
                                maxLines: 3,
                                style: TextStyle(
                                  color: corCinzaMedio2,
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 3,
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Nav.push(context,
                                        RecoverPassword(input: _cpfRaw));
                                  },
                                  child: AutoSizeText(
                                    "Esqueci minha senha",
                                    maxFontSize: 14,
                                    minFontSize: 12,
                                    maxLines: 3,
                                    style: TextStyle(
                                        color: corCinzaMedio4,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: screenHeight * 4,
                              ),
                              Observer(builder: (context) {
                                if (_authenticateController.isLoading) {
                                  return EALoader();
                                } else {
                                  return EAButton(
                                    text: "ENTRAR",
                                    icon: FontAwesomeIcons.chevronRight,
                                    iconColor: corAmarelo1,
                                    btnColor: corLaranja,
                                    desabled: CPFValidator.isValid(_cpf) &&
                                        _password.length >= 7,
                                    onPress: () {
                                      if (_formKey.currentState.validate()) {
                                        _handleSignIn(_cpf, _password);
                                      } else {
                                        setState(() {
                                          _cpfIsError = true;
                                          _passwordIsError = true;
                                        });
                                      }
                                    },
                                  );
                                }
                              }),
                            ]),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: screenHeight * 6,
                  margin: EdgeInsets.only(top: 70),
                  child: Image.asset(assetLogoSME, fit: BoxFit.cover),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
