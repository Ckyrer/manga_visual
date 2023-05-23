import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:manga_visual/models/InputerViewModel.dart';
import 'package:pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webdriver/async_io.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;

class MangaCore {
  static WebDriver? driver;
  static const String driverPath = "D:\\chromedriver\\chromedriver.exe";

  // Создание драйвера и подключение к нему
  static Future<void> init() async {
    Process chromeDriverProcess = await Process.start(driverPath, ['--port=4444', '--url-base=wd/hub']);
    await for (String browserOut in const LineSplitter().bind(utf8.decoder.bind(chromeDriverProcess.stdout))) {
      // Это для Linux --> if (browserOut.contains('Starting ChromeDriver')) {
      if (browserOut.contains('ChromeDriver was started successfully.')) {
        break;
      }
    }
    Map<String, dynamic> caps = Capabilities.chrome;
    caps[Capabilities.chromeOptions] = {'args': ['--no-sandbox', '--headless'], 'detach': true};

    driver =  await createDriver(desired: caps);
  }


  // Ждать до прогрузки элемента (может пригодится) 
  static Future<WebElement> waitForElement(WebElement root, By by) async {
    while (true) {
      try {
        await root.findElement(by);
        return await root.findElement(by);
      } on NoSuchElementException {
        continue;
      }
    }
  }

  // Найти мангу
  static Future<List> getManga(String url) async {
    if (url=="" || !url.startsWith("https://mangalib.me/")) {
      return [false];
    }
    try {
      await driver!.get(url);
      if (await driver!.title=='Страница не найдена 404') {return [false];}
      else {
        return [
          true,
          await (await driver!.findElement(const By.className('media-name__main'))).text, // Название
          await (await driver!.findElement(const By.className('media-name__alt'))).text, // Альт. название.
          await (await driver!.findElement(const By.cssSelector('.media-sidebar__cover > img'))).attributes['src'], // Обложка
          double.parse((await (await driver!.findElement(const By.className('link-default'))).text).trim().split(' ')[3]) // Последняя глава
        ];
      }
    } catch (e) {
      return [false];
    }
  }

  // Поиск нужной главы
  static Future<bool> selectChapter(String number) async {

    // Проверка на возрастное ограничение
    try {
      await driver!.findElement(const By.id("title-caution"));
      print("Возрастное ограничение! Вход в аккаунт...");

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      if ( !(await login(prefs.getString("username")??"", prefs.getString("password")??"")) ) {
        print("Неверный логин или пароль!");
        return false;
      }
    } on NoSuchElementException {
      print("Нет ограничений");
    }

    // <div> всех глав
    final WebElement chaptersDiv = await driver!.findElement(const By.className('vue-recycle-scroller__item-wrapper'));

    // <body>
    final WebElement body = await driver!.findElement(const By.tagName('body')); 

    int height = int.parse(await body.properties['scrollHeight']??'0');
    m: while (height>0) {
      // Поиск нужного <a>
      for (WebElement div in await chaptersDiv.findElements(const By.className('media-chapter__name.text-truncate')).toList()) {
        final a = await div.findElement(const By.className('link-default')); // <a> с ссылкой на главу
        final n = await a.text; // Текст <a>

        // Проверка на то, что <a> не пустой(иногда попадаются пустые, которые не прогрузились)
        if (n.trim()!='') {
          if (n.split(' ')[3] == number) {
            await a.click();
            break m;
          }
        }
      }

      // Прогрузка следующих глав
      driver!.execute('scrollTo(0, scrollY+1200)', []);
      height-=1000; // Примерно на таком расстоянии прогружаются новые главы, а большинство предыдущих очищаются
    }
    return true;
  }

  // Скачивание глав
  static Future<void> downloadChapters(InputerViewModel inp, String title, double last, int width, int height) async {
    // Создание PDF дркумента
    final pw.Document doc = pw.Document(author: 'Kvdl', title: title);
    while (true) {
      // По сути тут всё легко, но очень много действий в двух строках, мне лень делать много переменных
      String label = await (await (driver!.findElements(const By.className('reader-header-action__title.text-truncate'))).toList())[1].text;
      final double currentChapter = double.parse((label).split(' ')[3]);
      // Проверка на то, что глава еще находится в нужном диапозоне
      if (currentChapter > last) {break;}
      // Ещё одна сложная строка
      final int pagesAmount = int.parse((await (await driver!.findElement(const By.className('button.reader-pages__label.reader-footer__btn'))).text).split(' ')[3]);
      int currentPage = 1;
      while (currentPage<=pagesAmount) {
        // Обновление счётчика
        inp.setCurrentPage("$label $currentPage/$pagesAmount");
        
        // Получение ссылки на изображение
        final String img = (await (await (await driver!.findElement(const By.className('reader-view__container'))).findElements(const By.tagName('img')).toList())[currentPage-1].properties['src'])??'';
        await _addPageToPDF(doc, await _downloadImage(img), width.toDouble(), height.toDouble());
        driver!.keyboard.sendKeys(Keyboard.right);
        currentPage+=1;
      }
    }   
    final file = File('$title.pdf');
    await file.writeAsBytes(await doc.save());

    driver!.get('data:,');
  }

  // Вход в аккаунт
  static Future<bool> login(String? name, String? password) async {
    if (name==null || password==null) {return false;}

    WebElement frame =  await driver!.findElement(const By.id("title-caution"));
    await (await frame.findElement(const By.className("button_block"))).click();

    await (await driver!.findElement(const By.name("email"))).sendKeys(name);
    await (await driver!.findElement(const By.name("password"))).sendKeys(password);
    await (await driver!.findElement(const By.className("control__indicator"))).click();
    await (await driver!.findElement(const By.className("button"))).click();

    if (await driver!.title=='Авторизация') {
      await driver!.get("data:,");
      return false;
    }
    return true;
  }

  // Скачивание изображения
  static Future<Uint8List> _downloadImage(String url) async {
    return (await http.get(Uri.parse(url))).bodyBytes;
  }

  // Добавление страницы в PDF
  static  Future<void> _addPageToPDF(pw.Document doc, Uint8List img, double width, double height) async {
    final image = pw.MemoryImage(img);
    doc.addPage (
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(image));
        },
        pageFormat: PdfPageFormat(width, height)
      )
    );
  }
}
