import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderwave/providers/travel_diary_provider.dart';
import 'package:wanderwave/models/travel_diary_model.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class AddTravelEntryScreen extends StatefulWidget {
  @override
  _AddTravelEntryScreenState createState() => _AddTravelEntryScreenState();
}

class _AddTravelEntryScreenState extends State<AddTravelEntryScreen> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  List<Asset> selectedImages = [];
  bool isUploading = false;

  Future<void> _pickImages() async {
    List<Asset> result = [];
    try {
      result = await MultiImagePicker.pickImages(
        maxImages: 5,
        enableCamera: true,
      );
    } on Exception catch (e) {
      // Handle the exception
    }

    if (!mounted) return;

    setState(() {
      selectedImages = result;
    });
  }

  Future<void> _addEntry() async {
    if (selectedImages.isEmpty) {
      // Show an error message or handle the case where no image is selected
      return;
    }

    setState(() {
      isUploading = true;
    });

    final entry = TravelDiaryEntry(
      id: '',
      title: titleController.text,
      description: descriptionController.text,
      imageUrls: [],
      // Images will be uploaded in the provider
    );

    await Provider.of<TravelDiaryProvider>(context, listen: false)
        .addEntry(entry, selectedImages);

    setState(() {
      isUploading = false;
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Travel Entry',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xffb2d8d8),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      backgroundColor: Color(0xffb2d8d8),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: Color(0xFFC4E4E4),
          elevation: 20,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Capture Your Journey',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: titleController,
                    style: TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.4),
                        spreadRadius: 3,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: descriptionController,
                    style: TextStyle(fontSize: 18),
                    maxLines: 4, // Allowing multiple lines for description
                    decoration: InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _pickImages,
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF66B2B2),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text('Pick Images', style: TextStyle(fontSize: 18)),
                ),
                SizedBox(height: 16),
                selectedImages.isNotEmpty
                    ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                        ),
                        itemCount: selectedImages.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.4),
                                  spreadRadius: 3,
                                  blurRadius: 10,
                                  offset: Offset(0, 5),
                                ),
                              ],
                            ),
                            child: AssetThumb(
                              asset: selectedImages[index],
                              width: 300,
                              height: 300,
                            ),
                          );
                        },
                      )
                    : Container(),
                SizedBox(height: 16),
                isUploading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _addEntry,
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xFF66B2B2),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child:
                            Text('Add Entry', style: TextStyle(fontSize: 18)),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
