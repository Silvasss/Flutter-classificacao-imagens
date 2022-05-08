import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image1;
import 'package:image_picker/image_picker.dart';
import 'package:teste/client.dart';


class modelo extends StatefulWidget {
  const modelo({Key? key}) : super(key : key);

  @override
  _modeloState createState() => _modeloState();
}

class _modeloState extends State<modelo> {

  late File _image;
  late String _results;
  bool imageSelect = false;

  Client clientService = Client();

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Image Classification"),
      ),
      body: ListView(
        children: [
          (imageSelect)?Container(
            margin: const EdgeInsets.all(10),
            child: Image.file(_image),
          ):Container(
            margin: const EdgeInsets.all(10),
            child: const Opacity(
              opacity: 0.8,
              child: Center(
                child: Text("No image selected"),
              ),
            ),
          ),
        ]
      ),


      floatingActionButton: FloatingActionButton(
        onPressed: pickImage,
        tooltip: "Pick Image",
        child: const Icon(Icons.image),
      ),
    );
  }

  Future pickImage() async {
    final ImagePicker _picker = ImagePicker();

    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    File image = File(pickedFile!.path);

    // Image no display do aplicativo
    _image = image;

    // decodeImage will identify the format of the image and use the appropriate decode
    final image2 = image1.decodeImage(image.readAsBytesSync())!;

    // Image redimensionada e recortada quadrada
    final newImage = image1.copyResizeCropSquare(image2, 28);

    final newImage2 = image1.grayscale(newImage);

    // Abre o arquivo, grava a lista de bytes nele e fecha o arquivo
    image.writeAsBytesSync(image1.encodeJpg(newImage2));

    // Upload de um texto sem image
    //print(await clientService.uploadText());

    // Upload de uma imagem com texto
    await clientService.uploadImage(image);

    // Lista para os dados retornados do Django
    var lista = [];

    // Chama o servidor django
    lista.add(await clientService.getAllDados());

    _results = lista[0][0]['boby'];
  }

}
