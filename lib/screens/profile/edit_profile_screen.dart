import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:wanderwave/services/firebase_auth_methods.dart';
import 'package:wanderwave/widgets/auth_icon_button.dart';
import 'package:wanderwave/widgets/auth_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const EditProfileScreen({
    super.key,
    required this.userData,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
  }

  Future<bool> getUserProfileDataFromFirebase(User user) async {
    final ans = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((value) {
      if (value.exists) {
        userData = value.data()!;
        return true;
      } else {
        return false;
      }
    });
    return ans;
  }

  Future<String?> uploadImageToFirebaseStorage(
      File imageFile, String userID) async {
    try {
      firebase_storage.Reference storageReference = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('profile_images/$userID.jpg');

      final firebase_storage.UploadTask uploadTask =
          storageReference.putFile(imageFile);

      await uploadTask.whenComplete(() => null);

      return await storageReference.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController aboutController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  File? _image;

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    return FutureBuilder(
      future: getUserProfileDataFromFirebase(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return const Center(child: Text("Error"));
        }

        nameController.text = userData['Name'] ?? '';
        emailController.text = userData['Email'] ?? '';
        aboutController.text = userData['About'] ?? '';

        return Scaffold(
          body: Center(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const Text(
                      "Edit Your Profile",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 33,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xff234243),
                          child: _image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.file(
                                    _image!,
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.network(
                                    userData["ImageURL"] ??
                                        "https://api.multiavatar.com/Doge%20Bulls.png",
                                    width: 100,
                                    height: 100,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () async {
                              final pickedFile = await _imagePicker.pickImage(
                                source: ImageSource.gallery,
                              );
                              if (pickedFile != null) {
                                setState(() {
                                  _image = File(pickedFile.path);
                                });
                              }
                            },
                            child: Container(
                              width: 35,
                              height: 35,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.yellow,
                              ),
                              child: const Icon(Icons.edit),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    AuthTextField(
                      controller: nameController,
                      hintText: 'Enter Your Name',
                    ),
                    const SizedBox(height: 30),
                    AuthTextField(
                      controller: emailController,
                      hintText: 'Enter Your Email',
                    ),
                    const SizedBox(height: 30),
                    AuthTextField(
                      controller: aboutController,
                      hintText: 'Tell us about yourself',
                    ),
                    const SizedBox(height: 30),
                    AuthIconButton(
                      labelText: 'Save',
                      isSvg: false,
                      icon: Icons.save,
                      onPress: () async {
                        final userID = user.uid;

                        final name = nameController.text;
                        final email = emailController.text;
                        final about = aboutController.text;
                        String imageURL =
                            "https://api.multiavatar.com/Doge%20Bulls.png";

                        if (_image != null) {
                          final uploadedImageUrl =
                              await uploadImageToFirebaseStorage(
                                  _image!, userID);
                          if (uploadedImageUrl != null) {
                            imageURL = uploadedImageUrl;
                          }
                        }

                        final userData = {
                          'Name': name,
                          'Email': email,
                          'About': about,
                          'ImageURL': imageURL
                        };

                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(userID)
                              .set(userData);

                          // ignore: use_build_context_synchronously
                          Navigator.pop(context, userData);
                        } catch (e) {}
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
