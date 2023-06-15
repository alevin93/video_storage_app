import 'package:flutter/material.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Sign In'),
              onPressed: () {
                print('Sign In Pressed');
                // Implement sign in functionality
              },
            ),
            ElevatedButton(
              child: Text('Use Offline'),
              onPressed: () {
                print('Use Offline Pressed');
                // Implement offline usage functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}