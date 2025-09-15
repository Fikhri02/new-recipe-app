import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ProfileWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>();

    if (!user.isLoggedIn) {
      return Text("Not logged in");
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("Logout ${user.name}?"),
        const SizedBox(height: 10),
        ElevatedButton.icon(
          onPressed: () async {
            await user.logout();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Logged out")),
            );
          },
          icon: Icon(Icons.logout, color: Colors.white),
          label: Text("Logout"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
        ),
      ],
    );
  }
}
