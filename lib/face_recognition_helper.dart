import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'dart:math';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'database_helper.dart';

class FaceRecognitionHelper {
  late Interpreter _interpreter;
  int? matchedUserId;

  Future<void> testAsset() async {
    try {
      final data = await rootBundle.load('assets/mobilefacenet.tflite');
      print('✅ Asset exists. Size: ${data.lengthInBytes} bytes');
    } catch (e) {
      print('❌ Asset test failed: $e');
    }
  }

  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
      print('✅ Model loaded successfully.');
    } catch (e) {
      print('❌ Failed to load model: $e');
    }
  }

  double compareEmbeddings(List<double> e1, List<double> e2) {
    if (e1.length != e2.length) throw Exception('Embedding length mismatch');
    double dot = 0.0, norm1 = 0.0, norm2 = 0.0;
    for (int i = 0; i < e1.length; i++) {
      dot += e1[i] * e2[i];
      norm1 += e1[i] * e1[i];
      norm2 += e2[i] * e2[i];
    }
    double denom = sqrt(norm1) * sqrt(norm2);
    return denom == 0 ? 0.0 : dot / denom;
  }

  Future<Map<String, dynamic>> matchFaceWithMobile(String mobileNumber, List<double> capturedEmbedding, double threshold) async {
    final dbHelper = DatabaseHelper();
    final db = await dbHelper.database;

    final result = await db.query(
      'form_data',
      columns: ['embedding'],
      where: 'mobile = ?',
      whereArgs: [mobileNumber],
    );

    if (result.isEmpty) {
      return {'matched': false, 'similarity': 0.0};
    }

    final storedEmbeddingJson = result.first['embedding'] as String;
    final storedEmbedding = (jsonDecode(storedEmbeddingJson) as List<dynamic>)
        .map((e) => (e as num).toDouble())
        .toList();

    final similarity = compareEmbeddings(capturedEmbedding, storedEmbedding);
    print("📸 Similarity with stored embedding: $similarity");

    return {
      'matched': similarity >= threshold,
      'similarity': similarity,
    };
  }

  /// Converts image bytes to face embedding vector
  Future<List<double>> getEmbedding(Uint8List imageBytes, Face face) async {
    var input = _preprocessImage(imageBytes, face);

    var output = List.generate(1, (_) => List.filled(192, 0.0));
    _interpreter.run([input], output);

    print("Embedding (first 5 values): ${output[0].sublist(0, 5)}");
    return List<double>.from(output[0]);
  }

  /// Preprocess image: crop face, resize to 112x112, normalize pixels to [-1, 1]
  List<List<List<double>>> _preprocessImage(Uint8List imageBytes, Face face) {
    final img.Image originalImage = img.decodeImage(imageBytes)!;

    final rect = face.boundingBox;
    final int x = rect.left.toInt().clamp(0, originalImage.width - 1);
    final int y = rect.top.toInt().clamp(0, originalImage.height - 1);
    final int width = rect.width.toInt().clamp(1, originalImage.width - x);
    final int height = rect.height.toInt().clamp(1, originalImage.height - y);

    final img.Image cropped = img.copyCrop(originalImage, x: x, y: y, width: width, height: height);
    final img.Image resized = img.copyResize(cropped, width: 112, height: 112);

    return List.generate(112, (y) => List.generate(112, (x) {
      final pixel = resized.getPixel(x, y);
      final r = pixel.r.toDouble();
      final g = pixel.g.toDouble();
      final b = pixel.b.toDouble();
      return [(r - 128) / 128.0, (g - 128) / 128.0, (b - 128) / 128.0];
    }));
  }
}
