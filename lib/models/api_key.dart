import 'dart:async' show Future;
import 'package:flutter/services.dart' show rootBundle;

class ApiKey {
  String _file = '';
  ApiKey(String fileName) {
    _file = fileName;
  }

  Future<String> readApiKey() async {
    return await rootBundle.loadString('assets/$_file');
  }
}
