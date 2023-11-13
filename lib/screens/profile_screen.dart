import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wanderwave/services/firebase_auth_methods.dart';
import 'package:wanderwave/widgets/auth_icon_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<FirebaseAuthMethods>().user;

    void onSignOut() {
      context.read<FirebaseAuthMethods>().signOut(context);
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Profile Screen'),
          const SizedBox(height: 20),
          Text(user.email!),
          const SizedBox(height: 20),
          //Text(user.displayName!),
          const SizedBox(height: 20),
          Text(user.uid),
          const SizedBox(height: 20),
          AuthIconButton(
            labelText: 'Sign Out',
            isSvg: false,
            onPress: onSignOut,
            icon: Icons.sign_language,
          )
        ],
      ),
    );
  }
}
