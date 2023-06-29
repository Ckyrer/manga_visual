import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:manga_visual/webdriver_core.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdriver/async_io.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;

class MangaCore {
  // Найти мангу
  static Future<List> getManga(String url) async {
    try {
      await WDC.driver.get(url);
      if (await WDC.driver.title == 'Страница не найдена 404') {
        return [0];
      } else {
        // Проверка на возрастное ограничение
        if (await WDC.isElementExist(null, const By.id("title-caution")) != null) {
          print("Возрастное ограничение! Вход в аккаунт...");

          final SharedPreferences prefs = await SharedPreferences.getInstance();

          if (!(await _login(prefs.getString("username") ?? "", prefs.getString("password") ?? ""))) {
            print("Неверный логин или пароль!");
            return [-1];
          }
        } else {
          print("Нет ограничений");
        }

        return [
          1,
          await (await WDC.driver.findElement(const By.className('media-name__main'))).text, // Название
          await (await WDC.driver.findElement(const By.className('media-name__alt'))).text, // Альт. название.
          await (await WDC.driver.findElement(const By.cssSelector('.media-sidebar__cover > img'))).attributes['src'], // Обложка
          await _getChapters()
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
    WDC.driver.execute('scrollTo(0, 0)', []);

    return res.toList();
  }

  // Поиск нужной главы
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

  // Скачивание глав
  static Future<void> downloadChapters(InputerViewModel inp, String title, String last, int width, int height) async {
    // Запоминаем ссылку на главную страницу манги
    final String homePage = (await (await WDC.driver.findElement(const By.className("reader-header-action.reader-header-action_full"))).attributes["href"])!;

    // Создание PDF документа (Для манги)
    final pw.Document doc = pw.Document(author: 'Mangalib', title: title);

    // Главный цикл
    bool run = true;
    while (run) {
      // Проверка на то, что мы всё еще не дочитали всю мангу
      if ((await WDC.driver.currentUrl).endsWith("?section=info")) {
        break;
      }

      // Получение названия текущей главы
      String label = await (await (WDC.driver.findElements(const By.className('reader-header-action__title.text-truncate'))).toList())[1].text;

      // Проверка на то, что глава еще находится в нужном диапозоне
      if (last.startsWith(label)) {
        run = false;
      }
      // Ещё одна сложная строка
      final int pagesAmount = int.parse((await (await WDC.driver.findElement(const By.className('button.reader-pages__label.reader-footer__btn'))).text).split(' ')[2]);

      int currentPage = 1;
      while (currentPage <= pagesAmount) {
        // Обновление счётчика
        inp.setCurrentPage("$label $currentPage/$pagesAmount");

        // Получение ссылки на изображение
        final WebElement conatiner = await WDC.driver.findElement(const By.className('reader-view__container'));
        String imgUrl = "";

        int count = 0;
        await for (final WebElement img in conatiner.findElements(const By.tagName('img'))) {
          if (count == currentPage - 1) {
            imgUrl = (await img.properties['src'])!;
            break;
          }
        }

        await _addPageToPDF(doc, await _downloadImage(imgUrl), width.toDouble(), height.toDouble());
        WDC.driver.keyboard.sendKeys(Keyboard.right);
        currentPage += 1;
      }
    }
    final file = File('$title.pdf');
    await file.writeAsBytes(await doc.save());

    WDC.driver.get(homePage);
  }

  // Вход в аккаунт
  static Future<bool> _login(String? name, String? password) async {
    if (name == null || password == null) {
      return false;
    }

    WebElement frame = await WDC.driver.findElement(const By.id("title-caution"));
    await (await frame.findElement(const By.className("button_block"))).click();

    await (await WDC.driver.findElement(const By.name("email"))).sendKeys(name);
    await (await WDC.driver.findElement(const By.name("password"))).sendKeys(password);
    await (await WDC.driver.findElement(const By.className("control__indicator"))).click();
    await (await WDC.driver.findElement(const By.className("button"))).click();

    if (await WDC.driver.title == 'Авторизация') {
      await WDC.driver.back();
      await WDC.driver.back();
      return false;
    }
    return true;
  }

  // Скачивание изображения
  static Future<Uint8List> _downloadImage(String url) async {
    return (await http.get(Uri.parse(url))).bodyBytes;
  }

  // Добавление страницы в PDF
  static Future<void> _addPageToPDF(pw.Document doc, Uint8List img, double width, double height) async {
    pw.MemoryImage image = pw.MemoryImage(img);
    if (image.width! > image.height!) {
      Image im = decodeImage(img)!;
      image = pw.MemoryImage(encodePng(copyRotate(im, angle: 270)));
    }

    doc.addPage(pw.Page(
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
        pageFormat: PdfPageFormat(width, height)));
  }
}
