import 'package:sme_app_aluno/models/models.dart';

class Data {
  bool ok;
  List<String> erros;
  Usuario data;

  Data({this.ok, this.erros, this.data});

  Data.fromJson(Map<String, dynamic> json) {
    ok = json['ok'];
    erros = json['erros'].cast<String>();
    data = json['data'] != null ? new Usuario.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['ok'] = this.ok;
    data['erros'] = this.erros;
    if (this.data != null) {
      data['user'] = this.data.toJson();
    }
    return data;
  }
}
