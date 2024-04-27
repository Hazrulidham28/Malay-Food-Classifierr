import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'provider/tflite.dart';

void main() {
  runApp(ChangeNotifierProvider(create: (context) => Tflite(), child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Malay Food Classifier'),
        ),
        body: Consumer<Tflite>(
          builder: (context, tflite, child) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () => tflite.btnAction(ImageSource.gallery),
                  child: Text('Pick Image from Gallery'),
                ),
                ElevatedButton(
                  onPressed: () => tflite.btnAction(ImageSource.camera),
                  child: Text('Capture Image from Camera'),
                ),
                if (tflite.img != null)
                  Container(
                    width: 250,
                    height: 250,
                    child: Image.file(tflite.img!),
                  ),
                if (tflite.predLabel != null)
                  Text('Prediction: ${tflite.predLabel}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
