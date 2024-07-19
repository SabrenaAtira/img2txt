import 'dart:io';
import 'package:translatify/widgets/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tesseract_ocr/android_ios.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clipboard/clipboard.dart';
import 'package:translatify/screen/viewsaved.dart';
import 'package:translatify/widgets/consts.dart';
import 'package:translatify/widgets/device.dart';
import '../widgets/utils.dart';

class RecognitionScreen extends StatefulWidget {
  const RecognitionScreen({super.key});

  @override
  State<RecognitionScreen> createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  @override
  void initState() {
    //cameraUtils.initializeCamera();
    recognizedText = '';
    getDeviceId();
    super.initState();
  }

  @override
  void dispose() {
    //cameraUtils.disposeCamera();
    super.dispose();
  }

  File? pickedimage;
  bool scanning = false;
  String recognizedText = '';
  String extractText = '';
  FlutterTts flutterTts = FlutterTts();
  final CameraUtils cameraUtils = CameraUtils();

  Future<void> saveFirebase(String text) async {
    try {
      String deviceId = await getDeviceId();
      await FirebaseFirestore.instance.collection('History').add({
        'recognizedText': text, // Use the same field name 'recognizedText'
        'timestamp': FieldValue.serverTimestamp(),
        'deviceId': deviceId,
      });
      // print('Text saved to History collection in Firebase!');
    } catch (e) {
      e.toString();
    }
  }

  Future<void> saveToFirebase(String text) async {
    try {
      String deviceId = await getDeviceId();
      await FirebaseFirestore.instance.collection('Saved').add({
        'Saved': text,
        'timestamp': FieldValue.serverTimestamp(),
        'deviceId': deviceId,
      });
      // print('Text saved to Firebase!');
    } catch (e) {
      e.toString();
    }
  }

