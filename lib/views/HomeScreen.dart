import 'package:flutter/material.dart';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:manga_visual/views/widgets/ChaptersRange.dart';
import 'package:manga_visual/views/widgets/Cover.dart';
import 'package:manga_visual/views/widgets/URLInput.dart';
import 'package:provider/provider.dart';

import 'LoginScreen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(children: [
      ElevatedButton(onPressed: () => {context.read<InputerViewModel>().quit()}, child: const Text("Выйти")),
      const SizedBox(height: 10),
      ElevatedButton(
          onPressed: !context.watch<InputerViewModel>().getIsDownloading
              ? () => {context.read<InputerViewModel>().loadUserData(), Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()))}
              : null,
          child: const Text("Поменять логин и пароль")),
      const SizedBox(height: 10),
      const URLInput(),
      const SizedBox(height: 10),
      Text(context.watch<InputerViewModel>().getMangaName),
      const Cover(),
      const ChaptersRange(),
      Text(context.watch<InputerViewModel>().getCurrentPage),
      ElevatedButton(
          onPressed: context.watch<InputerViewModel>().getIsReady ? () => {context.read<InputerViewModel>().startDownloading(context.read<InputerViewModel>())} : null, child: const Text("Скачать"))
    ])));
  }
}
