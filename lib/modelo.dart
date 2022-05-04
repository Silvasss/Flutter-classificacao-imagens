import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';


class modelo extends StatefulWidget {
  const modelo({Key? key}) : super(key : key);

  @override
  _modeloState createState() => _modeloState();
}

class _modeloState extends State<modelo> {

  late File _image;
  late List _results;
  bool imageSelect = false;

  @override
  void initState() {
    super.initState();

    loadModel();
  }

  // Carrega o modelo
  Future loadModel() async {
    Tflite.close();

    String resp;

    // Carregar o modelo e a label
    //resp = (await Tflite.loadModel(model: 'assets/model/model.tflite', labels: "assets/model/labels2.txt", numThreads: 6))!;
    resp = (await Tflite.loadModel(model: 'assets/model/tflite_model.tflite', labels: "assets/model/labels3.txt", numThreads: 6))!;
    /*
    numThreads: 1, // defaults to 1
    isAsset: true, // defaults to true, set to false to load resources outside assets
    useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    */

    print('Estado de carregamento do modelo: $resp');
  }

  Future imageClassification(File image) async {

    // "?" indicar que uma variável pode ter o valor null
    final List? recognitions = await Tflite.runModelOnImage(
        path: image.path,
        // Valor médio de pixel do conjunto de dados da imagem
        imageMean: 127.0,   // defaults to 117.0
        // Desvio padrão
        imageStd: 127.5,  // defaults to 1.0
        numResults: 2,    // defaults to 5
        // Valor limite de classificação
        threshold: 0.05,   // defaults to 0.1
        asynch: true      // defaults to true
    );
    setState(() {
      // "!" Converte uma expressão em seu tipo não anulável subjacente, lançando uma exceção de tempo de execução se a conversão falhar
      _results = recognitions!;

      _image = image;

      imageSelect = true;
    });
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
          SingleChildScrollView(
            child: Column(
              children: (imageSelect)?_results.map((result) {
                return Card(
                  child: Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      "${result['label']} - ${result['confidence'].toStringAsFixed(2)}",
                      style: const TextStyle(color: Colors.red,
                          fontSize: 20),
                    ),
                  ),
                );
              }).toList():[],

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

    imageClassification(image);
  }

}
