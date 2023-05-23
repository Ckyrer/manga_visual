import 'dart:math';

import 'package:flutter/material.dart';
import 'package:manga_visual/manga_core.dart';
import 'package:manga_visual/views/HomeScreen.dart';
import 'package:provider/provider.dart';

import 'models/InputerViewModel.dart';

void main() async {
  await MangaCore.init();
  (await MangaCore.driver!.window).setRect(const Rectangle(0, 0, 800, 900));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  
  const MyApp({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<InputerViewModel>(
      create: (context) => InputerViewModel(),
      child: MaterialApp(
        title: 'CManga Visual',
        theme: ThemeData(
          primarySwatch: Colors.amber,
        ),
        home: const HomeScreen()
      ),
    );
  }
}
