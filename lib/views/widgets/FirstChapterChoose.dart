import 'package:flutter/material.dart';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:provider/provider.dart';

class FirstChapterChoose extends StatefulWidget {
  const FirstChapterChoose({super.key});

  @override
  State<FirstChapterChoose> createState() => _FirstChapterChooseState();
}

class _FirstChapterChooseState extends State<FirstChapterChoose> {
  int _value = 0;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<int>(
      items: context.watch<InputerViewModel>().getChaptersList,
      value: _value,
      onChanged: (context.watch<InputerViewModel>().getIsProcessing || context.watch<InputerViewModel>().getIsDownloading) ? null : callback,
    );
  }

  void callback(int? val) {
    if (val is int) {
      context.read<InputerViewModel>().setFirstChapter(val);
      setState(() {
        _value = val;
      });
    }
  }
}
