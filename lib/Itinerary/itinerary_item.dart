import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wanderwave/services/itinerary_services.dart';
import '../models/itinerary_model.dart';
import 'package:wanderwave/Itinerary/itinerary_page.dart';

class Itinerary extends StatefulWidget {
  final Itinerary_class itinerary;
  final String currentUserId;

  const Itinerary(
    this.itinerary, {
    required this.currentUserId,
    Key? key,
  }) : super(key: key);

  @override
  State<Itinerary> createState() => _ItineraryState();
}

class _ItineraryState extends State<Itinerary> {
  final Firebase_Operations _controller = Firebase_Operations();

  @override
  Widget build(BuildContext context) {
    // Check if the itinerary belongs to the current user
    bool isCurrentUserItinerary = widget.itinerary.userId == widget.currentUserId;

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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Start Date: ${_formatDate(widget.itinerary.startDate)}\nEnd Date: ${_formatDate(widget.itinerary.endDate)}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 4), // Add some spacing
            const Text(
              'Activities:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.itinerary.activities.join(', '),
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        leading: isCurrentUserItinerary
            ? IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ItineraryEntryPage(
                        itinerary: widget.itinerary,
                      ),
                    ),
                  );
                },
              )
            : null,
        trailing: isCurrentUserItinerary
            ? IconButton(
                color: Colors.red,
                icon: const Icon(Icons.delete),
                onPressed: () {
                  // Call the method to delete the itinerary
                  _controller.delete(widget.itinerary.id);
                },
              )
            : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
