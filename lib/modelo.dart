import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as image1;
import 'package:image_picker/image_picker.dart';
import 'package:teste/client.dart';

class modelo extends StatefulWidget {
  const modelo({Key? key}) : super(key: key);

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
          title: Text("Image Classification"),
          centerTitle: true,
        ),
        /*
      body: (imageSelect)?Center(
        child: Image.asset(_image.path),
      ),
      */

        body: ListView(
          children: [
            (imageSelect)
                ? Container(
                    margin: const EdgeInsets.all(10),
                    child: Image.file(_image, fit: BoxFit.fitWidth),
                  )
                : Container(
                    margin: const EdgeInsets.all(10),
                    child: const Opacity(
                      opacity: 0.8,
                      child: Center(
                        child: Text("Sem imagem"),
                      ),
                    ),
                  ),
            SingleChildScrollView(
              child: Column(
                children: [
                  (imageSelect)
                      ? Text(
                          _results,
                          style: const TextStyle(
                              color: Colors.black, fontSize: 20),
                        )
                      : const Text(
                          "Sem resultado",
                          style: TextStyle(color: Colors.black, fontSize: 20),
                        )
                ],
              ),
            )
          ],
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

    // decodeImage will identify the format of the image and use the appropriate decode
    final image2 = image1.decodeImage(image.readAsBytesSync())!;

    // Image redimensionada e recortada quadrada
    final newImage = image1.copyResizeCropSquare(image2, 28);

    // Abre o arquivo, grava a lista de bytes nele e fecha o arquivo
    image.writeAsBytesSync(image1.encodeJpg(newImage));

    // Upload de uma imagem com texto
    await clientService.uploadImage(image);

    // Lista para os dados retornados do Django
    var lista = [];

    // Chama o servidor django
    lista.add(await clientService.getAllDados());

    setState(() {
      imageSelect = true;
      // Image no display do aplicativo
      _image = image;
      // Resultado do modelo
      _results = lista[0][0]['boby'];
    });
  }
}
