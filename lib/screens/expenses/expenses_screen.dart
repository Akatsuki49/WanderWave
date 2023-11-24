
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wanderwave/screens/expenses/group_list_helper.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _joinGroupIdController = TextEditingController();
  final TextEditingController _newGroupNameController = TextEditingController();
  String? _userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await createGroup(_userId, _newGroupNameController.text);
                _newGroupNameController.clear();
                setState(() {});
              },
              child: const Text('Create Group'),
            ),
            TextField(
              controller: _newGroupNameController,
              decoration: const InputDecoration(
                labelText: 'New Group Name',
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Groups',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: getUserGroups(_userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else {
                    List<DocumentSnapshot>? groups = snapshot.data;
                    bool noGroups = groups == null || groups.isEmpty;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          GroupListWidget(
                              groups: groups,
                              onJoinPressed: () {
                                _showJoinGroupDialog(context);
                              }),
                          if (noGroups) const Center(child: Text('No groups yet.')),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _showJoinGroupDialog(context);
                            },
                            child: const Text('Join Group'),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showJoinGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Group'),
          content: TextField(
            controller: _joinGroupIdController,
            decoration: const InputDecoration(
              labelText: 'Enter Group ID',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement join group functionality here
                _joinGroup(_joinGroupIdController.text);
                _joinGroupIdController.clear();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Join'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _getCurrentUser() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      setState(() {
        _userId = user.uid;
      });
    }
  }

  // Method to join a group
  void _joinGroup(String groupId) async {
    bool joined =
        await joinGroup(groupId, _userId!); // Assuming _userId is not null
    if (joined) {
      setState(() {
        // Refresh the UI after joining a group
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Group ID does not exist.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> createGroup(String? userId, String groupName) async {
    var groupId = const Uuid().v4(); // Generate a UUID for group ID
    await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
      'members': [userId],
      'group_name': groupName,
      // Include other group details as needed
    });
  }

  Future<bool> joinGroup(String? groupId, String userId) async {
    var groupDoc = FirebaseFirestore.instance.collection('groups').doc(groupId);
    var group = await groupDoc.get();
    if (group.exists) {
      await groupDoc.update({
        'members': FieldValue.arrayUnion([userId]),
      });
      return true; // Successfully joined the group
    } else {
      return false; // Group doesn't exist
    }
  }

  Future<List<DocumentSnapshot>> getUserGroups(String? userId) async {
    var querySnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: userId)
        .get();
    return querySnapshot.docs;
  }
}
