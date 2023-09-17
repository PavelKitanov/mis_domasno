import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/authentication.dart';
import 'map_page.dart';

class ChangeCredentialsPage extends StatefulWidget {
  const ChangeCredentialsPage({Key? key}) : super(key: key);

  @override
  State<ChangeCredentialsPage> createState() => _ChangeCredentialsPageState();
}

class _ChangeCredentialsPageState extends State<ChangeCredentialsPage> {
  String? errorMessage = '';
  bool success = false;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();

  Widget _title() {
    return const Text('Change credentials');
  }

  Widget _entryField(
    String title,
    TextEditingController controller,
    bool isPassword,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Color(0xFFFF6B6B),
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            labelText: title,
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(12.0),
          ),
        ),
      ),
    );
  }

  Widget _errorMessage() {
    return Text(errorMessage == '' ? '' : 'Humm ? $errorMessage');
  }

  Future<void> changeCredentials() async {
    try {
      await Auth().updateCurrentUser(
        email: _controllerEmail.text.trim(),
        password: _controllerPassword.text,
      );

      success = true;
      _controllerEmail.text = '';
      _controllerPassword.text = '';

      setState(() {});
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _submitButton() {
    return ElevatedButton(
      onPressed: changeCredentials,
      child: Text("Change"),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color customPrimaryColor = Color(0xFFFF6B6B);
    Color customCardColor = Color.fromARGB(255, 245, 224, 208);

    final makeBottom = Container(
      height: 55.0,
      child: BottomAppBar(
        color: customPrimaryColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            IconButton(
              icon: Icon(Icons.map, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => MapPage(),
                ));
              },
            ),
            IconButton(
              icon: Icon(Icons.account_box, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                Navigator.of(context).pop();
                Auth().signOut();
              },
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: _title(),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _entryField('New Email Address', _controllerEmail, false),
            _entryField('New Password', _controllerPassword, true),
            _errorMessage(),
            _submitButton(),
            success
                ? Text("Successfuly changed",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green))
                : Text("")
          ],
        ),
      ),
      bottomNavigationBar: makeBottom,
    );
  }
}
