import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class Client {
  // Recebe todos os dados
  String baseUrl = 'http://10.0.2.2:8000/array/';

  var lista = [];

  Future<List> getAllDados() async {
    try {
      var response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return Future.error('Server error');
      }
    } catch (e) {
      return Future.error(e);
    }
  }


  uploadText() async {
    try {
      var response = await http.post(Uri.parse(baseUrl + "createTeste"), body: {"body": "Upload text from flutter"});

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return Future.error('Server error');
      }
    } catch (e) {
      return Future.error(e);
    }
  }


  uploadImage(File file) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl + "createImage"));

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        return 'Server ok';
      } else {
        return Future.error('Server error');
      }
    } catch (e) {
      return Future.error(e);
    }
  }
}