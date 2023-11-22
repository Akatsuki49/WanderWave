// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/itinerary_model.dart';

// ignore: camel_case_types
class Firebase_Operations {
  final FirebaseFirestore _instance = FirebaseFirestore.instance;

  Future<void> addItinerary(Itinerary_class itinerary) async {
    await _instance.collection('Itinerary').add(itinerary.toJson());
  }

  Future<void> delete(String? id) async {
    try {
      await _instance.collection('Itinerary').doc(id).delete();
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateItinerary(Itinerary_class itinerary) async {
    try {
      await _instance.collection('Itinerary').doc(itinerary.id).update(itinerary.toJson());
    } catch (e) {
      print(e);
    }
  }
}
