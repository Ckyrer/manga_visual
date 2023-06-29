import 'dart:io';

import 'package:flutter/material.dart';
import 'package:manga_visual/manga_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../ranobe_core.dart';
import '../webdriver_core.dart';

class InputerViewModel with ChangeNotifier {
  String _imageUrl = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
  String _titleName = "None";
  int _mode = -1;

  String _firstChapter = "";
  String _lastChapter = "";
  final List<DropdownMenuItem<int>> _chaptersList = [];

  bool _isReady = false;
  bool _isDownloading = false;
  bool _isProcessing = false;

  String _username = "";
  String _password = "";

  static String _curPage = "";

  bool get getIsProcessing => _isProcessing;
  bool get getIsDownloading => _isDownloading;
  bool get getIsReady => _isReady;
  String get getImageUrl => _imageUrl;
  String get getTitleName => _titleName;
  String get getName => _username;
  String get getPassword => _password;
  String get getCurrentPage => _curPage;
  List<DropdownMenuItem<int>> get getChaptersList => _chaptersList;

  void quit() {
    WDC.exit();
    exit(0);
  }

  void loadUserData() async {
    _username = (await SharedPreferences.getInstance()).getString("username") ?? "";
    _password = (await SharedPreferences.getInstance()).getString("password") ?? "";
  }

  void setName(String name) async {
    (await SharedPreferences.getInstance()).setString("username", name);
  }

  void setPassword(String password) async {
    (await SharedPreferences.getInstance()).setString("password", password);
  }

  void setCurrentPage(String page) {
    _curPage = page;
    notifyListeners();
  }

  void setFirstChapter(int c) {
    final child = _chaptersList[c].child.toString();
    _firstChapter = child.substring(6, child.length - 2);
  }

  void setLastChapter(int c) {
    final child = _chaptersList[c].child.toString();
    _lastChapter = child.substring(6, child.length - 2);
  }

  void startDownloading(InputerViewModel i) async {
    _isDownloading = true;
    _isReady = false;
    notifyListeners();

    if (_mode == 0) {
      await MangaCore.selectChapter(_firstChapter);
    } else {
      await RanobeCore.selectChapter(_firstChapter);
    }

    if (_mode == 0) {
      await MangaCore.downloadChapters(i, _titleName, _lastChapter, 758, 1024);
    } else {
      await RanobeCore.downloadChapters(i, _titleName, _lastChapter, 758, 1024, _titleName, _imageUrl);
    }

    _curPage = "Загрузка завершена!";

    _isReady = true;
    _isDownloading = false;
    notifyListeners();
  }

  void setMangaURL(String url) async {
    if (url.startsWith("https://mangalib.me/") || url.startsWith("https://ranobelib.me/")) {
      _isProcessing = true;
      notifyListeners();
      List res;
      if (url.startsWith("https://mangalib.me/")) {
        _mode = 0;
        res = await MangaCore.getManga(url.replaceFirst("?section=info", "?section=chapters"));
      } else {
        _mode = 1;
        res = await RanobeCore.getRanobe(url.replaceFirst("?section=info", "?section=chapters"));
      }
      _isProcessing = false;
      if (res[0] == 1) {
        _isReady = true;
        _titleName = res[1];
        _imageUrl = res[3];

        _chaptersList.clear();
        res[4].asMap().forEach((i, v) => {_chaptersList.add(DropdownMenuItem(value: i, child: Text(v)))});
      } else {
        _titleName = "None";
        _imageUrl = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
        _chaptersList.clear();
        _isReady = false;
        if (res[0] == -1) {
          _curPage = "Неверный логин или пароль";
          print("Неверный логин или пароль!");
        }
      }
    } else {
      _chaptersList.clear();
      _isReady = false;
      _titleName = "None";
      _imageUrl = "https://i1.sndcdn.com/artworks-000003529677-qxmjmi-t500x500.jpg";
    }
    notifyListeners();
  }
}
