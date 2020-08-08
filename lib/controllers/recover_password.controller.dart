import 'package:mobx/mobx.dart';
import 'package:sme_app_aluno/repositories/recover_password_repository.dart';

part 'recover_password.controller.g.dart';

class RecoverPasswordController = _RecoverPasswordControllerBase
    with _$RecoverPasswordController;

RecoverPasswordRepository _recoverPasswordRepository;

abstract class _RecoverPasswordControllerBase with Store {
  _RecoverPasswordControllerBase() {
    _recoverPasswordRepository = RecoverPasswordRepository();
  }

  @observable
  String email;

  @observable
  bool loading = false;

  @action
  sendToken(String cpf) async {
    loading = true;
    email = await _recoverPasswordRepository.sendToken(cpf);
    loading = false;
  }

  @action
  validateToken(String token) async {
    loading = true;
    email = await _recoverPasswordRepository.validateToken(token);
    loading = false;
  }
}
