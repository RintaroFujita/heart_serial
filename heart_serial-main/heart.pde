import processing.serial.*;

Serial myPort; // Declare the Serial object

int distance = 0; // 受信した距離データを保持する変数
int fadeOutFrames = 300; // フェードアウトにかけるフレーム数（時間）
int frames = 0; // 現在のフレーム数

void setup() {
  // シリアルポートを開く
  String portName = "/dev/cu.usbserial-1410"; // Arduinoが接続されているポート名を指定
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n'); // 改行文字を受信するまでバッファリング

  // ウィンドウサイズの設定
  fullScreen(2);
  noStroke();
}

void draw() {
  background(255, 90, 90);

  // 中心の円を描画
  fill(255);
  ellipse(width / 2, height / 2, 15, 15);

  // 距離データが受信された場合に波紋を描画
  if (distance != 0) {
    // フェードアウトが完了したら距離データをリセット
    if (frames >= fadeOutFrames) {
      distance = 0;
      frames = 0; // フレーム数をリセット
    } else {
      frames++; // フレーム数を増やす
    }
    drawWave(distance, frames); // 波紋の描画
  }
}

// 波紋を描画する関数
void drawWave(int distance, int frames) {
  float maxRadius = 50; // 波紋の最大半径
  float increment = 0.1; // 波紋の増加量
  float angle = 0;
  float r = maxRadius * map(frames, 0, fadeOutFrames, 0, 2); // フェードアウトに合わせて半径を変化させる

  while (angle < TWO_PI) {
    // 波紋の中心からの位置を計算
    float x = cos(angle) * (maxRadius + distance * 5) + width / 2;
    float y = sin(angle) * (maxRadius + distance * 5) + height / 2;

    // フェードアウトに合わせて透明度を計算
    float opacity = map(frames, 0, fadeOutFrames, 255, 0);
    fill(255, opacity);
    ellipse(x, y, r, r);
    angle += increment;
  }
}

// Arduinoからのデータ受信時に呼び出される関数
void serialEvent(Serial port) {
  // 受信したデータを数値に変換して、receiveValue関数に渡す
  String data = port.readStringUntil('\n');
  if (data != null) {
    data = data.trim();
    int distanceValue = int(data);
    receiveValue(distanceValue);
  }
}

// 受信した距離データを格納する関数
void receiveValue(int distanceValue) {
  // 受信した距離データをグローバル変数に格納
  distance = distanceValue;
  frames = 0; // フレーム数をリセットしてフェードアウトを始める

  // コンソールに受信した距離データを表示
  println("Received distance value: " + distanceValue);
}
