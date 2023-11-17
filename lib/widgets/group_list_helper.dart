import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderwave/services/firebase_auth_methods.dart';
import 'package:wanderwave/widgets/chat_screen.dart';

class GroupListWidget extends StatelessWidget {
  final List<DocumentSnapshot>? groups;
  final VoidCallback onJoinPressed;

  const GroupListWidget({
    Key? key,
    this.groups,
    required this.onJoinPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (groups == null || groups!.isEmpty) {
      return Center(child: Text('No groups yet.'));
    } else {
      return ListView.builder(
        physics: NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: groups!.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> groupData =
              groups![index].data()! as Map<String, dynamic>;

          String groupName = groupData['group_name'] ?? 'Unknown';
          String groupId = groups![index].id;

          return GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GroupChatScreen(
                    groupId: groupId,
                    userId: context.read<FirebaseAuthMethods>().user.uid,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(10), // Adjust the value for roundness
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.17),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3), // changes the shadow direction
                  ),
                ],
              ),
              child: ListTile(
                title: Text(groupName),
                subtitle: Text('Group ID: $groupId'),
              ),
            ),
          );
        },
      );
    }
  }
}
