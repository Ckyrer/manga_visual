import 'package:flutter/material.dart';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:provider/provider.dart';

class UsernameInput extends StatelessWidget {
  const UsernameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        label: Text("Name or email")
      ),
      initialValue: context.read<InputerViewModel>().getName,
      onChanged: (value) => {context.read<InputerViewModel>().setName(value)},
    );
  }
}

class PasswordInput extends StatelessWidget {
  const PasswordInput({super.key});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        label: Text("Password")
      ),
      initialValue: context.read<InputerViewModel>().getPassword,
      onChanged: (value) => {context.read<InputerViewModel>().setPassword(value)},
    );
  }
}
