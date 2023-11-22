import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderwave/screens/expenses_screen.dart';
import 'package:wanderwave/screens/profile/edit_profile_screen.dart';
import 'package:wanderwave/services/firebase_auth_methods.dart';
import 'package:wanderwave/widgets/auth_icon_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void onSignOut() {
    context.read<FirebaseAuthMethods>().signOut(context);
  }

  void goToExpenses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpensesScreen(),
      ),
    );
  }

  Map<String, dynamic> userData = {};

  Future<bool> profileCheck(User user) async {
    bool ans = await context.read<FirebaseAuthMethods>().checkProfile();

    if (ans) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get()
          .then(
        (value) {
          userData = value.data()!;
        },
      );
    }
    return ans;
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    return FutureBuilder<bool>(
      future: profileCheck(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError || snapshot.data == false) {
          return Center(
            child: AuthIconButton(
              labelText: 'Add Profile',
              isSvg: false,
              onPress: () async {
                final updatedData = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const EditProfileScreen(
                      userData: {},
                    ),
                  ),
                );

                if (updatedData != null) {
                  setState(() {
                    userData = updatedData;
                  });
                }
              },
              icon: Icons.add,
            ),
          );
        }

        return Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xff234243),
                      backgroundImage: NetworkImage(
                        userData["ImageURL"],
                        scale: 1,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          final updatedData = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(
                                userData: {...userData},
                              ),
                            ),
                          );

                          if (updatedData != null) {
                            setState(() {
                              userData = updatedData;
                            });
                          }
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.yellow,
                          ),
                          child: const Icon(Icons.edit),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  userData['Name'] ?? 'Name not available',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                  ),
                ),
                Text(
                  userData['Email'] ?? 'Email not available',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    userData['About'] ?? 'About not available',
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 50),
                const Text(
                  'Manage',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 35,
                  ),
                ),
                const SizedBox(height: 20),
                AuthIconButton(
                  labelText: 'My Groups',
                  isSvg: false,
                  onPress: () {},
                  icon: Icons.sign_language,
                ),
                const SizedBox(height: 20),
                AuthIconButton(
                  labelText: 'Expenses Page',
                  isSvg: false,
                  onPress: goToExpenses,
                  icon: Icons.money_rounded,
                ),
                const SizedBox(height: 20),
                AuthIconButton(
                  labelText: 'Sign Out',
                  isSvg: false,
                  onPress: onSignOut,
                  icon: Icons.sign_language,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
