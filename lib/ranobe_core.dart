import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:manga_visual/webdriver_core.dart';
import 'package:webdriver/async_io.dart';

class RanobeCore {
  static Future<List> getRanobe(String url) async {
    try {
      await WDC.driver.get(url);
      if (await WDC.driver.title == 'Страница не найдена 404') {
        return [0];
      } else {
        // Если есть выбор переводов
        final WebElement? list = await WDC.isElementExist(null, const By.className("media-chapters-teams"));
        if (list != null) {
          // То выбераем первый (потом сделаю выбор пользователя)
          await (await list.findElement(const By.className("team-list-item"))).click();
        }
        return [
          1,
          await (await WDC.driver.findElement(const By.className('media-name__main'))).text, // Название
          await (await WDC.driver.findElement(const By.className('media-name__alt'))).text, // Альт. название.
          await (await WDC.driver.findElement(const By.cssSelector('.media-sidebar__cover > img'))).attributes['src'], // Обложка
          await await _getChapters()
        ];
      }
    } catch (e) {
      print(e);
      return [0];
    }
  }

  static Future<List<String>> _getChapters() async {
    final WebElement container = await WDC.driver.findElement(const By.className("vue-recycle-scroller__item-wrapper"));
    final WebElement body = await WDC.driver.findElement(const By.tagName("body"));

    final Set<String> res = {};
    int height = int.parse((await body.properties['scrollHeight'])!);

    while (height > 0) {
      await for (final element in container.findElements(const By.className("media-chapter__name"))) {
        final String c = await element.text;
        if (c != "") {
          res.add(c);
        }
      }
      WDC.driver.execute('scrollTo(0, scrollY+2600)', []);
      height -= 2600;
    }

    return res.toList();
  }

  static Future<void> selectChapter(String chapter) async {
    final WebElement container = await WDC.driver.findElement(const By.className("vue-recycle-scroller__item-wrapper"));
    final WebElement body = await WDC.driver.findElement(const By.tagName("body"));

    int height = int.parse((await body.properties['scrollHeight'])!);

    while (height > 0) {
      await for (final element in container.findElements(const By.className("media-chapter__name"))) {
        if ((await element.text) == chapter) {
          await (await element.findElement(const By.tagName("a"))).click();
          return;
        }
      }
      WDC.driver.execute('scrollTo(0, scrollY+1200)', []);
      height -= 1200;
    }
    print("Ошибка! При выборе главы");
  }

  static Future<Uint8List> _downloadImage(String url) async {
    return (await http.get(Uri.parse(url))).bodyBytes;
  }

  static String _createSample(String name) {
    final DateTime n = DateTime.now();
    final String date = "${n.day}.${n.month}.${n.year}";
    final String id = "${n.day}${n.month}${n.year}${n.hour}${n.minute}${n.second}";
    return '<?xml version="1.0" encoding="utf-8"?> <fictionbook xmlns="http://www.gribuser.ru/xml/fictionbook/2.0" xmlns:l="http://www.w3.org/1999/xlink"><description><title-info></genre>жанр</genre><author><nickname>Mangalib/Ranobelib</nickname></author><book-title>$name</book-title><coverpage><image l:href="#cover.png"></coverpage><lang>ru</lang></title-info><document-info><author>Kvdl</author><program-used>Manga visual</program-used><date>$date</date><id>$id</id><version>1.0</version></document-info></description><body>';
  }

  static Future<void> downloadChapters(InputerViewModel inp, String title, String last, int width, int height, String name, String coverUrl) async {
    // Запоминаем ссылку на главную страницу манги
    final String homePage = (await (await WDC.driver.findElement(const By.className("reader-header-action.reader-header-action_full"))).attributes["href"])!;

    // Создание fb2 документа
    int binaryCount = 0;
    // ignore: non_constant_identifier_names
    String CHAPTERS_CONTENT = _createSample(name);
    // ignore: non_constant_identifier_names
    String BINARY_CONTENT = '<binary id="cover.png" content-type="image/png">${base64.encode(await _downloadImage(coverUrl))}</binary>';

    // Главный цикл
    bool run = true;
    while (run) {
      // Проверка на то, что всё еще не дочитали всю мангу
      if ((await WDC.driver.currentUrl).endsWith("?section=info")) {
        break;
      }

      // Получение названия текущей главы
      final String label = await (await (WDC.driver.findElements(const By.className('reader-header-action__title.text-truncate'))).toList())[1].text;

      // Проверка на то, что глава еще находится в нужном диапозоне
      if (last.startsWith(label)) {
        run = false;
      }

      // Обновление счётчика
      inp.setCurrentPage(label);

      // Оформление
      // Создание главы
      CHAPTERS_CONTENT += "<section>";

      await for (WebElement tag in WDC.driver.findElements(const By.cssSelector(".reader-container > *"))) {
        switch (await tag.name) {
          case "p":
            CHAPTERS_CONTENT += "<p>${await tag.text}</p>";
            break;
          case "div":
            final String imgUrl = (await (await tag.findElement(const By.tagName("img"))).properties["src"])!;
            CHAPTERS_CONTENT += '<p><img l:href="#${binaryCount.toString()}.png"></p>';
            BINARY_CONTENT += '<binary id="${binaryCount.toString()}.png" content-type="image/png">${base64.encode(await _downloadImage(imgUrl))}</binary>';
            binaryCount += 1;
            break;
        }
      }

      // Следующая глава
      WDC.driver.keyboard.sendKeys(Keyboard.right);
    }

    final file = File('$title.pdf');
    await file.writeAsBytes(utf8.encode("$CHAPTERS_CONTENT</body>$BINARY_CONTENT</FictionBook>"));

    WDC.driver.get(homePage);
  }
}
