import 'package:flutter/material.dart';
import 'package:manga_visual/views/widgets/LoginInputs.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            ElevatedButton(onPressed: () => {Navigator.pop(context)}, child: const Text("Назад")),
            const SizedBox(height:25),
            const UsernameInput(),
            const SizedBox(height:25),
            const PasswordInput()
          ],
        )
      ),
    );
  }
}