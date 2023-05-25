import 'package:flutter/material.dart';
import 'package:manga_visual/manga_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InputerViewModel with ChangeNotifier {

  String _imageUrl = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
  String _mangaName = "None";
  bool _isReady = false;
  double _maxChapter = 1;
  RangeValues _chaptersRange = const RangeValues(0, 0);
  bool _isDownloading = false;
  bool _isProcessing = false;
  String _username = "";
  String _password = "";
  static String _curPage = "";

  bool get getIsProcessing => _isProcessing;
  bool get getIsDownloading => _isDownloading;
  bool get getIsReady => _isReady;
  String get getImageUrl => _imageUrl;
  double get getMaxChapter => _maxChapter;
  String get getMangaName => _mangaName;
  String get getName => _username;
  String get getPassword => _password;
  String get getCurrentPage => _curPage;

  void loadUserData() async {
    _username = (await SharedPreferences.getInstance()).getString("username")??"";
    _password = (await SharedPreferences.getInstance()).getString("password")??"";
  }

  void setName(String name) async {
    (await SharedPreferences.getInstance()).setString("username", name);
    _username = name;
  }

  void setPassword(String password) async {
    (await SharedPreferences.getInstance()).setString("password", password);
    _password = password;
  }

  void setCurrentPage(String page) {
    _curPage = page;
    notifyListeners();
  }

  void setChaptersRange(RangeValues v) {
    _chaptersRange = v;
  }

  void startDownloading(InputerViewModel i) async {
    _isDownloading = true;
    _isReady = false;
    notifyListeners();

    bool s = await MangaCore.selectChapter(_chaptersRange.start.ceil().toString());

    if (s) {
      await MangaCore.downloadChapters(i, _mangaName, _chaptersRange.end+1, 758, 1024);
      _curPage = "Загрузка завершена!";
    } else {
      _curPage = "Ошибка! Неверный логин или пароль";
      _isReady = true;
    }

    _isDownloading = false;
    notifyListeners();
  }

  void setMangaURL(String url) async {
    if (url.startsWith("https://mangalib.me/")) {
      _isProcessing = true;
      notifyListeners();
      List res = await MangaCore.getManga(url.replaceFirst("?section=info", "?section=chapters"));
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