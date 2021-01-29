import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiUtil {
  static String get HOST => env['API_URL'];
}
