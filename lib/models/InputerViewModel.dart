import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manga_visual/manga_core.dart';
import 'package:webdriver/async_core.dart';

class InputerViewModel with ChangeNotifier {

  InputerViewModel({
    required this.browser
  });

  final WebDriver browser;

  String _IMAGE_URL = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
  String _NOT_SURE_URL = "";
  bool _IS_READY = false;
  double _MAX_CHAPTER = 1;
  RangeValues _CHAPTERS_RANGE = RangeValues(0, 0);

  bool _processing = false;

  RangeValues get getChaptersRange => _CHAPTERS_RANGE;
  String get getImageUrl => _IMAGE_URL;
  double get getMaxChapter => _MAX_CHAPTER;

  void setNotSureURL(String url) {
    _NOT_SURE_URL = url;
    _IS_READY = false;
  }

  void setChaptersRange(RangeValues v) {
    _CHAPTERS_RANGE = v;
  }

  void changeImageUrl() async {
    if (!_processing) {
      _processing = true;
      List res = await getManga(browser, _NOT_SURE_URL);
      if (res[0]) {
        _IMAGE_URL = res[3];
        _MAX_CHAPTER = res[4];
      } else {
        _IMAGE_URL = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
      }

      notifyListeners();
      _processing = false;
    }
  }
}