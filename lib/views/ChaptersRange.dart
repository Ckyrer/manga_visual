import 'package:flutter/material.dart';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:provider/provider.dart';

class ChaptersRange extends StatefulWidget {
  const ChaptersRange({super.key});

  @override
  State<ChaptersRange> createState() => _ChaptersRangeState();
}

class _ChaptersRangeState extends State<ChaptersRange> {
  RangeValues range = const RangeValues(1, 1);

  @override
  Widget build(BuildContext context) {
    return RangeSlider(
      values: range, 
      onChanged: (nRange) => {
        if (!context.read<InputerViewModel>().isDownloading) {
          setState(() => range = nRange),
          context.read<InputerViewModel>().setChaptersRange(nRange)
        }
      },
      min: 1,
      max: context.watch<InputerViewModel>().getMaxChapter.ceil().toDouble(),
      divisions: context.watch<InputerViewModel>().getMaxChapter.ceil(),
      labels: RangeLabels(range.start.ceil().toString(), range.end.ceil().toString()),
    );
  }
}