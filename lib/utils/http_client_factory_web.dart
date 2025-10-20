import 'package:http/http.dart' as http;
import 'timeout_client.dart';
import 'http_timeout.dart';

http.Client createHttpClient() {
  final http.Client base = http.Client();
  return TimeoutClient(base, kHttpTimeout);
}


