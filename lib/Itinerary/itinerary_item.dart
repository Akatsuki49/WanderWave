import 'package:flutter/material.dart';
import 'package:wanderwave/services/itinerary_services.dart';

import '../models/itinerary_model.dart';

class Itinerary extends StatefulWidget {
  final Itinerary_class itinerary;

  const Itinerary(
    this.itinerary, {
    Key? key,
  }) : super(key: key);

  @override
  State<Itinerary> createState() => _ItineraryState();
}

class _ItineraryState extends State<Itinerary> {
  final Firebase_Operations _controller = Firebase_Operations();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(
          widget.itinerary.destination,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Start Date: ${widget.itinerary.startDate.toString()}\nEnd Date: ${widget.itinerary.endDate.toString()}',
          style: const TextStyle(fontSize: 14),
        ),
        leading: IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            // Call the method to update the itinerary
            // You need to implement the logic to navigate to the update screen
            // where you can modify the itinerary details and call updateItinerary method.
          },
        ),
        trailing: IconButton(
          color: Colors.red,
          icon: const Icon(Icons.delete),
          onPressed: () {
            // Call the method to delete the itinerary
            _controller.delete(widget.itinerary.id);
          },
        ),
      ),
    );
  }
}
