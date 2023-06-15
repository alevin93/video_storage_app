import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'main_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  final TextEditingController passphraseController = TextEditingController();
  String passphrase = "Your Secret Passphrase"; // Replace with actual passphrase retrieval logic

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
  try {
    // Check if we can check biometrics
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    print('Can check biometrics: $canCheckBiometrics');
    if (!canCheckBiometrics) return;

    // Check what biometrics are available
    List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
    print('Available biometrics: $availableBiometrics');
    if (availableBiometrics.isEmpty) return;

    // Try to authenticate
    bool authenticated = await auth.authenticate(
      localizedReason: 'Scan your fingerprint to authenticate'
    );

    print('Authenticated: $authenticated');

    if (!authenticated) return;

    // If we're authenticated, move to the main screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen()),
    );
  } catch (e) {
    print('Authentication failed with exception: $e');
    _showPassphraseDialog();  // Fallback to passphrase when authentication fails
  }
}

void _showPassphraseDialog() {
  // Implement a method to show a dialog where the user can enter their passphrase.
}

  void _unlockWithPassphrase() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Unlock with Passphrase"),
          content: TextField(
            controller: passphraseController,
            obscureText: true,
            decoration: InputDecoration(
              labelText: "Enter Passphrase",
            ),
          ),
          actions: [
            TextButton(
              child: Text("Unlock"),
              onPressed: () {
                if (passphraseController.text == passphrase) {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainScreen()),
                  );
                } else {
                  // Incorrect passphrase, show error or handle as needed
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authenticate'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              child: Text('Unlock with Biometrics'),
              onPressed: _authenticate,
            ),
            ElevatedButton(
              child: Text('Unlock with passphrase'),
              onPressed: _unlockWithPassphrase,
            ),
          ],
        ),
      ),
    );
  }
}