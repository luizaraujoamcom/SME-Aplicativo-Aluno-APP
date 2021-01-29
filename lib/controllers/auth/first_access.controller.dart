import 'package:mobx/mobx.dart';
import 'package:sme_app_aluno/models/change_email_and_phone/data_change_email_and_phone.dart';
import 'package:sme_app_aluno/models/first_access/data.dart';
import 'package:sme_app_aluno/models/models.dart';
import 'package:sme_app_aluno/repositories/first_access_repository.dart';
import 'package:sme_app_aluno/services/user.service.dart';

part 'first_access.controller.g.dart';

class FirstAccessController = _FirstAccessControllerBase
    with _$FirstAccessController;

abstract class _FirstAccessControllerBase with Store {
  FirstAccessRepository _firstAccessRepository;
  final UserService _userService = UserService();
  _FirstAccessControllerBase() {
    _firstAccessRepository = FirstAccessRepository();
  }

  @observable
  Data data;

  @observable
  DataChangeEmailAndPhone dataEmailOrPhone;

  bool isLoading = false;

  @observable
  String currentEmail;

  @observable
  String currentPhone;

  @action
  changeNewPassword(int id, String password) async {
    isLoading = true;
    data = await _firstAccessRepository.changeNewPassword(id, password);
    isLoading = false;
  }

  @action
  changeEmailAndPhone(
      String email, String phone, int userId, bool changePassword) async {
    isLoading = true;
    dataEmailOrPhone = await _firstAccessRepository.changeEmailAndPhone(
        email, phone, userId, changePassword);
    isLoading = false;
  }

  @action
  loadUserForStorage(int userId) async {
    Usuario user = await _userService.find(userId);
    currentEmail = user.email;
    currentPhone = user.celular;
  }
}
