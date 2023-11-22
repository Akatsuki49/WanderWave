import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wanderwave/models/itinerary_model.dart';
import 'package:wanderwave/services/itinerary_services.dart';

class ItineraryEntryPage extends StatefulWidget {
  const ItineraryEntryPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ItineraryEntryPageState createState() => _ItineraryEntryPageState();
}

class _ItineraryEntryPageState extends State<ItineraryEntryPage> {
  final Firebase_Operations _controller = Firebase_Operations();
  final TextEditingController destinationController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  final TextEditingController activitiesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerary Entry'),
      ),
      body: Padding(
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
      // Create an Itinerary_class instance
      Itinerary_class newEntry = Itinerary_class(
        id: '', // You can generate a unique ID here or let Firebase generate it
        destination: destinationController.text,
        startDate: startDate!,
        endDate: endDate!,
        activities: activitiesController.text.split(',').map((e) => e.trim()).toList(),
      );

      // Call the Firebase operation to add the entry
      _controller.addItinerary(newEntry);

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
        activitiesController.text.isNotEmpty;
  }
}
