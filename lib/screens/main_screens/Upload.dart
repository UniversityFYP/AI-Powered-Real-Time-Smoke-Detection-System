import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:ui' as ui;
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import '../controller/VideoBoundingBoxController.dart';
import '../controller/ImageBoundingBoxController.dart';

class UploadPage extends StatefulWidget {
    final String IpAdress;
    final String PortNo;
  const UploadPage({super.key,
    required this.IpAdress,
    required this.PortNo,
  });

  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  final ImagePicker Image_Picker = ImagePicker();
  File? Selected_File;
  VideoPlayerController? Video_Controller;
  List<File> Gallery_Images = [];
  bool Is_Detecting = false;
  int Selected_Gallery_Index = -1;
  List<Map<String, dynamic>> Detections = [];
  ui.Image? Image_To_Draw;
  bool Is_Video_Detection_Running = false;
  Timer? Video_Detection_Timer;
  List<Map<String, dynamic>> Video_Detections = [];

  List<String> cloudinaryImageUrls = [];
  bool isLoadingGallery = false;

  double? Video_Fps;
  double? Video_Duration;
  int? Total_Frames;
//cloudinary for image storage
  final cloudinary = Cloudinary.signedConfig(
    apiKey: '925557794339816',
    apiSecret: 'kKC-cMpW1pQbwj1pciptmEGAol0',
    cloudName: 'dopwmj4xc',
  );
//Firebase Firstore for database
  late FirebaseFirestore firestore;
  bool isUploading = false;
  int vehicleCounter = 1;


  //initialize the images at start and database
  @override
  void initState() {
    super.initState();
    _initializeFirebase();
    _fetchFirestoreImages();
  }

  //initialization of Firebase
  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp();
    firestore = FirebaseFirestore.instance;
  }

  //initialization of images link available in databases
  Future<void> _fetchFirestoreImages() async {
    setState(() => isLoadingGallery = true);
    try {
      final querySnapshot = await firestore.collection('detections').get();
      setState(() {
        cloudinaryImageUrls = querySnapshot.docs
            .map((doc) => doc['imageUrl'] as String)
            .where((url) => url.isNotEmpty)
            .toList();
      });
    } catch (e) {
      print('Error fetching Firestore images: $e');
    } finally {
      setState(() => isLoadingGallery = false);
    }
  }


  @override
  void dispose() {
    Video_Controller?.dispose();
    Video_Detection_Timer?.cancel();
    super.dispose();
  }

  Future<void> Load_Image(File file) async {
    final data = await file.readAsBytes();
    final codec = await ui.instantiateImageCodec(data);
    final frame = await codec.getNextFrame();
    setState(() {
      Image_To_Draw = frame.image;
    });
  }

  Future<File> Resize_Image_If_Needed(File imageFile) async {
    // Decode the image
    final image = img.decodeImage(await imageFile.readAsBytes());
    if (image == null) return imageFile;

    // Check if resizing is needed
    if (image.width <= 640 && image.height <= 640) {
      return imageFile; // No resizing needed
    }

    // Calculate new dimensions while maintaining aspect ratio
    int newWidth, newHeight;
    if (image.width > image.height) {
      newWidth = 640;
      newHeight = (image.height * (640 / image.width)).round();
    } else {
      newHeight = 640;
      newWidth = (image.width * (640 / image.height)).round();
    }

    // Resize the image
    final resizedImage = img.copyResize(image, width: newWidth, height: newHeight);

    // Save to temporary file
    final directory = await getTemporaryDirectory();
    final resizedFile = File('${directory.path}/resized_${imageFile.path.split('/').last}');
    await resizedFile.writeAsBytes(img.encodePng(resizedImage));

    return resizedFile;
  }


  Future<void> Image_Picker_For_Detection() async {
    final XFile? image = await Image_Picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      if (Video_Controller != null) {
        await Video_Controller!.dispose();
        Video_Controller = null;
      }

      Reset_Detection_State();
      final originalFile = File(image.path);
      final resizedFile = await Resize_Image_If_Needed(originalFile);

      setState(() {
        Selected_File = resizedFile;
        Load_Image(Selected_File!);
      });
    }
  }


  Future<File> _resizeVideoIfNeeded(File videoFile) async {
    // This is a placeholder - you'll need to implement actual video resizing
    // For a real implementation, you'd use something like flutter_ffmpeg

    // For now, we'll just return the original file
    return videoFile;
  }



  Future<void> Video_Picker_For_Detection() async {
    final XFile? video = await Image_Picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      Reset_Detection_State();
      final originalFile = File(video.path);
      final resizedFile = await _resizeVideoIfNeeded(originalFile);

      Video_Controller = VideoPlayerController.file(resizedFile)
        ..initialize().then((_) {
          setState(() {
            Selected_File = resizedFile;
            Video_Controller!.setPlaybackSpeed(0.7);
            Video_Controller!.seekTo(Duration.zero);
          });
        });
    }
  }



  Future<void> Capture_Image_For_Detection() async {
    final XFile? image = await Image_Picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      Reset_Detection_State();
      final originalFile = File(image.path);
      final resizedFile = await Resize_Image_If_Needed(originalFile);

      setState(() {
        Selected_File = resizedFile;
        Load_Image(Selected_File!);
      });
    }
  }

