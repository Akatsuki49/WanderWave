import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BuildNSendMsgs {
  static Widget buildGenericMessage(Map<String, dynamic> messageData) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey[200],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          messageData['text'],
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'From: ${messageData['from']}',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey[600],
          ),
        ),
      ),
    );
  }

  static Future<void> sendMessage(
      String groupId, String senderId, String text) async {
    CollectionReference messagesRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages');

    await messagesRef.add({
      'text': text,
      'from': senderId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> sendExpenseMessage(
      String groupId, String senderId, String expenseAmount) async {
    CollectionReference messagesRef = FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .collection('messages');

    // Fetch group members
    DocumentSnapshot groupSnapshot = await FirebaseFirestore.instance
        .collection('groups')
        .doc(groupId)
        .get();

    if (!groupSnapshot.exists) {
      print('Group not found');
      return; // Exit function if group is not found
    }

    Map<String, dynamic> groupData =
        groupSnapshot.data() as Map<String, dynamic>;

    List<dynamic> groupMembers = groupData['members'];

    // Calculate share per member
    int numberOfGroupMembers = groupMembers.length;
    double totalExpenses = double.parse(expenseAmount);
    double share = totalExpenses / numberOfGroupMembers;

    // Add the overall expense to the messages collection
    DocumentReference expenseDocRef = await messagesRef.add({
      'expense': expenseAmount,
      'userId': senderId,
      'paid': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    String newExpenseId = expenseDocRef.id; // Get the newly created expense ID

    // Add the expenses to Firestore for each user with the new expense ID
    for (var userId in groupMembers) {
      // Reference to the user's document in Firestore
      DocumentReference userExpenseRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection(
              'users_expenses') // Points directly to user_expenses collection
          .doc(userId);

      // Get user's expenses data if it exists, otherwise, create a new document
      DocumentSnapshot userExpenseSnapshot = await userExpenseRef.get();
      Map<String, dynamic> userData = {};

      if (userExpenseSnapshot.exists) {
        userData = userExpenseSnapshot.data() as Map<String, dynamic>;
      }

      // Update or create the expenses map for the new expense ID
      userData[newExpenseId] = {
        'expense': share, // Assign share for each user
        'paid': false, // Initially set to false
        // Include other necessary fields here
      };

      // Update or set the user's expenses data in Firestore
      await userExpenseRef.set(userData);
    }

    print('Expenses added successfully');
  }
}
