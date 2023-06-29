import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:webdriver/async_io.dart';

class WDC {
  static late WebDriver driver;

  // Путь к драйверу
  static const String _driverPath = "./chromedriver";

  // Запуск драйвера
  static Future<void> init() async {
    final Process chromedriver = await Process.start(_driverPath, ['--port=4444', '--url-base=wd/hub']);
    await for (String browserOut in const LineSplitter().bind(utf8.decoder.bind(chromedriver.stdout))) {
      if (browserOut.contains('Starting ChromeDriver')) {
        break;
      }
    }
    final Map<String, dynamic> caps = Capabilities.chrome;
    caps[Capabilities.chromeOptions] = {
      'args': ['--user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36'] //, '--headless']
    };

    driver = await createDriver(desired: caps);
    (await driver.window).setRect(const Rectangle(0, 0, 800, 900));
  }

  // Найти элемент (null если не существует)
  static Future<WebElement?> isElementExist(WebElement? parent, By by) async {
    try {
      if (parent != null) {
        return await parent.findElement(by);
      } else {
        return await (await driver.findElement(const By.tagName("body"))).findElement(by);
      }
    } on NoSuchElementException {
      return null;
    }
  }

  // Выход
  static Future<void> exit() async {
    await WDC.driver.quit();
  }
}
