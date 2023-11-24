import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:wanderwave/Itinerary/itinerary_page.dart';
import 'package:wanderwave/models/itinerary_model.dart';
import '../Itinerary/itinerary_item.dart';
import '../services/itinerary_services.dart';

class ItineraryList extends StatefulWidget {
  const ItineraryList({Key? key}) : super(key: key);

  @override
  State<ItineraryList> createState() => _ItineraryListState();
}

class _ItineraryListState extends State<ItineraryList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Firebase_Operations op = Firebase_Operations();

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    if (user == null) {
      // If the user is not logged in, you may want to redirect to the login page
      return const Scaffold(
        body: Center(
          child: Text('User not logged in'),
        ),
      );
    }

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Itinerary')
            .where('userId', isEqualTo: user.uid) // Filter by user ID
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final itineraries = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Itinerary_class.fromJson({
              'id': doc.id,
              'userId': data['userId'], // Set userId from Firestore data
              'destination': data['destination'],
              'startDate': data['startDate'],
              'endDate': data['endDate'],
              'activities': List<String>.from(data['activities']),
            });
          }).toList();

          if (itineraries.isEmpty) {
            // Display a message and an image when there are no entries
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Plan your Itinerary',
                    style: TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 10),
                  Image.asset(
                    'assets/itinerary.png', // Replace with your image path
                    width: 200,
                    height: 200,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: itineraries.length,
            shrinkWrap: true,
            itemBuilder: (context, index) {
              final itinerary = itineraries[index];
              return Itinerary(itinerary, currentUserId: user.uid);
              // Make sure to pass the currentUserId here
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ItineraryEntryPage(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
