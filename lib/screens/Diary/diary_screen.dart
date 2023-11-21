import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderwave/providers/travel_diary_provider.dart';
import 'package:wanderwave/utils/snack_bar.dart';
import 'add_entry_screen.dart';
import 'view_entry.dart';

class TravelDiaryScreen extends StatefulWidget {
  const TravelDiaryScreen({Key? key}) : super(key: key);

  @override
  _TravelDiaryScreenState createState() => _TravelDiaryScreenState();
}

class _TravelDiaryScreenState extends State<TravelDiaryScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch entries when the screen is first loaded
    Provider.of<TravelDiaryProvider>(context, listen: false).fetchEntries();
  }

  Widget build(BuildContext context) {
    print('TravelDiaryScreen build');

    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color(0xffb2d8d8),
      appBar: AppBar(
        title: const Text('My Diary',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.black)),
        backgroundColor: Color(0xffb2d8d8), // Subtle green color
        elevation: 0,
      ),
      body: Consumer<TravelDiaryProvider>(
        builder: (context, travelDiaryProvider, child) {
          final entries = travelDiaryProvider.entries;
          // print("Image URLs: ${entries[0].imageUrls.toString()}"); //do not use if empty entries will crash the app
          if (!travelDiaryProvider.entriesFetched) {
            // Entries are still being fetched, show a loading indicator or
            // a different message.
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return entries.isEmpty
              ? Center(
                  child: Column(
                    children: [
                      SizedBox(height: height * 0.15),
                      Text(
                        'Journal Your Entry',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      Image.asset(
                        'assets/diary_img.png',
                        height: 200,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    return Dismissible(
                      key: Key(entry.id),
                      onDismissed: (direction) {
                        // Delete entry when dismissed
                        Provider.of<TravelDiaryProvider>(context, listen: false)
                            .deleteEntry(entry.id);
                        // Show feedback for deletion
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Entry deleted"),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      confirmDismiss: (direction) async {
                        // Show confirmation dialog before deleting
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Delete Entry"),
                              content: Text(
                                  "Are you sure you want to delete this entry?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: Text("No"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: Text("Yes"),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      background: Container(
                        color: Colors.red,
                        child: Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 36,
                        ),
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20),
                      ),
                      child: AnimatedSwitcher(
                        duration: Duration(milliseconds: 500),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          key: ValueKey(entry.id),
                          elevation: 4,
                          margin:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) =>
                                    ViewTravelEntryDetailsScreen(entry),
                              ));
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                entry.imageUrls.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: entry.imageUrls[
                                            0], //first image for thumbnail lol
                                        placeholder: (context, url) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Icon(Icons.error),
                                      )
                                    : Container(),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              entry.title,
                                              style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors
                                                      .black87 // Subtle green color
                                                  ),
                                            ),
                                          ),
                                          Spacer(),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              // Show alert dialog for deletion
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title: Text("Delete Entry"),
                                                    content: Text(
                                                        "Are you sure you want to delete this entry?"),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () =>
                                                            Navigator.of(
                                                                    context)
                                                                .pop(),
                                                        child: Text("Cancel"),
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          // Delete entry when confirmed
                                                          Provider.of<TravelDiaryProvider>(
                                                                  context,
                                                                  listen: false)
                                                              .deleteEntry(
                                                                  entry.id);
                                                          // Show feedback for deletion
                                                          travelDiarySnackBar(
                                                              context,
                                                              "Message Deleted"); //defined in utils
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text("Delete"),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 8.0),
                                        child: Text(
                                          entry.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
        },
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AddTravelEntryScreen(),
            ));
          },
          label: Text(
            "Add entry",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          icon: Image.asset('assets/add_entry.png', height: 28, width: 28),
          backgroundColor: Color(0xFF66B2B2), // Updated color
        ),
      ),
    );
  }
}
