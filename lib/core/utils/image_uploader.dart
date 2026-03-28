import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';

class QuickImageUploader {
  static Future<void> uploadInitialImages() async {
    print('Starting image upload to Firebase Storage...');
    try {
      final storage = FirebaseStorage.instanceFor(bucket: 'gs://hybrid-order-system.firebasestorage.app');

      // Ramen
      await _uploadAsset(storage, 'assets/images/ramen.png', 'images/ramen.png');
      
      // Gyoza
      await _uploadAsset(storage, 'assets/images/gyoza.png', 'images/gyoza.png');

      print('All images uploaded successfully!');
    } catch (e) {
      print('Error during QuickImageUploader: $e');
    }
  }

  static Future<void> _uploadAsset(FirebaseStorage storage, String assetPath, String storagePath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      
      final ref = storage.ref().child(storagePath);
      await ref.putData(bytes, SettableMetadata(contentType: 'image/png'));
      final url = await ref.getDownloadURL();
      print('Uploaded $assetPath to $url');
    } catch (e) {
      print('Failed to upload $assetPath: $e');
    }
  }
}
