import 'package:flutter/material.dart';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:provider/provider.dart';

class URLInput extends StatelessWidget {
  const URLInput({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (value) => {
        context.read<InputerViewModel>().setMangaURL(value)
      },
      enabled: (!context.watch<InputerViewModel>().getIsDownloading && !context.watch<InputerViewModel>().getIsProcessing),
    );
  }
}
