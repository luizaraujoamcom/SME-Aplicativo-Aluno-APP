import 'package:background_fetch/background_fetch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sme_app_aluno/controllers/terms/terms.controller.dart';
import 'package:sme_app_aluno/service.locator.dart';
import 'package:sme_app_aluno/themes/app.theme.dart';
import 'package:sme_app_aluno/views/views.dart';
import 'package:sme_app_aluno/utils/conection.util.dart';
import 'package:sentry/sentry.dart';

import 'controllers/auth/authenticate.controller.dart';
import 'controllers/auth/first_access.controller.dart';
import 'controllers/auth/recover_password.controller.dart';
import 'controllers/messages/messages.controller.dart';
import 'controllers/students/students.controller.dart';
import 'package:intl/date_symbol_data_local.dart' as date_symbol_data_local;
import 'package:flutter_dotenv/flutter_dotenv.dart' as DotEnv;

/// This "Headless Task" is run when app is terminated.
void backgroundFetchHeadlessTask(String taskId) async {
  BackgroundFetch.finish(taskId);
}

void main() async {
  await DotEnv.load(fileName: ".env");
  final SentryClient sentry = new SentryClient(dsn: DotEnv.env['SENTRY_DSN']);

  try {} catch (error, stackTrace) {
    await sentry.captureException(
      exception: error,
      stackTrace: stackTrace,
    );
  }
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Color(0xffde9524),
    statusBarBrightness: Brightness.dark,
    // status bar color
  ));

  setupLocator();
  runApp(MyApp());

  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends StatelessWidget {
  MyApp() {
    date_symbol_data_local.initializeDateFormatting();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticateController>.value(value: AuthenticateController()),
        Provider<StudentsController>.value(value: StudentsController()),
        Provider<MessagesController>.value(value: MessagesController()),
        Provider<RecoverPasswordController>.value(
            value: RecoverPasswordController()),
        Provider<FirstAccessController>.value(value: FirstAccessController()),
        Provider<TermsController>.value(value: TermsController()),
        StreamProvider<ConnectivityStatus>(
            create: (context) =>
                ConnectivityService().connectionStatusController.stream),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'SME Aplicativo do Aluno',
        theme: appTheme(),
        home: WrapperView(),
      ),
    );
  }
}
