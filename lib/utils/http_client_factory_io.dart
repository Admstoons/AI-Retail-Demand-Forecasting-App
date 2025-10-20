import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import 'timeout_client.dart';
import 'http_timeout.dart';

http.Client createHttpClient() {
  final HttpClient ioHttpClient = HttpClient()
    ..connectionTimeout = kHttpTimeout;
  final http.Client base = IOClient(ioHttpClient);
  return TimeoutClient(base, kHttpTimeout);
}


