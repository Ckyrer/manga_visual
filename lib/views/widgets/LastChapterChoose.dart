import 'package:flutter/material.dart';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:provider/provider.dart';

class LastChapterChoose extends StatefulWidget {
  const LastChapterChoose({super.key});

  @override
  State<LastChapterChoose> createState() => _LastChapterChooseState();
}

class _LastChapterChooseState extends State<LastChapterChoose> {
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
      context.read<InputerViewModel>().setLastChapter(val);
      setState(() {
        _value = val;
      });
    }
  }
}
