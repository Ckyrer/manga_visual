import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:manga_visual/manga_core.dart';
import 'package:webdriver/async_core.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class InputerViewModel with ChangeNotifier {

  InputerViewModel({
    required this.browser
  });

  final WebDriver browser;

  String _IMAGE_URL = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
  String _NOT_SURE_URL = "";
  String _MANGA_NAME = "None";
  bool _IS_READY = false;
  double _MAX_CHAPTER = 1;
  RangeValues _CHAPTERS_RANGE = RangeValues(0, 0);
  bool _IS_DOWNLOADING = false;

  bool _processing = false;

  String get getImageUrl => _IMAGE_URL;
  double get getMaxChapter => _MAX_CHAPTER;
  String get getMangaName => _MANGA_NAME;
  bool get isDownloading => _IS_DOWNLOADING;

  void setNotSureURL(String url) {
    _NOT_SURE_URL = url;
    _IS_READY = false;
  }

  void setChaptersRange(RangeValues v) {
    _CHAPTERS_RANGE = v;
  }

  void startDownloading() async {
    _IS_DOWNLOADING = true;

    await selectChapter(browser, _CHAPTERS_RANGE.start.ceil().toString());
    final pw.Document pdfFile = pw.Document(author: 'Kvdl', title: _MANGA_NAME);

    downloadChapters(browser, pdfFile, _CHAPTERS_RANGE.end, 758, 1024);

    final file = File('$_MANGA_NAME.pdf');
    await file.writeAsBytes(await pdfFile.save());

    _IS_DOWNLOADING = false;
  }

  void changeImageUrl() async {
    if (!_processing) {
      _processing = true;
      List res = await getManga(browser, _NOT_SURE_URL);
      if (res[0]) {
        _IS_READY = true;
        _MANGA_NAME = res[1];
        _IMAGE_URL = res[3];
        _MAX_CHAPTER = res[4];
      } else {
        _MANGA_NAME = "None";
        _IMAGE_URL = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
      }

      notifyListeners();
      _processing = false;
    }
  }
}