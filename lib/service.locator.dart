import 'package:get_it/get_it.dart';
import 'package:sme_app_aluno/models/models.dart';

GetIt servicelocator = GetIt.instance();
void setupLocator() {
  servicelocator.registerFactory(() => Usuario());
}
