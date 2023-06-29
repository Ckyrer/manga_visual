import 'package:flutter/material.dart';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:manga_visual/views/widgets/Cover.dart';
import 'package:manga_visual/views/widgets/FirstChapterChoose.dart';
import 'package:manga_visual/views/widgets/LastChapterChoose.dart';
import 'package:manga_visual/views/widgets/URLInput.dart';
import 'package:provider/provider.dart';

import 'LoginScreen.dart';

class MangaScreen extends StatelessWidget {
  const MangaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(children: [
      ElevatedButton(onPressed: () => {context.read<InputerViewModel>().quit()}, child: const Text("Выйти")),
      ElevatedButton(onPressed: () => {Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()))}, child: const Text("Настройки аккаунта")),
      const SizedBox(height: 10),
      const SizedBox(height: 10),
      const URLInput(),
      const SizedBox(height: 10),
      Text(context.watch<InputerViewModel>().getTitleName),
      const Cover(),
      const FirstChapterChoose(),
      const LastChapterChoose(),
      Text(context.watch<InputerViewModel>().getCurrentPage),
      ElevatedButton(
          onPressed: context.watch<InputerViewModel>().getIsReady ? () => {context.read<InputerViewModel>().startDownloading(context.read<InputerViewModel>())} : null, child: const Text("Скачать"))
    ])));
  }
}
