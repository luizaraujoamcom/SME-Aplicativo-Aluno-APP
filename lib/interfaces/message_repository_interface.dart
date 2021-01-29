import 'package:sme_app_aluno/models/message/message.dart';
import 'package:sme_app_aluno/models/models.dart';

abstract class IMessageRepository {
  Future<List<Message>> fetchNewMessages(int codigoEol, Usuario user);

  Future<List<Message>> fetchMessages(int codigoEol, int userId);

  Future<bool> readMessage(int notificacaoId, int usuarioId, int codigoAlunoEol,
      bool mensagemVisualia);

  Future<bool> deleteMessage(int codigoEol, int idNotificacao, int userId);
}
