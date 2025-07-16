import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class CameraService extends ChangeNotifier {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isStreaming = false;
  Timer? _captureTimer;
  
  // Stream for real-time image processing
  StreamController<Uint8List>? _imageStreamController;
  Stream<Uint8List>? _imageStream;

  CameraController? get controller => _controller;
  bool get isInitialized => _isInitialized;
  bool get isStreaming => _isStreaming;
  Stream<Uint8List>? get imageStream => _imageStream;

  /// Initialize camera service
  Future<bool> initialize() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (status != PermissionStatus.granted) {
        print('Camera permission denied');
        return false;
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        print('No cameras available');
        return false;
      }

      // Initialize with back camera (usually better quality)
      final backCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras!.first,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.medium, // Balance between quality and performance
        enableAudio: false, // We don't need audio for visual assistance
        imageFormatGroup: Platform.isAndroid 
            ? ImageFormatGroup.yuv420 
            : ImageFormatGroup.bgra8888,
      );

      await _controller!.initialize();
      _isInitialized = true;
      notifyListeners();
      
      print('Camera initialized successfully');
      return true;
    } catch (e) {
      print('Failed to initialize camera: $e');
      return false;
    }
  }

  /// Start real-time image streaming
  Future<void> startStreaming() async {
    if (!_isInitialized || _controller == null) {
      print('Camera not initialized');
      return;
    }

    if (_isStreaming) {
      print('Already streaming');
      return;
    }

    try {
      _imageStreamController = StreamController<Uint8List>.broadcast();
      _imageStream = _imageStreamController!.stream;
      _isStreaming = true;

      // Start periodic image capture
      _captureTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
        _captureAndProcessImage();
      });

      notifyListeners();
      print('Started camera streaming');
    } catch (e) {
      print('Failed to start streaming: $e');
    }
  }

  /// Stop real-time image streaming
  Future<void> stopStreaming() async {
    if (!_isStreaming) return;

    _captureTimer?.cancel();
    _captureTimer = null;
    _imageStreamController?.close();
    _imageStreamController = null;
    _imageStream = null;
    _isStreaming = false;
    
    notifyListeners();
    print('Stopped camera streaming');
  }

  /// Capture and process a single image
  Future<Uint8List?> _captureAndProcessImage() async {
    if (!_isInitialized || _controller == null) return null;

    try {
      final image = await _controller!.takePicture();
      final bytes = await File(image.path).readAsBytes();
      
      // Process image for better analysis
      final processedBytes = await _processImage(bytes);
      
      // Send to stream
      _imageStreamController?.add(processedBytes);
      
      return processedBytes;
    } catch (e) {
      print('Failed to capture image: $e');
      return null;
    }
  }

  /// Process image for better AI analysis
  Future<Uint8List> _processImage(Uint8List imageBytes) async {
    try {
      // Decode image
      final image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Resize for better performance (maintain aspect ratio)
      final resized = img.copyResize(
        image,
        width: 640, // Good balance for AI analysis
        height: (640 * image.height / image.width).round(),
      );

      // Enhance contrast for better text recognition
      final enhanced = img.contrast(resized, contrast: 1.2);

      // Convert back to bytes
      return Uint8List.fromList(img.encodeJpg(enhanced, quality: 85));
    } catch (e) {
      print('Failed to process image: $e');
      return imageBytes;
    }
  }

  /// Capture a single high-quality image for detailed analysis
  Future<Uint8List?> captureHighQualityImage() async {
    if (!_isInitialized || _controller == null) return null;

    try {
      // Temporarily stop streaming if active
      final wasStreaming = _isStreaming;
      if (wasStreaming) {
        await stopStreaming();
      }

      // Take high-quality image
      final image = await _controller!.takePicture();
      final bytes = await File(image.path).readAsBytes();

      // Restart streaming if it was active
      if (wasStreaming) {
        await startStreaming();
      }

      return bytes;
    } catch (e) {
      print('Failed to capture high-quality image: $e');
      return null;
    }
  }

  /// Get camera preview widget
  Widget? getCameraPreview() {
    if (!_isInitialized || _controller == null) return null;
    
    return CameraPreview(_controller!);
  }

  /// Dispose resources
  @override
  void dispose() {
    stopStreaming();
    _controller?.dispose();
    super.dispose();
  }
} 