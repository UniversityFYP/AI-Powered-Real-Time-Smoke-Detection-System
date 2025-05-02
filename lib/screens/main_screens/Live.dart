import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

class LiveDetectionPage extends StatefulWidget {
  final String IpAdress;
  final String PortNo;

  const LiveDetectionPage({super.key,
    required this.IpAdress,
    required this.PortNo,});

  @override
  State<LiveDetectionPage> createState() => _LiveDetectionPageState();
}

class _LiveDetectionPageState extends State<LiveDetectionPage> {
  late CameraController Controller;
  late WebSocketChannel Channal;
  bool Is_Streaming = false;
  bool Is_Connected = false;
  List<dynamic> Detections = [];

  bool Show_Bounding_Boxes = false;
  int Frame_Count = 0;
  DateTime? Last_Frame_Time;
  double Current_Fps = 0;
  bool Use_Image_Stream = true; // Toggle between image stream and takePicture

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    Init_WebSocket();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras(); // Fetch cameras here
    Controller = CameraController(
      cameras.first, // Use the first camera
      ResolutionPreset.medium,
    );
    await Controller.initialize();
    if (mounted) setState(() {});
  }

  void Init_WebSocket() {
    final String ip= widget.IpAdress;
    final String port= widget.PortNo;
    Channal = IOWebSocketChannel.connect('ws://$ip:$port/ws-video-stream');
    Channal.stream.listen(
          (data) {
        if (!mounted) return;
        try {
          final parsedData = json.decode(data);
          if (parsedData is Map<String, dynamic>) {
            setState(() {
              Detections = parsedData['detections'] ?? [];
              Is_Connected = true;
            });
          } else {
            print('Received unexpected data format: $parsedData');
          }
        } catch (e) {
          print('Error parsing WebSocket data: $e');
          print('Raw data received: $data');
        }
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          Is_Connected = false;
          Is_Streaming = false;
          Show_Bounding_Boxes = false;
        });
        print('WebSocket error: $error');
      },
      onDone: () {
        if (!mounted) return;
        setState(() {
          Is_Connected = false;
          Is_Streaming = false;
          Show_Bounding_Boxes = false;
        });
        print('WebSocket connection closed');
      },
    );
  }

  Future<void> Toggle_Streaming() async {
    if (Is_Streaming) {
      await Stop_Streaming();
      return;
    }

    await Start_Streaming();
  }

  Future<void> Start_Streaming() async {
    setState(() {
      Is_Streaming = true;
      Show_Bounding_Boxes = true;
      Frame_Count = 0;
      Current_Fps = 0;
      Last_Frame_Time = DateTime.now();
    });

    if (Use_Image_Stream) {
      await Controller.startImageStream((CameraImage image) async {
        if (!Is_Streaming || !mounted) return;
        Process_Frame(image);
      });
    } else {
      // Fallback to takePicture if image stream not available
      while (Is_Streaming && mounted) {
        if (!Controller.value.isInitialized) {
          await Future.delayed(const Duration(milliseconds: 100));
          continue;
        }
        try {
          final image = await Controller.takePicture();
          final bytes = await File(image.path).readAsBytes();
          Channal.sink.add(bytes);
          await File(image.path).delete();
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e) {
          print('Error capturing/sending frame: $e');
          if (mounted) await Stop_Streaming();
          break;
        }
      }
    }
  }

  Future<void> Stop_Streaming() async {
    if (Use_Image_Stream && Controller.value.isStreamingImages) {
      await Controller.stopImageStream();
    }
    setState(() {
      Is_Streaming = false;
      Show_Bounding_Boxes = false;
    });
  }

  Future<void> Process_Frame(CameraImage image) async {
    if (!Is_Streaming || !mounted) return;

    final now = DateTime.now();
    Frame_Count++;

    // Calculate FPS every 10 frames
    if (Frame_Count % 10 == 0) {
      final elapsed = now.difference(Last_Frame_Time!).inMilliseconds / 1000;
      Current_Fps = 10 / elapsed;
      Last_Frame_Time = now;
      if (mounted) setState(() {});
    }

    try {
      final jpeg = await Convert_Camera_Image_To_Jpeg(image);
      Channal.sink.add(jpeg);
    } catch (e) {
      print('Error processing frame: $e');
      if (mounted) await Stop_Streaming();
    }
  }

  Future<Uint8List> Convert_Camera_Image_To_Jpeg(CameraImage image) async {
    // Simplified conversion - consider using a proper image processing package
    // For production, use something like 'camera: ^0.10.0+1' with proper conversion
    final tmpDir = await getTemporaryDirectory();
    final tmpFile = File('${tmpDir.path}/frame_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tmpFile.writeAsBytes(image.planes[0].bytes);
    final bytes = await tmpFile.readAsBytes();
    await tmpFile.delete();
    return bytes;
  }

  @override
  void dispose() {
    Stop_Streaming();
    Controller.dispose();
    Channal.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detection (${Current_Fps.toStringAsFixed(1)} FPS)'),
        actions: [
          Icon(
            Is_Connected ? Icons.cloud_done : Icons.cloud_off,
            color: Is_Connected ? Colors.green : Colors.red,
          ),
          IconButton(
            icon: Icon(Use_Image_Stream ? Icons.videocam : Icons.camera_alt),
            onPressed: () {
              setState(() {
                Use_Image_Stream = !Use_Image_Stream;
              });
              if (Is_Streaming) {
                Stop_Streaming().then((_) => Start_Streaming());
              }
            },
            tooltip: Use_Image_Stream ? 'Using Video Stream' : 'Using Single Frames',
          ),
        ],
      ),
      body: Stack(
        children: [
          if (Controller.value.isInitialized)
            CameraPreview(Controller),
          if (Show_Bounding_Boxes)
            ...Build_Detection_Boxes(),
          if (!Controller.value.isInitialized)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: Toggle_Streaming,
        backgroundColor: Is_Streaming ? Colors.red : Colors.green,
        child: Icon(
          Is_Streaming ? Icons.stop : Icons.play_arrow,
          color: Colors.white,
        ),
      ),
    );
  }

  List<Widget> Build_Detection_Boxes() {
    if (!Controller.value.isInitialized || Detections.isEmpty) {
      return [];
    }

    final previewSize = Controller.value.previewSize!;
    final screenSize = MediaQuery.of(context).size;

    // Calculate scaling factors
    final scaleX = screenSize.width / previewSize.height;
    final scaleY = screenSize.height / previewSize.width;

    // Check if coordinates are normalized (0-1)
    final isNormalized = Detections.any((d) {
      final bbox = d['bbox'] is List ? List<double>.from(d['bbox']) : [];
      return bbox.length == 4 && bbox.every((v) => v >= 0 && v <= 1);
    });

    return Detections.map<Widget>((detection) {
      try {
        List<double> bbox = detection['bbox'] is List
            ? List<double>.from(detection['bbox'])
            : [0, 0, 0, 0];

        // Convert normalized coordinates if needed
        if (isNormalized) {
          bbox = [
            bbox[0] * previewSize.width,
            bbox[1] * previewSize.height,
            bbox[2] * previewSize.width,
            bbox[3] * previewSize.height,
          ];
        }

        // Adjust for camera rotation (swap x/y if needed)
        final left = bbox[1] * scaleX;
        final top = bbox[0] * scaleY;
        final width = (bbox[3] - bbox[1]) * scaleX;
        final height = (bbox[2] - bbox[0]) * scaleY;

        return Positioned(
          left: left,
          top: top,
          width: width,
          height: height,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.green,
                width: 2,
              ),
            ),
            child: Text(
              '${detection['class_name'] ?? 'object'} ${((detection['confidence'] ?? 0) * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                backgroundColor: Colors.black54,
                fontSize: 12,
              ),
            ),
          ),
        );
      } catch (e) {
        print('Error rendering detection box: $e');
        return Container();
      }
    }).toList();
  }
}