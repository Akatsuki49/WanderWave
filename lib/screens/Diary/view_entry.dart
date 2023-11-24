import 'package:flutter/material.dart';
import 'package:wanderwave/models/travel_diary_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ViewTravelEntryDetailsScreen extends StatelessWidget {
  final TravelDiaryEntry entry;

  const ViewTravelEntryDetailsScreen(this.entry, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Collage of all images
            SizedBox(
              height: 200, // Set a fixed height for the GridView
              child: buildImageGrid(entry.imageUrls),
            ),
            // Description
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                entry.description,
                style: const TextStyle(fontSize: 16.0),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageGrid(List<String> imageUrls) {
    // Check the number of images
    if (imageUrls.length == 1) {
      // If only one image, display it in full size
      return CachedNetworkImage(
        imageUrl: imageUrls[0],
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      );
    } else {
      // If multiple images, create a responsive grid
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: imageUrls.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: imageUrls[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          );
        },
      );
    }
  }
}
