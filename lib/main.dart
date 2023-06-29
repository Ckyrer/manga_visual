import 'package:flutter/material.dart';
import 'package:manga_visual/views/MangaScreen.dart';
import 'package:manga_visual/webdriver_core.dart';
import 'package:provider/provider.dart';

import 'models/InputerViewModel.dart';

void main() async {
  await WDC.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InputerViewModel>(
      create: (context) => InputerViewModel(),
      child: MaterialApp(
          title: 'CManga Visual',
          theme: ThemeData(
            primarySwatch: Colors.amber,
          ),
          home: const MangaScreen()),
    );
  }
}
