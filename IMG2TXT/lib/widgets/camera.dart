// camera_utils.dart
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraUtils {
  late CameraController _cameraController;

  Future<void> initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    // Use the camera controller to start the camera preview
    // You can customize the resolution and other parameters here
    _cameraController = CameraController(firstCamera, ResolutionPreset.medium);
    await _cameraController.initialize();
  }

  Widget buildCameraPreview() {
    return _cameraController.value.isInitialized
        ? CameraPreview(_cameraController)
        : const CircularProgressIndicator();
  }

  void disposeCamera() {
    _cameraController.dispose();
  }
}
