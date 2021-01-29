import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sme_app_aluno/interfaces/ue_repository_interface.dart';
import 'package:sme_app_aluno/models/ue/data_ue.dart';
import 'package:sme_app_aluno/models/models.dart';
import 'package:sme_app_aluno/services/user.service.dart';
import 'package:sme_app_aluno/utils/utils.dart';

class UERepository extends IUERepository {
  final UserService _userService = UserService();

  @override
  Future<DadosUE> fetchUE(String codigoUe, int id) async {
    final Usuario user = await _userService.find(id);
    try {
      var response = await http.get("${ApiUtil.HOST}/UnidadeEscolar/$codigoUe",
          headers: {"Authorization": "Bearer ${user.token}"});
      if (response.statusCode == 200) {
        var ueResponse = jsonDecode(response.body);
        var ue = DadosUE.fromJson(ueResponse);
        return ue;
      } else {
        print('Erro ao obter dados');
        return null;
      }
    } catch (e) {
      print('$e');
      return null;
    }
  }
}
