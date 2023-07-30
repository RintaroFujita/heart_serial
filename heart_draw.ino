#include <Adafruit_NeoPixel.h>

#define PIXEL_PIN 6
#define PIXEL_COUNT 12 // NeoPixelの個数（例として12個に設定）
#define PIXEL_BRIGHTNESS 150 // NeoPixelの輝度（0-255）

Adafruit_NeoPixel pixels(PIXEL_COUNT, PIXEL_PIN, NEO_GRB + NEO_KHZ800);

void setup() {
  Serial.begin(9600); // シリアル通信を初期化
  pixels.begin();     // NeoPixelの初期化
}

void flashAndFade(uint32_t color, int duration) {
  // フェードイン
  for (int i = 0; i <= PIXEL_BRIGHTNESS; i++) {
    pixels.setBrightness(i);
    for (int j = 0; j < PIXEL_COUNT; j++) {
      pixels.setPixelColor(j, color);
    }
    pixels.show();
    delay(duration);
  }

  // フェードアウト
  for (int i = PIXEL_BRIGHTNESS; i >= 0; i--) {
    pixels.setBrightness(i);
    for (int j = 0; j < PIXEL_COUNT; j++) {
      pixels.setPixelColor(j, color);
    }
    pixels.show();
    delay(duration);
  }

  pixels.setBrightness(PIXEL_BRIGHTNESS); // 輝度を元に戻す
  pixels.clear(); // NeoPixelを消す
  pixels.show();
}

void loop() {
  int value = random(30, 100); // 30から100の間でランダムな数値を生成
  Serial.println(value); // 数値をシリアル通信で送信

  // NeoPixelを点灯（赤色の場合）
  uint32_t red = pixels.Color(PIXEL_BRIGHTNESS, 0, 0); // 赤色の色を作成
  flashAndFade(red, 15); // フェードイン＆フェードアウト点滅（30ミリ秒間隔）

  delay(random(1000)); // データ送信間隔（1秒）
}
