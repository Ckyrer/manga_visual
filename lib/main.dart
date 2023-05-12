import 'dart:math';

import 'package:flutter/material.dart';
import 'package:manga_visual/manga_core.dart';
import 'package:manga_visual/views/ChaptersRange.dart';
import 'package:manga_visual/views/Cover.dart';
import 'package:manga_visual/views/URLInput.dart';
import 'package:provider/provider.dart';
import 'package:webdriver/async_core.dart';

import 'models/InputerViewModel.dart';

void main() async {
  final WebDriver browser = await startDriver();
  (await browser.window).setRect(const Rectangle(0, 0, 800, 900));
  runApp(MyApp(browser: browser));
}

class MyApp extends StatelessWidget {
  final WebDriver browser; 
  
  const MyApp({
    super.key,
    required this.browser
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InputerViewModel>(
      create: (context) => InputerViewModel(browser: browser),
      child: MaterialApp(
        title: 'CManga Visual',
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: const HomeWidget()
      ),
    );
  }
}

class HomeWidget extends StatelessWidget{
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              children: [
                const URLInput(),
                ElevatedButton(
                  onPressed: () => {
                    if (!context.read<InputerViewModel>().isDownloading) {
                      context.read<InputerViewModel>().changeImageUrl()
                    }
                  },
                  child: const Text("Найти")
                ),
                Text(context.watch<InputerViewModel>().getMangaName),
                const Cover(),
                const ChaptersRange(),
                ElevatedButton(
                  onPressed: () => {
                    if (!context.read<InputerViewModel>().isDownloading) {
                      context.read<InputerViewModel>().startDownloading()
                    }
                  },
                  child: const Text("Скачать")
                )
              ],
            )
          ),
        ),
      );
  }
}
