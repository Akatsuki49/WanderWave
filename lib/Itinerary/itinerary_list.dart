import 'package:cloud_firestore/cloud_firestore.dart';
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
  Firebase_Operations op = Firebase_Operations();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection('Itinerary').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final itineraries = snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return Itinerary_class.fromJson({
                'id': doc.id,
                'destination': data['destination'],
                'startDate': data['startDate'],
                'endDate': data['endDate'],
                'activities': List<String>.from(data['activities']),
              });
            }).toList();

            return ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: itineraries.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final itinerary = itineraries[index];
                return Itinerary(itinerary);
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
        ));
  }
}
