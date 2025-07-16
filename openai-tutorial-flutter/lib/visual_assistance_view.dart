import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:stream_video_flutter/stream_video_flutter.dart' as stream_video;

import 'camera_service.dart';

class VisualAssistanceView extends StatefulWidget {
  const VisualAssistanceView({
    super.key,
    required this.call,
    required this.cameraService,
    this.isFullScreen = false,
  });

  final stream_video.Call call;
  final CameraService cameraService;
  final bool isFullScreen;

  @override
  State<VisualAssistanceView> createState() => _VisualAssistanceViewState();
}

class _VisualAssistanceViewState extends State<VisualAssistanceView> {
  bool _isAnalyzing = false;
  String _lastAnalysis = '';
  StreamSubscription<Uint8List>? _imageSubscription;
  Timer? _analysisTimer;
  bool _isStreaming = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    
    // Auto-start visual assistance if in full-screen mode
    if (widget.isFullScreen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startVisualAssistance();
      });
    }
  }

  Future<void> _initializeCamera() async {
    final success = await widget.cameraService.initialize();
    if (success && mounted) {
      setState(() {});
    }
  }

  Future<void> _startVisualAssistance() async {
    if (!widget.cameraService.isInitialized) {
      _showMessage('Camera not available');
      return;
    }

    setState(() {
      _isStreaming = true;
    });

    // Start camera streaming
    await widget.cameraService.startStreaming();

    // Subscribe to image stream for real-time analysis
    _imageSubscription = widget.cameraService.imageStream?.listen((imageBytes) {
      _analyzeImage(imageBytes, 'What do you see in front of me?');
    });

    // Periodic analysis every 5 seconds with more natural queries
    _analysisTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (widget.cameraService.isStreaming) {
        widget.cameraService.captureHighQualityImage().then((imageBytes) {
          if (imageBytes != null) {
            // Use more natural, varied queries
            final queries = [
              'What do you see in front of me?',
              'What\'s around me right now?',
              'Can you describe what I\'m looking at?',
              'What\'s in my current view?',
              'Tell me what you can see'
            ];
            final randomQuery = queries[DateTime.now().millisecond % queries.length];
            _analyzeImage(imageBytes, randomQuery);
          }
        });
      }
    });

    _showMessage('Visual assistance started! I can now see and describe what\'s around you.');
  }

  Future<void> _stopVisualAssistance() async {
    _imageSubscription?.cancel();
    _analysisTimer?.cancel();
    await widget.cameraService.stopStreaming();

    setState(() {
      _isStreaming = false;
    });

    _showMessage('Visual assistance stopped');
  }

  Future<void> _analyzeImage(Uint8List imageBytes, String query) async {
    if (_isAnalyzing) return;

    setState(() {
      _isAnalyzing = true;
    });

    try {
      // Create form data for image upload
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://10.69.175.165:3000/analyze-image'),
      );

      request.fields['query'] = query;
      request.fields['callId'] = widget.call.id;
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'capture.jpg',
        ),
      );

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(responseData);
        final analysis = jsonResponse['analysis'] ?? responseData;
        final skip = jsonResponse['skip'] ?? false;
        
        if (!skip) {
          setState(() {
            _lastAnalysis = analysis;
          });

          // Speak the analysis through the call
          await _speakAnalysis(analysis);
        } else {
          print('Skipping gray/blank image analysis');
        }
      } else {
        _showMessage('Failed to analyze image');
      }
    } catch (e) {
      print('Error analyzing image: $e');
      _showMessage('Error analyzing image');
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _speakAnalysis(String analysis) async {
    try {
      // Store the current visual context for the AI to reference
      _updateAIVisualContext(analysis);
      
      print('Visual Analysis: $analysis');
      print('Lexi will now read what it sees to you!');
    } catch (e) {
      print('Error processing analysis: $e');
    }
  }

  void _updateAIVisualContext(String analysis) async {
    // Store the current visual context so the AI can reference it
    // This will be used when the user asks follow-up questions
    if (mounted) {
      // Update the AI's context with what it currently sees
      _lastAnalysis = analysis;
      
      // Send visual context to the server
      await _sendVisualContextToServer(analysis);
    }
  }

  Future<void> _sendVisualContextToServer(String analysis) async {
    try {
      // Send visual context to the server so the AI knows what it sees
      final response = await http.post(
        Uri.parse('http://10.69.175.165:3000/update-visual-context'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'callId': widget.call.id,
          'visualContext': analysis,
        }),
      );

      if (response.statusCode == 200) {
        print('Visual context updated successfully');
      } else {
        print('Failed to update visual context: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending visual context: $e');
    }
  }



  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _imageSubscription?.cancel();
    _analysisTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isFullScreen) {
      // Full-screen camera view for toggle mode
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Stack(
            children: [
              // Camera Preview (full screen)
              SizedBox.expand(
                child: widget.cameraService.isInitialized
                    ? widget.cameraService.getCameraPreview() ?? 
                      const Center(
                        child: Text(
                          'Camera not available',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(color: Colors.deepPurple),
                            SizedBox(height: 16),
                            Text(
                              'Initializing camera...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
              ),
              
              // Analysis overlay
              if (_isAnalyzing)
                Positioned(
                  top: 50,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Analyzing...',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Last analysis result overlay
              if (_lastAnalysis.isNotEmpty)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _lastAnalysis,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    // Normal view with controls
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.deepPurple,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Expanded(
                    child: Text(
                      'Visual Assistance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    _isStreaming ? Icons.visibility : Icons.visibility_off,
                    color: Colors.white,
                  ),
                ],
              ),
            ),

            // Camera Preview
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.deepPurple, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: widget.cameraService.isInitialized
                      ? widget.cameraService.getCameraPreview() ?? 
                        const Center(
                          child: Text(
                            'Camera not available',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.deepPurple),
                              SizedBox(height: 16),
                              Text(
                                'Initializing camera...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ),

            // Control Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Start/Stop Visual Assistance
                  ElevatedButton.icon(
                    onPressed: widget.cameraService.isInitialized
                        ? (_isStreaming ? _stopVisualAssistance : _startVisualAssistance)
                        : null,
                    icon: Icon(_isStreaming ? Icons.stop : Icons.play_arrow),
                    label: Text(_isStreaming ? 'Stop' : 'Start'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isStreaming ? Colors.red : Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),

                  // Capture and Analyze
                  ElevatedButton.icon(
                    onPressed: widget.cameraService.isInitialized && !_isAnalyzing
                        ? () async {
                            final imageBytes = await widget.cameraService.captureHighQualityImage();
                            if (imageBytes != null) {
                              _analyzeImage(imageBytes, 'What do you see in front of me?');
                            }
                          }
                        : null,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Analyze'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            // Analysis Status
            if (_isAnalyzing)
              Container(
                padding: const EdgeInsets.all(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Analyzing image...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),

            // Last Analysis Result
            if (_lastAnalysis.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Analysis:',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _lastAnalysis,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 