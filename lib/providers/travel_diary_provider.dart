import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'package:wanderwave/models/travel_diary_model.dart';

class TravelDiaryProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  List<TravelDiaryEntry> _entries = [];
  bool _entriesFetched = false;

  bool get entriesFetched => _entriesFetched;

  List<TravelDiaryEntry> get entries => _entries;

  Future<void> fetchEntries() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    final snapshot = await _firestore
        .collection('travel_diary')
        .where('userId', isEqualTo: currentUser.uid)
        .get();

    _entries = snapshot.docs
        .map((doc) => TravelDiaryEntry.fromMap(doc.data()..['id'] = doc.id))
        .toList();
    _entriesFetched = true; // Set to true once entries are fetched

    notifyListeners();
  }

  Future<void> addEntry(TravelDiaryEntry entry, List<Asset> images) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    List<String> imageUrls = [];

    //Creating a batch for Firestore writes- parallel read, write and update - still a lot of time it takes :(
    WriteBatch batch = _firestore.batch();

    // Upload images to Firebase Storage
    for (var i = 0; i < images.length; i++) {
      final storageRef = _storage
          .ref()
          .child('images/${currentUser.uid}/${entry.id}/image_$i.jpg');

      ByteData byteData = await images[i].getByteData();
      List<int> imageData = byteData.buffer.asUint8List();

      final UploadTask uploadTask =
          storageRef.putData(Uint8List.fromList(imageData));
      final TaskSnapshot storageTaskSnapshot = await uploadTask;
      final String imageUrl = await storageTaskSnapshot.ref.getDownloadURL();
      imageUrls.add(imageUrl);
    }

    // Add a new entry to the batch
    batch.set(
      _firestore.collection('travel_diary').doc(),
      {
        ...entry.toMap(),
        'id': entry.id,
        'userId': currentUser.uid,
        'imageUrls': imageUrls,
      },
    );

    // Commit the batch
    await batch.commit();

    _entries.add(TravelDiaryEntry(
      id: entry.id,
      title: entry.title,
      description: entry.description,
      imageUrls: imageUrls,
    ));
    notifyListeners();
  }

  Future<void> deleteEntry(String entryId) async {
    print(entryId);
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return;
    }

    // Fetch the entry from the local list
    final entryIndex = _entries.indexWhere((entry) => entry.id == entryId);

    if (entryIndex == -1) {
      return; // Entry not found
    }

    // Delete from Firebase Storage if the entry has image URLs
    // TODO: Delete images from Firebase Storage

    // Delete from Firestore
    await _firestore.collection('travel_diary').doc(entryId).delete();

    // Remove from the local list
    _entries.removeAt(entryIndex);

    notifyListeners();
  }
}
