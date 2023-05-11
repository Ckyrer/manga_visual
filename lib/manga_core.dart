import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:webdriver/async_io.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart' as pw;

String driverPath = "D:\\chromedriver\\chromedriver.exe";

// Создание драйвера и подключение к нему
Future<WebDriver> startDriver() async {
  Process chromeDriverProcess = await Process.start(driverPath, ['--port=4444', '--url-base=wd/hub']);
  await for (String browserOut in const LineSplitter().bind(utf8.decoder.bind(chromeDriverProcess.stdout))) {
    // Это для Linux --> if (browserOut.contains('Starting ChromeDriver')) {
    if (browserOut.contains('ChromeDriver was started successfully.')) {
      break;
    }
  }
  Map<String, dynamic> caps = Capabilities.chrome;
  // caps[Capabilities.chromeOptions] = {'args': ['--headless']};

  return await createDriver(desired: caps);
}

// Найти мангу
Future<List> getManga(WebDriver driver, String url) async {
  if (url=="" || !url.startsWith("https://mangalib.me/")) {
    return [false];
  }
  try {
    await driver.get(url);
    if (await driver.title=='Страница не найдена 404') {return [false];}
    else {
      return [
        true,
        await (await driver.findElement(const By.className('media-name__main'))).text, // Название
        await (await driver.findElement(const By.className('media-name__alt'))).text, // Альт. название.
        await (await driver.findElement(const By.cssSelector('.media-sidebar__cover > img'))).attributes['src'], // Обложка
        double.parse((await (await driver.findElement(const By.className('link-default'))).text).trim().split(' ')[3]) // Последняя глава
      ];
    }
  } catch (e) {
    return [false];
  }
}

// Поиск нужной главы
Future<void> selectChapter(WebDriver driver, String number) async {
  // <div> всех глав
  final WebElement chaptersDiv = await driver.findElement(const By.className('vue-recycle-scroller__item-wrapper'));

  // <body>
  final WebElement body = await driver.findElement(const By.tagName('body')); 

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
    driver.execute('scrollTo(0, scrollY+1200)', []);
    height-=1000; // Примерно на таком расстоянии прогружаются новые главы, а большинство предыдущих очищаются
  } 
}

// Скачивание глав
Future<void> downloadChapters(WebDriver driver, pw.Document doc, double last, int width, int height) async {
  while (true) {
    // По сути тут всё легко, но очень много действий в двух строках, мне лень делать много переменных
    final double currentChapter = double.parse((await (await (driver.findElements(const By.className('reader-header-action__title.text-truncate'))).toList())[1].text).split(' ')[3]);
    // Проверка на то, что глава еще находится в нужном диапозоне
    if (currentChapter > last) {break;}
    // Ещё одна сложная строка
    final int pagesAmount = int.parse((await (await driver.findElement(const By.className('button.reader-pages__label.reader-footer__btn'))).text).split(' ')[3]);
    int currentPage = 1;
    while (currentPage<=pagesAmount) {
      // Получение ссылки на изображение
      final String img = (await (await (await driver.findElement(const By.className('reader-view__container'))).findElements(const By.tagName('img')).toList())[currentPage-1].properties['src'])??'';
      await _addPageToPDF(doc, await _downloadImage(img), width.toDouble(), height.toDouble());
      driver.keyboard.sendKeys(Keyboard.right);
      currentPage+=1;
    }
  }
}

// Скачивание изображения
Future<Uint8List> _downloadImage(String url) async {
  return (await http.get(Uri.parse(url))).bodyBytes;
}

// Добавление страницы в PDF
Future<void> _addPageToPDF(pw.Document doc, Uint8List img, double width, double height) async {
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
