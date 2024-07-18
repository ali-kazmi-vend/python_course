import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Uint8List? imageData;
  List? output;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flower Detector using CNN'),
      ),
      body: ListView(
        children: [
          imageData == null
              ? const SizedBox.shrink()
              : Image.memory(
                  imageData!,
                  height: 200,
                ),
          const SizedBox(
            height: 50,
          ),
          output == null
              ? const SizedBox.shrink()
              : Center(child: Text('Image is of ${output![0]['label']}')),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: ElevatedButton(
              onPressed: _pickImage,
              child: const Text('Pick Image'),
            ),
          )
        ],
      ),
    );
  }

  _loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model.tflite', labels: 'assets/labels.txt');
  }

  _classifyImage(String imagePath) async {
    var _output = await Tflite.runModelOnImage(
      path: imagePath,
      numResults: 5,
      threshold: 0.5,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      output = _output;
    });
  }

  _pickImage() async {
    final ImagePicker picker = ImagePicker();
// Pick an image.
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    final imageBytes = await image?.readAsBytes();
    setState(() {
      imageData = imageBytes;
    });
    if (image != null) {
      _classifyImage(image.path);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadModel();
  }
}