//Reset Detection method
  void Reset_Detection_State() {
    Video_Controller?.pause();
    Video_Detection_Timer?.cancel();
    setState(() {
      Detections = [];
      Video_Detections = [];
      Is_Video_Detection_Running = false;
    });
  }



  Future<void> Detect_Smoke() async {
    if (Selected_File == null) return;

    setState(() {
      Is_Detecting = true;
      Detections = [];
      Video_Detections = [];
    });

    try {
      if (Video_Controller != null && Video_Controller!.value.isInitialized) {
        await Detect_In_Video();
      } else {
        await Detect_In_Image();
      }

      // After detection, show popup with smoke type details
      if (Detections.isNotEmpty) {
        final smokeType = Detections.firstWhere(
              (d) => d['class_name'].toString().toLowerCase().contains('smoke'),
          orElse: () => {'class_name': 'unknown'},
        )['class_name'];

        if (smokeType != 'unknown') {
          await Show_Smoke_TypeDialog(smokeType);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => Is_Detecting = false);
    }
  }

// Helper method to show the smoke type dialog
  Future<void> Show_Smoke_TypeDialog(String smokeType) async {
    // Define smoke details with explicit types
    final Map<String, Map<String, dynamic>> smokeDetails = {
      'black smoke': {
        'title': 'Black Smoke',
        'icon': Icons.warning_amber_rounded,
        'color': Colors.orange,
        'description': 'Indicates incomplete combustion, possibly due to:',
        'causes': <String>[
          '• Clogged air filters',
          '• Faulty fuel injectors',
          '• Excessive fuel in combustion chamber',
          '• Poor quality fuel'
        ],
      },
      'white smoke': {
        'title': 'White Smoke',
        'icon': Icons.water_drop_rounded,
        'color': Colors.blue,
        'description': 'Often caused by coolant/water entering combustion:',
        'causes': <String>[
          '• Blown head gasket',
          '• Cracked engine block',
          '• Faulty cylinder head',
          '• Cold weather condensation'
        ],
      },
      'blue smoke': {
        'title': 'Blue Smoke',
        'icon': Icons.oil_barrel,
        'color': Colors.indigo,
        'description': 'Sign of oil burning in combustion chamber:',
        'causes': <String>[
          '• Worn piston rings',
          '• Faulty valve seals',
          '• Turbocharger issues',
          '• Overfilled engine oil'
        ],
      },
      'gray smoke': {
        'title': 'Gray Smoke',
        'icon': Icons.gradient_rounded,
        'color': Colors.grey,
        'description': 'May suggest transmission fluid burning:',
        'causes': <String>[
          '• Transmission fluid leakage',
          '• Faulty PCV valve',
          '• Turbocharger problems',
          '• Incorrect fuel mixture'
        ],
      },
    };

    final details = smokeDetails[smokeType.toLowerCase()];
    if (details == null) return;

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 8,
        backgroundColor: Colors.transparent, // Transparent to let Card shine
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (details['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          details['icon'] as IconData,
                          color: details['color'] as Color,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          details['title'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: "Archivo",
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    details['description'] as String,
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "Inter",
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: (details['causes'] as List<String>)
                        .map((cause) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '• ',
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "Inter",
                              color: Colors.grey[800],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              cause.substring(2), // Remove "• " prefix
                              style: TextStyle(
                                fontSize: 15,
                                fontFamily: "Inter",
                                color: Colors.grey[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6E75EC),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: "Archivo",
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }









//Smoke Detection in images
  Future<void> Detect_In_Image() async {
    final String ip= widget.IpAdress;
    final String port= widget.PortNo;
    final uri = Uri.parse('http://$ip:$port/predict-image');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', Selected_File!.path),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      setState(() {
        Detections = List<Map<String, dynamic>>.from(json.decode(result)['predictions']);
      });
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }


//Smoke Detection in Videos
  Future<void> Detect_In_Video() async {

    final String ip= widget.IpAdress;
    final String port= widget.PortNo;
    if (Video_Controller == null) return;

    // Ensure video is paused before detection starts
    if (Video_Controller!.value.isPlaying) {
      await Video_Controller!.pause();
    }

    final uri = Uri.parse('http://$ip:$port/predict-video');
    var request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', Selected_File!.path),
    );

    final response = await request.send();
    if (response.statusCode == 200) {
      final result = await response.stream.bytesToString();
      final parsedResult = json.decode(result);

      setState(() {
        Video_Detections = List<Map<String, dynamic>>.from(parsedResult['video_predictions']);
        Video_Fps = parsedResult['fps']?.toDouble();
        Video_Duration = parsedResult['duration']?.toDouble();
        Total_Frames = parsedResult['total_frames']?.toInt();
        Is_Video_Detection_Running = true;
      });

      // Start playing video only after detection completes
      if (mounted) {
        await Video_Controller!.play();
        Process_Video_Detections();
      }
    } else {
      throw Exception('API Error: ${response.statusCode}');
    }
  }

  //Video Processing Method
  void Process_Video_Detections() {
    if (Video_Controller == null || !Video_Controller!.value.isInitialized) return;

    Video_Detection_Timer?.cancel();

    // Use actual video FPS if available, otherwise estimate
    final fps = Video_Fps ?? (Video_Controller!.value.size.height > 0
        ? Video_Controller!.value.size.height / 1000
        : 30);

    final frameInterval = (1000 / fps).round(); // ms per frame

    Video_Detection_Timer = Timer.periodic(Duration(milliseconds: frameInterval), (timer) {
      if (!Video_Controller!.value.isPlaying || !mounted) {
        timer.cancel();
        return;
      }

      final currentPosition = Video_Controller!.value.position;
      final currentTime = currentPosition.inMilliseconds / 1000; // in seconds

      // Find detections closest to current timestamp
      Map<String, dynamic>? closestFrame;
      double minTimeDiff = double.infinity;

      for (final frame in Video_Detections) {
        if (frame != null && frame['timestamp'] != null) {
          final timeDiff = (frame['timestamp'] - currentTime).abs();
          if (timeDiff < minTimeDiff) {
            minTimeDiff = timeDiff;
            closestFrame = frame;
          }
        }
      }

      if (closestFrame != null && closestFrame['detections'] != null) {
        setState(() {
          Detections = List<Map<String, dynamic>>.from(closestFrame!['detections']);
        });
      }
    });
  }

  //Save Detection Result
  Future<void> Save_Detection_Result() async {
    try {
      if (Video_Controller != null && Video_Controller!.value.isInitialized) {
        final frame = await Save_Video_Frame_With_Detection();
        if (frame != null) {
          await _processAndSaveDetection(frame);
        }
      } else if (Selected_File != null && Detections.isNotEmpty) {
        await _processAndSaveDetection(Selected_File!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Save failed: $e')),
      );
    }
  }

  //for detecting location

  Future<Map<String, dynamic>?> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get placemarks from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      String locationName = 'Unknown Location';
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        locationName = [
          place.locality,
          place.administrativeArea,
          place.country
        ].where((part) => part?.isNotEmpty ?? false).join(', ');
      }

      return {
        'coordinates': GeoPoint(position.latitude, position.longitude),
        'name': locationName,
      };
    } catch (e) {
      print('Location error: $e');
      return null;
    }
  }


  //for storing data in Firebase

  Future<void> _saveToFirestore({
    required String imageUrl,
    String? numberPlate,
    required String smokeType,
  }) async {
    try {
      final locationData = await _getCurrentLocation();
      final now = DateTime.now();

      final detectionData = {
        'creationDate': formatDate(now, [yyyy, '-', mm, '-', dd]),
        'time': formatDate(now, [HH, ':', nn, ':', ss]),
        'timestamp': FieldValue.serverTimestamp(),
        'imageUrl': imageUrl,
        'numberPlate': numberPlate ?? 'vehicle${vehicleCounter++}',
        'smokeType': smokeType,
        'location': locationData?['name'] ?? 'Unknown Location',
        'coordinates': locationData?['coordinates'],
      };

      await firestore.collection('detections').add(detectionData);
    } catch (e) {
      print('Firestore save error: $e');
      throw e;
    }
  }


  //Process and save Detection
  Future<void> _processAndSaveDetection(File file) async {
    setState(() => isUploading = true);

    try {
      // First check smoke type
      final smokeType = Detections.isNotEmpty
          ? Detections.firstWhere(
            (d) => d['class_name'].toString().toLowerCase().contains('smoke'),
        orElse: () => {'class_name': 'unknown'},
      )['class_name']
          : 'unknown';

      // Don't proceed if smoke type is unknown
      if (smokeType == 'unknown') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No smoke detected - data not saved')),
        );
        return;
      }

      // Upload image to Cloudinary
      final imageUrl = await _uploadDetectedImageToCloudinary();
      if (imageUrl == null) {
        throw Exception('Failed to upload image to Cloudinary');
      }

      // Find the best number plate detection (highest confidence)
      String? plateText;
      for (var detection in Detections) {
        if (detection['model_type'] == 'plate_detection' && detection['plate_text'] != null) {
          if (plateText == null || detection['confidence'] > (Detections.firstWhere(
                (d) => d['plate_text'] == plateText,
            orElse: () => {'confidence': 0},
          )['confidence'])) {
            plateText = detection['plate_text'];
          }
        }
      }

      await _saveToFirestore(
        imageUrl: imageUrl,
        numberPlate: plateText,
        smokeType: smokeType.toString(),
      );

      // Refresh Cloudinary images after saving
      await _fetchFirestoreImages();

      setState(() {
        Gallery_Images.add(file);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Detection saved successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving detection: $e')),
      );
    } finally {
      setState(() => isUploading = false);
    }
  }

  //Uploading detected image in cloudinary
  Future<String?> _uploadDetectedImageToCloudinary() async {
    try {
      if (Selected_File == null) return null;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final image = await Selected_File!.readAsBytes();
      final codec = await ui.instantiateImageCodec(image);
      final frame = await codec.getNextFrame();

      canvas.drawImageRect(
        frame.image,
        Rect.fromLTRB(0, 0, frame.image.width.toDouble(), frame.image.height.toDouble()),
        Rect.fromLTRB(0, 0, frame.image.width.toDouble(), frame.image.height.toDouble()),
        Paint(),
      );

      if (Detections.isNotEmpty) {
        Draw_Detections(canvas, frame.image, Detections);
      }

      final picture = recorder.endRecording();
      final img = await picture.toImage(frame.image.width, frame.image.height);
      final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/detected_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(bytes);

      final response = await cloudinary.upload(
        file: tempFile.path,
        fileBytes: bytes,
        resourceType: CloudinaryResourceType.image,
        folder: "detections",
        fileName: 'detection_${DateTime.now().millisecondsSinceEpoch}',
      );

      return response.secureUrl;
    } catch (e) {
      print('Cloudinary upload error: $e');
      return null;
    }
  }

  Future<void> Save_Image_With_Detection() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final image = await Selected_File!.readAsBytes();
    final codec = await ui.instantiateImageCodec(image);
    final frame = await codec.getNextFrame();

    canvas.drawImageRect(
      frame.image,
      Rect.fromLTRB(0, 0, frame.image.width.toDouble(), frame.image.height.toDouble()),
      Rect.fromLTRB(0, 0, frame.image.width.toDouble(), frame.image.height.toDouble()),
      Paint(),
    );

    Draw_Detections(canvas, frame.image, Detections);

    final picture = recorder.endRecording();
    final img = await picture.toImage(frame.image.width, frame.image.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/detection_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());

    setState(() => Gallery_Images.add(file));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Detection saved to gallery')),
    );
  }


  Future<File?> Save_Video_Frame_With_Detection() async {
    if (Video_Controller == null || !Video_Controller!.value.isInitialized) {
      return null;
    }

    await Video_Controller!.pause();

    final currentPosition = Video_Controller!.value.position;
    final fps = Video_Controller!.value.size.height > 0
        ? Video_Controller!.value.size.height / 1000
        : 30;
    final currentFrame = (currentPosition.inMilliseconds * fps / 1000).round();
    final frameDetections = Video_Detections.firstWhere(
          (item) => item['frame'] == currentFrame,
      orElse: () => {'detections': []},
    )['detections'];

    final image = await Create_Video_Screenshot();
    if (image == null) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawImage(image, Offset.zero, Paint());
    Draw_Detections(canvas, image, frameDetections);

    final picture = recorder.endRecording();
    final img = await picture.toImage(image.width, image.height);
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/video_frame_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(byteData!.buffer.asUint8List());

    setState(() => Gallery_Images.add(file));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Video frame saved to gallery')),
    );

    await Video_Controller!.play();
    return file;
  }


  Future<ui.Image?> Create_Video_Screenshot() async {
    if (Video_Controller == null || !Video_Controller!.value.isInitialized) return null;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();

    final width = Video_Controller!.value.size.width.toInt();
    final height = Video_Controller!.value.size.height.toInt();

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);

    return img;
  }


  void Draw_Detections(Canvas canvas, ui.Image image, List<dynamic> detections) {
    final scaleX = image.width.toDouble();
    final scaleY = image.height.toDouble();

    for (final detection in detections) {
      final bbox = detection['bbox'];
      final rect = Rect.fromLTRB(
        bbox[0].toDouble(),
        bbox[1].toDouble(),
        bbox[2].toDouble(),
        bbox[3].toDouble(),
      );

      final boxPaint = Colors_For_Class_Labels(detection['class_name']);
      canvas.drawRect(rect, boxPaint);

      final textSpan = TextSpan(
        text: '${detection['class_name']} ${(detection['confidence'] * 100).toStringAsFixed(1)}%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          backgroundColor: Colors.black54,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(rect.left, rect.top - textPainter.height),
      );
    }
  }

  Paint Colors_For_Class_Labels(String className) {
    Color color;
    switch (className.toLowerCase()) {
      case "black smoke": color = Colors.black; break;
      case "white smoke": color = Colors.white; break;
      case "gray smoke": color = Colors.grey; break;
      case "vehicle": color = Colors.red; break;
      case "blue smoke": color = Colors.blue; break;
      case "car": color = Colors.yellow; break;
      case "bus": color = Colors.pinkAccent; break;
      case "human": color = Colors.brown; break;
      case "motorcyclist": color = Colors.cyan; break;
      case "scooty": color = Colors.deepOrange; break;
      case "truck": color = Colors.purple; break;
      case "bike": color = Colors.indigo; break;
      default: color = Colors.green; break;
    }

    return Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
  }


  void View_Full_Image(File image) {
    setState(() {
      Selected_Gallery_Index = Gallery_Images.indexOf(image);
    });
  }

  void Exit_Full_View() {
    setState(() {
      Selected_Gallery_Index = -1;
    });
  }

  Widget _buildPreview() {
    if (Selected_File == null) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.image_outlined,
            size: 80,
            color: Colors.grey,
          ),
        ),
      );
    }

    if (Video_Controller != null && Video_Controller!.value.isInitialized) {
      return Stack(
        children: [
          AspectRatio(
            aspectRatio: Video_Controller!.value.aspectRatio,
            child: VideoPlayer(Video_Controller!),
          ),
          if (Is_Video_Detection_Running && Detections.isNotEmpty)
            CustomPaint(
              painter: VideoBoundingBoxPainter(
                videoSize: Video_Controller!.value.size,
                detections: Detections,
                getClassPaint: Colors_For_Class_Labels,
              ),
              child: Container(),
            ),
        ],
      );
    } else {
      return Stack(
        children: [
          GestureDetector(
            onTap: () => View_Full_Image(Selected_File!),
            child: Image.file(
              Selected_File!,
              width: double.infinity,
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          if (Image_To_Draw != null && Detections.isNotEmpty)
            CustomPaint(
              painter: ImageBoundingBoxPainter(
                image: Image_To_Draw!,
                detections: Detections,
                getClassPaint: Colors_For_Class_Labels,
              ),
              size: Size.infinite,
            ),
        ],
      );
    }
  }
 //It will show the cloudinary images
  Widget _buildGallery() {
    if (isLoadingGallery) {
      return const Center(child: CircularProgressIndicator());
    }

    if (cloudinaryImageUrls.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        const Text(
          "Gallery",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: cloudinaryImageUrls.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    Selected_Gallery_Index = index;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(cloudinaryImageUrls[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFullView() {
    return Stack(
      children: [
        InteractiveViewer(
          child: Center(
            child: Image.network(
              cloudinaryImageUrls[Selected_Gallery_Index],
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          top: 16,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: Exit_Full_View,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Selected_Gallery_Index >= 0) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: _buildFullView(),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Stack(
                  alignment: Alignment.center,
                  children: [
                    const Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Upload",
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: "Archivo",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 8),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: const BoxDecoration(
                              color: Color(0xFF535CE8),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_outline,
                                color: Color.fromARGB(255, 245, 244, 244),
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Upload Card Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                            onPressed: Image_Picker_For_Detection,
                            icon: const Icon(Icons.image_outlined,
                                color: Color(0xFF6E75EC)),
                            label: const Text("Upload Photo"),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF6E75EC)),
                              foregroundColor: const Color(0xFF6E75EC),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton.icon(
                            onPressed: Video_Picker_For_Detection,
                            icon: const Icon(Icons.play_circle_outline,
                                color: Color(0xFF6E75EC)),
                            label: const Text("Upload Video"),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF6E75EC)),
                              foregroundColor: const Color(0xFF6E75EC),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: Capture_Image_For_Detection,
                        icon: const Icon(Icons.camera_alt_outlined,
                            color: Color(0xFF6E75EC)),
                        label: const Text("Capture Image"),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF6E75EC)),
                          foregroundColor: const Color(0xFF6E75EC),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        Selected_File?.path.split('/').last ??
                            "No File Selected",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                          Selected_File != null && !Is_Detecting ? Detect_Smoke : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Is_Detecting
                                ? Colors.grey
                                : const Color(0xFF6E75EC),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Is_Detecting
                              ? const CircularProgressIndicator(
                              color: Colors.white)
                              : const Text(
                            "Detect Smoke",
                            style: TextStyle(
                              fontFamily: "Archivo",
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Preview Section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 200,
                        child: _buildPreview(),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          /*
                          OutlinedButton.icon(
                            onPressed: _captureImage,
                            icon: const Icon(Icons.camera_alt_outlined,
                                color: Color(0xFF6E75EC)),
                            label: const Text("  SnapShot     "),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF6E75EC)),
                              foregroundColor: const Color(0xFF6E75EC),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),

                           */
                          OutlinedButton.icon(
                            onPressed: isUploading || Detections.isEmpty ? null : Save_Detection_Result,
                            icon: isUploading
                                ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF6E75EC),
                              ),
                            )
                                : const Icon(Icons.cloud_upload_outlined, color: Color(0xFF6E75EC)),
                            label: isUploading
                                ? const Text("  Saving...    ")
                                : const Text("  Add Data     "),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Color(0xFF6E75EC)),
                              foregroundColor: const Color(0xFF6E75EC),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ],
                      ),
                      _buildGallery(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

}