  optionsdialog(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          children: [
            SimpleDialogOption(
              onPressed: () async {
                setState(() {
                  scanning = true;
                });
                pickedimage = await pickImage(ImageSource.gallery);

                
                

























                
                

                setState(() {
                  scanning = false;
                });
              },
              child: Text(
                "Gallery",
                style: textStyle(20, Colors.black, FontWeight.w800),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                await cameraUtils.initializeCamera();
                pickedimage = await pickImage(ImageSource.camera);

                // Check if pickedimage is not null before using it
                if (pickedimage != null) {
                  try {
                    recognizedText = await FlutterTesseractOcr.extractText(
                      pickedimage!.path,
                      // language: selectedLanguage,
                    );

                    // Save the recognized text to Firebase
                    await saveFirebase(recognizedText);

                    // Set the recognized text in the TextToSpeech class
                    TextToSpeech.ttsInput = recognizedText;
                  } catch (e) {
                    e.toString();
                  }
                }

                setState(() {
                  scanning = false;
                });
              },
              child: Text(
                "Camera",
                style: textStyle(20, Colors.black, FontWeight.w800),
              ),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Cancel",
                style: textStyle(20, Colors.black, FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<File?> pickImage(ImageSource source) async {
    //Kalau ada Future, kena ada return!
    final image = await ImagePicker().pickImage(source: source);

    if (source == ImageSource.camera) {
      // Initialize the camera before using it
      await cameraUtils.initializeCamera();
    }

    if (image == null) {
      return null;
    }
    setState(() {
      scanning = true;
      pickedimage = File(image.path);
      recognizedText = '';
    });

    // Perform additional tasks like text recognition, language identification, translation, etc.

    // ignore: use_build_context_synchronously
    Navigator.pop(context);
    return File(image.path);
  }

  Future<void> speakText(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  DateTime timeBackPressed = DateTime.now();

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
        onWillPop: () {
          final difference = DateTime.now().difference(timeBackPressed);
          final isExit = difference >= const Duration(seconds: 2);

          if (isExit) {
            Fluttertoast.showToast(msg: 'Press again to exit', fontSize: 14);
            return Future.value(false);
          } else {
            Fluttertoast.cancel();
            return exit(0);
          }
        },
        child: Scaffold(
            appBar: AppBar(
              elevation: 5,
              shadowColor: Colors.blue[400],
              backgroundColor: Colors.blue[200],
              title: const Text(
                'IMG2TXT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              centerTitle: true,
              actions: <Widget>[
                Builder(
                  builder: (context) => IconButton(
                    icon: const Icon(Icons.info_outline_rounded),
                    onPressed: () {
                      Scaffold.of(context).openEndDrawer();
                    },
                  ),
                ),
              ],
            ),
            endDrawer: Drawer(
                child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                Container(
                  height: 100.0,
                  color: Colors.blue[200],
                  child: const Center(
                    child: Text(
                      'About',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const ListTile(
                  title: Text(
                      "Instructions:\nText Recognition:\n1. Tap the \"Add file image\" button to choose an image from your gallery or use the camera to capture a new one.\n2. Wait for the system to automatically extract text from the selected image.\n3. The extracted text will be displayed on the screen. Click the \"Copy Text\" button to copy it.\n4. Click on the \"Speak\" button, then the application will read it aloud. \n 5. The system can clear your images and extracted text from the UI when the user clicks on Refresh button.' \n6. The text exracted can be saved into collections. \n\nSaved collections:\n1. Click on the \"Saved\" button to access the saved collection.\n2. The saved extracted text can be copied.\n3. The saved extracted text can be edited.\n4.The saved extracted text can be deleted. \n\nView History:\n1. Navigate to the \"History\" page by clicking on the \"History\" icon in the app bar.\n2. Explore history from previous extraction request. \n3. History of extraction request can be deleted. \n\nThank you for using IMG2TXT!"),
                ),
              ],
            )),
            backgroundColor: Colors.white,
            floatingActionButton: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(
                  width: 30,
                ),
                FloatingActionButton.extended(
                  backgroundColor: Colors.blue[100],
                  heroTag: null,
                  onPressed: () {
                    FlutterClipboard.copy(recognizedText).then((value) {
                      SnackBar snackBar = SnackBar(
                        content: Text(
                          "Copied to clipboard",
                          style: textStyle(18, Colors.white, FontWeight.w700),
                        ),
                        duration: const Duration(seconds: 1),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    });
                  },
                  label: const Column(
                    children: [
                      Icon(
                        Icons.copy,
                        size: 28,
                      ),
                      Text(
                        "Copy",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton.extended(
                  backgroundColor: Colors.blue[100],
                  heroTag: null,
                  onPressed: () {
                    setState(() {
                      speakText(recognizedText);
                    });
                  },
                  label: const Column(
                    children: [
                      Icon(
                        Icons.volume_up_rounded,
                        size: 28,
                      ),
                      Text(
                        "Speak",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                FloatingActionButton.extended(
                  backgroundColor: Colors.blue[100],
                  heroTag: null,
                  onPressed: () {
                    setState(() {
                      pickedimage = null;
                      recognizedText = '';
                    });
                  },
                  label: const Column(
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 28,
                      ),
                      Text(
                        "Refresh",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                FloatingActionButton.extended(
                  backgroundColor: Colors.blue[100],
                  heroTag: null,
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ViewSaved()));
                  },
                  label: const Column(
                    children: [
                      Icon(Icons.bookmark_added_outlined, size: 28),
                      Text(
                        "Saved",
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: ListView(children: [
              const SizedBox(height: 30),
              const Padding(
                padding: EdgeInsets.fromLTRB(20.0, 0.0, 25.0, 0.0),
                child: Text(
                  "Click on the add file to pick an image.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Container(
                width: double.infinity,
                height: 200.0,
                padding: const EdgeInsets.all(20.0),
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.blue,
                  ),
                ),
                child: InkWell(
                  onTap: () => optionsdialog(context),
                  child: pickedimage != null
                      ? Image(
                          width: 200,
                          height: 200,
                          image: FileImage(pickedimage!),
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(
                          width: 200,
                          height: 200,
                          child: Image(
                            image: AssetImage('assets/add_file_black.png'),
                          ),
                        ),
                ),
              ),
              const Text(
                "Text from the image:",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              Container(
                width: 350.0,
                height: MediaQuery.of(context).size.height * 0.3,
                margin: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                    color: Colors.blue,
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration:
                            const InputDecoration(border: InputBorder.none),
                        controller: TextEditingController(text: recognizedText),
                        maxLines: null,
                        expands: true,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.justify,
                        onChanged: (text) {
                          setState(() {
                            recognizedText = text;
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: IconButton(
                          icon: const Icon(Icons.bookmark_outline_rounded),
                          onPressed: () {
                            // Handle bookmark button click
                            setState(() {
                              saveToFirebase(recognizedText);
                              showSavedSnackBar(context);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ])));
  }
}

void showSavedSnackBar(BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
    content: Text('Text saved!'),
    duration: Duration(seconds: 2),
  ));
}
