import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wanderwave/screens/expenses/BuildNSendMsgs.dart';

class GroupChatScreen extends StatefulWidget {
  final String groupId;
  final String userId;

  GroupChatScreen({required this.groupId, required this.userId});

  @override
  _GroupChatScreenState createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  Map<String, bool> checkboxStates = {}; // Store checkbox states by user ID

  bool sendingExpense = false;

  void initState() {
    super.initState();
    //fetch the checkbox states from firebase and store them in the checkboxStates map:
    fetchCheckboxStates();
  }

  Future<void> fetchCheckboxStates() async {
    try {
      // Retrieve user's expenses data from Firestore
      QuerySnapshot userExpensesQuery = await FirebaseFirestore.instance
          .collection('groups')
          .doc(widget.groupId)
          .collection('users_expenses')
          .get();

      if (userExpensesQuery.docs.isNotEmpty) {
        for (var doc in userExpensesQuery.docs) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

          // Assuming the structure directly contains expenses using their IDs
          if (userData != null) {
            // Loop through each expense directly within user's data
            userData.forEach((expenseId, expenseData) {
              bool paid = expenseData['paid'] ?? false;
              // Assuming the document ID is user ID, and expenseId is unique
              checkboxStates[doc.id + "_" + expenseId] = paid;
            });
          }
        }

        print(checkboxStates);
        setState(() {});
      }
    } catch (e) {
      print('Error fetching checkbox states: $e');
    }
  }

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
                    String msg_id = messages[index].id;
                    Map<String, dynamic> messageData =
                        messages[index].data() as Map<String, dynamic>;

                    if (messageData.containsKey('expense')) {
                      // return buildExpenseMessage(messageData);
                      return buildExpenseMessage(
                          messageData, widget.groupId, msg_id);
                    } else {
                      return BuildNSendMsgs.buildGenericMessage(messageData);
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
                      BuildNSendMsgs.sendExpenseMessage(widget.groupId,
                          widget.userId, _messageController.text.trim());
                    } else {
                      BuildNSendMsgs.sendMessage(widget.groupId, widget.userId,
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

  Widget buildExpenseMessage(
      Map<String, dynamic> messageData, String groupId, String msg_id) {
    String currentUserId = widget.userId;
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('groups')
          .doc(groupId)
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

        // Calculate share per member
        int numberOfGroupMembers = groupMembers.length;
        double totalExpenses = double.parse(messageData['expense']);
        double share = totalExpenses / numberOfGroupMembers;

        // Display expenses per member
        return Container(
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: Colors.grey[200],
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: numberOfGroupMembers,
            //itemExtent: 120.0, // Set the height between each ListTile
            itemBuilder: (context, index) {
              String userId = groupMembers[index];
              return ListTile(
                contentPadding: EdgeInsets.all(16.0),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$userId :',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Checkbox(
                      onChanged: (value) async {
                        String expenseId = msg_id;

                        // Check if the current user is the message sender
                        String senderId = messageData['userId'];
                        if (senderId == currentUserId) {
                          // Only allow changes if the current user sent the expense message

                          DocumentReference userExpenseRef = FirebaseFirestore
                              .instance
                              .collection('groups')
                              .doc(groupId)
                              .collection('users_expenses')
                              .doc(userId);

                          DocumentSnapshot userExpenseSnapshot =
                              await userExpenseRef.get();

                          if (userExpenseSnapshot.exists) {
                            Map<String, dynamic> userData = userExpenseSnapshot
                                .data() as Map<String, dynamic>;

                            // Check if the expense exists for the given message ID
                            if (userData.containsKey(expenseId)) {
                              userData[expenseId]['paid'] = value;
                              await userExpenseRef.set(userData);
                              print('Expense status updated for user: $userId');
                              setState(() {
                                // Update the checkbox state for the specific user
                                print(userId + "_" + expenseId);
                                print(userId + "_" + msg_id);
                                checkboxStates[userId + "_" + expenseId] =
                                    value ?? false;
                                print(checkboxStates);
                                //checkboxStates[userId] = value ?? false;
                              });
                            }
                          }
                        } else {
                          // Show error message or dialog indicating the user isn't authorized
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Access Denied'),
                                content: Text('Only message admin can edit.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      value: checkboxStates[userId + "_" + msg_id] ?? false,
                    ),
                  ],
                ),
                subtitle: Text(
                  '${totalExpenses.toStringAsFixed(2)} / $numberOfGroupMembers = ${share.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
