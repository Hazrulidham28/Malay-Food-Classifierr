import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Tflite extends ChangeNotifier {
  //late final WebViewController controller;
  var loadingPercentage = 0;
  File? img;
  String? predLabel;
  List result = [];
  bool isLoading = false;
  XFile? imagePicked;
  List<String> allLabel = [];
  Interpreter? interpreterInstance;

  Tflite() {
    loadAsset();
  }

  void loadAsset() async {
    String loadedString = await rootBundle.loadString('assets/labels.txt');
    allLabel = loadedString.split('\n');
    notifyListeners();
  }

  Future<Interpreter> get _interpreter async {
    if (interpreterInstance == null) {
      interpreterInstance = await Interpreter.fromAsset(
        'assets/5classmodelLatest.tflite',
      );
      notifyListeners();
    }
    return interpreterInstance!;
  }

  Future predict(imglib.Image img) async {
    isLoading = true;
    notifyListeners();

    final imageInput = imglib.copyResize(img, width: 180, height: 180);

    final imageMatrix = List.generate(
      imageInput.height,
      (y) => List.generate(
        imageInput.width,
        (x) {
          final pixel = imageInput.getPixel(x, y);
          return [pixel.r, pixel.g, pixel.b];
        },
      ),
    );

    result = await _runInference(imageMatrix);
    predLabel = getLabel(result.cast<num>());

    isLoading = false;
    notifyListeners();
  }

  Future<List<num>> _runInference(
    List<List<List<num>>> imageMatrix,
  ) async {
    final interpreter = await _interpreter;
    final input = [imageMatrix];
    final output = List.filled(1 * allLabel.length, 0.0).reshape(
      [1, allLabel.length],
    );

    interpreter.run(input, output);
    notifyListeners();
    return output.first;
  }

  String getLabel(List<num>? diagnoseScores) {
    int bestInd = 0;
    num maxScore = -1;

    diagnoseScores?.asMap().forEach((i, score) {
      if (score > maxScore) {
        maxScore = score;
        bestInd = i;
      }
    });

    return allLabel[bestInd];
  }

  Future getImage(ImageSource source) async {
    imagePicked = await ImagePicker().pickImage(source: source);
    if (imagePicked != null) {
      img = File(imagePicked!.path);
      notifyListeners();
      await predict(imglib.decodeImage(File(img!.path).readAsBytesSync())!);
    }
  }

  Future btnAction(ImageSource source) async {
    await getImage(source);
    notifyListeners();
  }
}
