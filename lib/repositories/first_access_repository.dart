import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:sme_app_aluno/interfaces/first_access_repository_interface.dart';
import 'package:sme_app_aluno/models/change_email_and_phone/data_change_email_and_phone.dart';
import 'package:sme_app_aluno/models/first_access/data.dart';
import 'package:sme_app_aluno/models/models.dart';
import 'package:sme_app_aluno/services/user.service.dart';
import 'package:sme_app_aluno/utils/utils.dart';

class FirstAccessRepository implements IFirstAccessRepository {
  final UserService _userService = UserService();
  @override
  Future<Data> changeNewPassword(int id, String password) async {
    final Usuario user = await _userService.find(id);

    int _id = user.id;
    Map _data = {
      "id": _id,
      "novaSenha": password,
    };

    var body = json.encode(_data);
    try {
      final response = await http.post(
        "${ApiUtil.HOST}/Autenticacao/PrimeiroAcesso",
        headers: {
          "Authorization": "Bearer ${user.token}",
          "Content-Type": "application/json",
        },
        body: body,
      );
      var decodeJson = jsonDecode(response.body);
      var data = Data.fromJson(decodeJson);
      if (response.statusCode == 200) {
        await _userService.update(Usuario(
          id: user.id,
          nome: user.nome,
          cpf: user.cpf,
          email: user.email,
          celular: user.celular,
          token: user.token,
          primeiroAcesso: false,
          informarCelularEmail: true,
        ));

        return data;
      } else if (response.statusCode == 408) {
        return Data(ok: false, erros: [GlobalConfig.ERROR_MESSAGE_TIME_OUT]);
      } else {
        var decodeError = jsonDecode(response.body);
        var dataError = Data.fromJson(decodeError);
        return dataError;
      }
    } catch (error, stacktrace) {
      print("[fetchFirstAccess] Erro de requisição " + stacktrace.toString());
      return null;
    }
  }

  @override
  Future<DataChangeEmailAndPhone> changeEmailAndPhone(
      String email, String phone, int userId, bool changePassword) async {
    final Usuario user = await _userService.find(userId);
    String token = user.token;

    Map _data = {
      "id": userId,
      "email": email ?? "",
      "celular": phone ?? "",
      "alterarSenha": changePassword
    };
    var body = json.encode(_data);
    try {
      final response = await http.post(
        "${ApiUtil.HOST}/Autenticacao/AlterarEmailCelular",
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
        body: body,
      );
      if (response.statusCode == 200) {
        var decodeJson = jsonDecode(response.body);
        var data = DataChangeEmailAndPhone.fromJson(decodeJson);
        await _userService.update(Usuario(
            id: userId,
            nome: user.nome,
            cpf: user.cpf,
            email: email,
            celular: phone,
            token: data.token,
            primeiroAcesso: false,
            informarCelularEmail: false));
        return data;
      } else {
        var decodeError = jsonDecode(response.body);
        var dataError = DataChangeEmailAndPhone.fromJson(decodeError);
        return dataError;
      }
    } catch (error, stacktrace) {
      print(
          "[changeEmailAndPhone] Erro de requisição " + stacktrace.toString());
      return null;
    }
  }
}
