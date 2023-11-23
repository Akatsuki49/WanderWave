import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wanderwave/models/itinerary_model.dart';
import 'package:wanderwave/services/itinerary_services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItineraryEntryPage extends StatefulWidget {
  final Itinerary_class? itinerary;

  const ItineraryEntryPage({
    Key? key,
    this.itinerary,
  }) : super(key: key);

  @override
  _ItineraryEntryPageState createState() => _ItineraryEntryPageState();
}

class _ItineraryEntryPageState extends State<ItineraryEntryPage> {
  final Firebase_Operations _controller = Firebase_Operations();
  User? user = FirebaseAuth.instance.currentUser;
  final TextEditingController destinationController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController activitiesController = TextEditingController();
  @override
  void initState() {
    super.initState();

    // Check if it's an update
    if (widget.itinerary != null) {
      // Fill form fields with existing itinerary details
      destinationController.text = widget.itinerary!.destination;
      startDate = widget.itinerary!.startDate;
      endDate = widget.itinerary!.endDate;
      activitiesController.text = widget.itinerary!.activities.join(', ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary Entry'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: destinationController,
                decoration: const InputDecoration(labelText: 'Destination'),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(true),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Start Date',
                        ),
                        child: Text(
                          startDate != null
                              ? DateFormat('yyyy-MM-dd').format(startDate!)
                              : 'Select Start Date',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(false),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'End Date',
                        ),
                        child: Text(
                          endDate != null
                              ? DateFormat('yyyy-MM-dd').format(endDate!)
                              : 'Select End Date',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: activitiesController,
                decoration: const InputDecoration(labelText: 'Activities'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  // Validate and save the entry
                  _saveEntry();
                },
                child: const Text('Save Entry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }

  void _saveEntry() {
    // Validate the form
    if (_validateForm()) {
      // Check if it's an update or a new entry
      if (widget.itinerary != null) {
        // It's an update, create an updated Itinerary_class instance
        Itinerary_class updatedEntry = Itinerary_class(
          id: widget.itinerary!.id,
          userId: widget.itinerary!.userId, // Preserve userId
          destination: destinationController.text,
          startDate: startDate!,
          endDate: endDate!,
          activities: activitiesController.text.split(',').map((e) => e.trim()).toList(),
        );

        // Call the Firebase operation to update the entry
        _controller.updateItinerary(updatedEntry);
      } else {
        // It's a new entry, create a new Itinerary_class instance
        Itinerary_class newEntry = Itinerary_class(
          id: '', // You can generate a unique ID here or let Firebase generate it
          userId: user?.uid ?? '', // Set the userId based on the authenticated user
          destination: destinationController.text,
          startDate: startDate!,
          endDate: endDate!,
          activities: activitiesController.text.split(',').map((e) => e.trim()).toList(),
        );

        // Call the Firebase operation to add the entry
        _controller.addItinerary(newEntry);
      }

      // Optionally, you can navigate back to the previous screen or perform other actions
      Navigator.pop(context);
    } else {
      // Handle validation errors or show a message to the user
      // For simplicity, you can display a SnackBar with an error message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields with valid data.'),
        ),
      );
    }
  }

  bool _validateForm() {
    // Perform your own validation logic here
    // For simplicity, we'll just check if all fields are non-empty
    return destinationController.text.isNotEmpty &&
        startDate != null &&
      endDate != null &&
      activitiesController.text.isNotEmpty &&
      startDate!.isBefore(endDate!);
  }
}
