import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:wanderwave/widgets/group_list_helper.dart';

class ExpensesScreen extends StatefulWidget {
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final TextEditingController _joinGroupIdController = TextEditingController();
  final TextEditingController _newGroupNameController = TextEditingController();
  String? _userId;

  void initState() {
    super.initState();
    _getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                await createGroup(_userId, _newGroupNameController.text);
                _newGroupNameController.clear();
                setState(() {});
              },
              child: Text('Create Group'),
            ),
            TextField(
              controller: _newGroupNameController,
              decoration: InputDecoration(
                labelText: 'New Group Name',
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Your Groups',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: FutureBuilder<List<DocumentSnapshot>>(
                future: getUserGroups(_userId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
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
                          if (noGroups) Center(child: Text('No groups yet.')),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              _showJoinGroupDialog(context);
                            },
                            child: Text('Join Group'),
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
          title: Text('Join Group'),
          content: TextField(
            controller: _joinGroupIdController,
            decoration: InputDecoration(
              labelText: 'Enter Group ID',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // Implement join group functionality here
                _joinGroup(_joinGroupIdController.text);
                _joinGroupIdController.clear();
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Join'),
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
    await joinGroup(groupId, _userId!); // Assuming _userId is not null
    setState(() {
      // Refresh the UI after joining a group
    });
  }

  Future<void> createGroup(String? userId, String groupName) async {
    var groupId = Uuid().v4(); // Generate a UUID for group ID
    await FirebaseFirestore.instance.collection('groups').doc(groupId).set({
      'members': [userId],
      'group_name': groupName,
      // Include other group details as needed
    });
  }

  Future<void> joinGroup(String? groupId, String userId) async {
    var groupDoc = FirebaseFirestore.instance.collection('groups').doc(groupId);
    var group = await groupDoc.get();
    if (group.exists) {
      await groupDoc.update({
        'members': FieldValue.arrayUnion([userId]),
      });
    } else {
      // Handle non-existent group
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
