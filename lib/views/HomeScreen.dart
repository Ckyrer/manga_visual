import 'package:flutter/material.dart';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:manga_visual/views/widgets/ChaptersRange.dart';
import 'package:manga_visual/views/widgets/Cover.dart';
import 'package:manga_visual/views/widgets/URLInput.dart';
import 'package:provider/provider.dart';


class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const URLInput(),
                Text(context.watch<InputerViewModel>().getMangaName),
                const Cover(),
                const ChaptersRange(),
                ElevatedButton(
                  onPressed: context.watch<InputerViewModel>().getIsReady
                  ? () => {
                    context.read<InputerViewModel>().startDownloading()
                  }
                  : null,
                  child: const Text("Скачать")
                )
              ],
            )
          ),
        ),
      );
  }
}