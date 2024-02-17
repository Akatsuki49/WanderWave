import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '/controllers/image_controller.dart';
import '/models/image_model.dart';
import '/models/quote_model.dart';
import '/services/api_service.dart';
import '/screens/auth/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImageController _imageController = ImageController();
  final ApiService _apiService = ApiService();
  late ImageModel _currentImage;
  late QuoteModel _currentQuote;
  late TextEditingController _textController;
  bool _isLoading = false;
  bool _isCameraEnabled = false;

  @override
  void initState() {
    _textController = TextEditingController();
    _initializeData();
    _startAutoCapture();
    super.initState();
  }

  Future<void> _initializeData() async {
    // Dummy image data (replace with actual image capture logic)
    final dummyImageData = 'dummy_image_data';
    // Dummy quotes (replace with actual quote generation logic)
    final dummyQuotes = [
      "Quote 1",
      "Quote 2",
      "Quote 3",
      "Quote 4",
      "Quote 5",
    ];
    setState(() {
      _currentImage = ImageModel(data: dummyImageData);
      _currentQuote = QuoteModel(quotes: dummyQuotes);
    });
  }

  Future<void> _captureAndGenerate() async {
    setState(() {
      _isLoading = true;
    });
    final image = await _imageController.captureImage();
    final emotion = ''; // Call emotion analysis API to get emotion from image
    final quotes = await _apiService.generateQuotes(emotion);
    setState(() {
      _currentImage = image;
      _currentQuote = QuoteModel(quotes: quotes);
      _isLoading = false;
    });
  }

  void _startAutoCapture() {
    // Timer to auto-capture image every 15 seconds
    const Duration autoCaptureInterval = Duration(seconds: 15);
    Timer.periodic(autoCaptureInterval, (timer) {
      if (_isCameraEnabled && !_isLoading) {
        _captureAndGenerate();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('EmoSense'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Logout logic
              FirebaseAuth.instance.signOut();
              // Navigate back to the login screen
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Emotion: ${_currentImage.data}',
            ), // Display current emotion
            SizedBox(height: 20),
            Column(
              children: _currentQuote.quotes
                  .map((quote) => Text(quote))
                  .toList(), // Display quotes
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      enabled: !_isLoading,
                      decoration: InputDecoration(
                        hintText: 'How are you feeling?',
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _captureAndGenerate,
                    child:
                        _isLoading ? CircularProgressIndicator() : Text('Send'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
