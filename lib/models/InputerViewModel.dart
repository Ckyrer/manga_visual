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
  String _MANGA_URL = "";
  String _MANGA_NAME = "None";
  bool _IS_READY = false;
  double _MAX_CHAPTER = 1;
  RangeValues _CHAPTERS_RANGE = RangeValues(0, 0);
  bool _IS_DOWNLOADING = false;
  bool _IS_PROCESSING = false;


  bool get getIsProcessing => _IS_PROCESSING;
  bool get getIsDownloading => _IS_DOWNLOADING;
  bool get getIsReady => _IS_READY;
  String get getImageUrl => _IMAGE_URL;
  double get getMaxChapter => _MAX_CHAPTER;
  String get getMangaName => _MANGA_NAME;

  void setChaptersRange(RangeValues v) {
    _CHAPTERS_RANGE = v;
  }

  void startDownloading() async {
    _IS_DOWNLOADING = true;
    _IS_READY = false;
    notifyListeners();

    await selectChapter(browser, _CHAPTERS_RANGE.start.ceil().toString());

    await downloadChapters(browser, _MANGA_NAME, _CHAPTERS_RANGE.end+1, 758, 1024);

    _IS_DOWNLOADING = false;
    notifyListeners();
  }

  void setMangaURL(String url) async {
    if (url.startsWith("https://mangalib.me/") && url.endsWith("?section=chapters")) {
      _IS_PROCESSING = true;
      notifyListeners();
      List res = await getManga(browser, url);
      _IS_PROCESSING = false;
      if (res[0]) {
        _IS_READY = true;
        _MANGA_NAME = res[1];
        _IMAGE_URL = res[3];
        _MAX_CHAPTER = res[4];
      } else {
        _IS_READY = false;
        _MANGA_NAME = "None";
        _IMAGE_URL = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
      }
    } else {
      _IS_READY = false;
      _MANGA_NAME = "None";
      _IMAGE_URL = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
    }
    notifyListeners();
  }
}