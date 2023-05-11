import 'package:flutter/material.dart';
import 'package:manga_visual/manga_core.dart';
import 'package:manga_visual/views/Cover.dart';
import 'package:manga_visual/views/URLInput.dart';
import 'package:provider/provider.dart';
import 'package:webdriver/async_core.dart';

import 'models/InputerViewModel.dart';

void main() async {
  final WebDriver browser = await startDriver();
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
                    context.read<InputerViewModel>().changeImageUrl()
                  },
                  child: const Text("Найти")
                ),
                const Cover(),
                RangeSlider(
                  values: context.read<InputerViewModel>().getChaptersRange,
                  max: context.read<InputerViewModel>().getMaxChapter,
                  divisions: context.read<InputerViewModel>().getMaxChapter.round(),
                  onChanged: (v) => {context.read<InputerViewModel>().setChaptersRange(v)}
                )
              ],
            )
          ),
        ),
      );
  }
}
