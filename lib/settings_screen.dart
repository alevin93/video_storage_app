import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Notifications'),
            subtitle: Text('Manage notification settings'),
            leading: Icon(Icons.notifications),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // Implement your logic to navigate to the notifications settings screen
            },
          ),
          ListTile(
            title: Text('Privacy'),
            subtitle: Text('Manage privacy settings'),
            leading: Icon(Icons.privacy_tip),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // Implement your logic to navigate to the privacy settings screen
            },
          ),
          ListTile(
            title: Text('Account'),
            subtitle: Text('Manage your account settings'),
            leading: Icon(Icons.account_circle),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // Implement your logic to navigate to the account settings screen
            },
          ),
          ListTile(
            title: Text('About'),
            subtitle: Text('Learn more about the app'),
            leading: Icon(Icons.info),
            trailing: Icon(Icons.keyboard_arrow_right),
            onTap: () {
              // Implement your logic to navigate to the about screen
            },
          ),
        ],
      ),
    );
  }
}
