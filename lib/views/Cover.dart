import 'package:flutter/cupertino.dart';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:provider/provider.dart';

class Cover extends StatelessWidget {
  const Cover({super.key});

  @override
  Widget build(BuildContext context) {
    return Image(
      image: NetworkImage(context.watch<InputerViewModel>().getImageUrl),
      height: 300,
    );
  }
}