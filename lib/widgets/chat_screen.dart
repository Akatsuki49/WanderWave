import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String userId;

  GroupChatScreen({required this.groupId, required this.userId});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  bool sendingExpense = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Chat'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('groups')
                  .doc(widget.groupId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<DocumentSnapshot> messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData =
                        messages[index].data() as Map<String, dynamic>;

                    if (messageData.containsKey('expense')) {
                      return buildExpenseMessage(messageData);
                    } else {
                      return buildGenericMessage(messageData);
                    }
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: sendingExpense
                          ? 'Enter expense amount...'
                          : 'Type a message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_money),
                  onPressed: () {
                    setState(() {
                      sendingExpense = !sendingExpense;
                    });
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (sendingExpense) {
                      sendExpenseMessage(widget.groupId, widget.userId,
                          _messageController.text.trim());
                    } else {
                      sendMessage(widget.groupId, widget.userId,
                          _messageController.text.trim());
                    }
                    _messageController.clear();
                    setState(() {
                      sendingExpense = false;
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExpenseMessage(Map<String, dynamic> messageData) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return CircularProgressIndicator();
        }

        if (!snapshot.data!.exists) {
          return Text('Group not found');
        }

        // Fetch group members
        Map<String, dynamic> groupData = snapshot.data!.data()
            as Map<String, dynamic>; // Adjust based on your structure

        List<dynamic> groupMembers = groupData['members']; // Adjust as needed
        print(groupMembers);

        // Calculate share per member
        int numberOfGroupMembers = groupMembers.length;
        // double totalExpenses = double.parse(_messageController.text.trim());
        double totalExpenses = double.parse(messageData['expense']);
        double share = totalExpenses / numberOfGroupMembers;

        // double totalExpenses = expensesPerMember.values
        //     .fold(0, (previous, current) => previous + current);
        // double share = totalExpenses / numberOfGroupMembers;

        // Display expenses per member
        return ListView.builder(
          shrinkWrap: true,
          itemCount: numberOfGroupMembers,
          itemBuilder: (context, index) {
            String userId = groupMembers[index];
            // String userId = expensesPerMember.keys.elementAt(index);
            // double userTotalExpense = expensesPerMember[userId] ?? 0;
            return ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text('$userId :'),
                  ),
                  Checkbox(
                      onChanged: (value) {},
                      value:
                          false // Assign the checkbox value based on the user's payment status,
                      ),
                ],
              ),
              subtitle: Text(
                  '${totalExpenses.toStringAsFixed(2)} / $numberOfGroupMembers = ${share.toStringAsFixed(2)}'),
            );
          },
        );
      },
    );
  }

  // Widget buildExpenseMessage(
  //     Map<String, dynamic> messageData, List<DocumentSnapshot> messages) {
  //   // Calculate expenses per member
  //   Map<String, double> expensesPerMember = {};

  //   for (var message in messages) {
  //     Map<String, dynamic> messageData = message.data() as Map<String, dynamic>;

  //     if (messageData.containsKey('expense')) {
  //       String userId = messageData['userId'];
  //       double expense = double.parse(messageData['expense']);

  //       if (userId != widget.userId) {
  //         expensesPerMember[userId] =
  //             (expensesPerMember[userId] ?? 0) + expense;
  //       }
  //     }
  //   }

  //   // Calculate share per member
  //   int numberOfGroupMembers =
  //       expensesPerMember.length + 1; // +1 for current user
  //   double totalExpenses = expensesPerMember.values
  //       .fold(0, (previous, current) => previous + current);
  //   double share = totalExpenses / numberOfGroupMembers;

  //   // Display expenses per member
  //   return ListView.builder(
  //       shrinkWrap: true,
  //       itemCount: expensesPerMember.length,
  //       itemBuilder: (context, index) {
  //         String userId = expensesPerMember.keys.elementAt(index);
  //         double userTotalExpense = expensesPerMember[userId] ?? 0;
  //         return ListTile(
  //           title: Text(
  //               '$userId : ${userTotalExpense.toStringAsFixed(2)} / $numberOfGroupMembers = ${share.toStringAsFixed(2)}'),
  //         );
  //       });
  //   // return ListTile(
  //   //   title: Text('${messageData['userId']} : ${messageData['expense']}'),
  //   //   subtitle: Checkbox(
  //   //     value: messageData['paid'] ?? false,
  //   //     onChanged: (bool? value) {
  //   //       // Handle checkbox change
  //   //       // You may update Firestore to mark the expense as paid here
  //   //     },
  //   //   ),
  //   // );
  // }

  Widget buildGenericMessage(Map<String, dynamic> messageData) {
    return ListTile(
      title: Text(messageData['text']),
      subtitle: Text(messageData['from']),
    );
  }

  Future<void> sendMessage(String groupId, String senderId, String text) async {
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

  Future<void> sendExpenseMessage(
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

    // Calculate each user's expense to be paid
    Map<String, double> expensesToBePaid = {};

    for (var userId in groupMembers) {
      expensesToBePaid[userId] = share;
    }

    // Add the overall expense to the messages collection
    DocumentReference expenseDocRef = await messagesRef.add({
      'expense': expenseAmount,
      'userId': senderId,
      'paid': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    String newExpenseId = expenseDocRef.id; // Get the newly created expense ID

// Add the expenses to Firestore for each user with the new expense ID
    for (var entry in expensesToBePaid.entries) {
      String userId = entry.key;
      double amountToPay = entry.value;

      // Reference to the user's document in Firestore
      DocumentReference userExpenseRef = FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
          .collection('users_expenses')
          .doc(userId);

      // Update the user's document with the expense to be paid
      await userExpenseRef.set({
        'expense_id': newExpenseId, // Assign the new expense ID
        'amountToPay': amountToPay,
        'paid': false, // You might want to set this to false initially
        // You can include other necessary fields here
      });
    }

    print('Expenses added successfully');
  }

  // Future<void> sendExpenseMessage(
  //     String groupId, String senderId, String expenseAmount) async {
  //   CollectionReference messagesRef = FirebaseFirestore.instance
  //       .collection('groups')
  //       .doc(groupId)
  //       .collection('messages');

  //   await messagesRef.add({
  //     'expense': expenseAmount,
  //     'userId': senderId,
  //     'paid': false,
  //     'timestamp': FieldValue.serverTimestamp(),
  //   });

  //   // Add logic here to trigger daily reminders for unpaid expenses
  //   // You can use scheduled notifications or cloud functions to handle reminders
  // }
}
