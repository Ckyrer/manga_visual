import 'package:flutter/material.dart';
import 'package:manga_visual/manga_core.dart';

class InputerViewModel with ChangeNotifier {

  String _imageUrl = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
  String _mangaName = "None";
  bool _isReady = false;
  double _maxChapter = 1;
  RangeValues _chaptersRange = const RangeValues(0, 0);
  bool _isDownloading = false;
  bool _isProcessing = false;


  bool get getIsProcessing => _isProcessing;
  bool get getIsDownloading => _isDownloading;
  bool get getIsReady => _isReady;
  String get getImageUrl => _imageUrl;
  double get getMaxChapter => _maxChapter;
  String get getMangaName => _mangaName;

  void setChaptersRange(RangeValues v) {
    _chaptersRange = v;
  }

  void startDownloading() async {
    _isDownloading = true;
    _isReady = false;
    notifyListeners();

    bool s = await MangaCore.selectChapter(_chaptersRange.start.ceil().toString());

    if (s) {
      await MangaCore.downloadChapters(_mangaName, _chaptersRange.end+1, 758, 1024);
    } else {
      
    }

    _isDownloading = false;
    notifyListeners();
  }

  void setMangaURL(String url) async {
    if (url.startsWith("https://mangalib.me/") && url.endsWith("?section=chapters")) {
      _isProcessing = true;
      notifyListeners();
      List res = await MangaCore.getManga(url);
      _isProcessing = false;
      if (res[0]) {
        _isReady = true;
        _mangaName = res[1];
        _imageUrl = res[3];
        _maxChapter = res[4];
      } else {
        _isReady = false;
        _mangaName = "None";
        _imageUrl = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
      }
    } else {
      _isReady = false;
      _mangaName = "None";
      _imageUrl = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
    }
    notifyListeners();
  }
}