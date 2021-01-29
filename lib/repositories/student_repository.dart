import 'dart:convert';

import 'package:sme_app_aluno/interfaces/student_repository_interface.dart';
import 'package:http/http.dart' as http;
import 'package:sme_app_aluno/models/student/data_student.dart';
import 'package:sme_app_aluno/models/models.dart';
import 'package:sme_app_aluno/services/user.service.dart';
import 'package:sme_app_aluno/utils/utils.dart';

class StudentRepository implements IStudentsRepository {
  final UserService _userService = UserService();

  @override
  Future<DataStudent> fetchStudents(String cpf, int id) async {
    final Usuario user = await _userService.find(id);
    try {
      final response = await http.post("${ApiUtil.HOST}/Aluno?cpf=$cpf",
          headers: {"Authorization": "Bearer ${user.token}"});

      if (response.statusCode == 200) {
        var decodeJson = jsonDecode(response.body);
        final dataEstudents = DataStudent.fromJson(decodeJson);
        return dataEstudents;
      } else if (response.statusCode == 408) {
        return DataStudent(
            ok: false, erros: [GlobalConfig.ERROR_MESSAGE_TIME_OUT]);
      } else {
        var decodeError = jsonDecode(response.body);
        var dataError = DataStudent.fromJson(decodeError);
        return dataError;
      }
    } catch (e, stacktrace) {
      print("Erro ao carregar lista de Estudantes " + stacktrace.toString());
      return null;
    }
  }
}
