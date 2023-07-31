import processing.serial.*;

Serial myPort; // Declare the Serial object

int distance = 0; // 受信した距離データを保持する変数
int fadeOutFrames = 200; // フェードアウトにかけるフレーム数（時間）
int frames = 0; // 現在のフレーム数


void setup() {
  // シリアルポートを開く
  String portName = "/dev/cu.usbmodem11101"; // Arduinoが接続されているポート名を指定
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n'); // 改行文字を受信するまでバッファリング

  // ウィンドウサイズの設定
  fullScreen(2);
  noStroke();
}

void draw() {
  background(0, 0, 0);

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

  // 背景の動的な形状を描画
  drawDynamicBackground();
}
void drawDynamicBackground() {
  float numShapes = map(distance, 0, 1023, 1, 100); // 距離データに応じて描画する形状の数を決定
  float shapeSize = map(distance, 0, 1023, 5, 50); // 距離データに応じて形状のサイズを決定
  float opacity = map(frames, 0, fadeOutFrames, 255, 0); // フェードアウトに合わせて透明度を計算

  if (frames >= fadeOutFrames) {
    return; // If frames reach the fadeOutFrames limit, stop drawing the ellipses
  }

  for (int i = 0; i < numShapes; i++) {
    float x = random(width);
    float y = random(height);
    float hue = 200; // Green color (hue = 200)
    float saturation = 255; // Maximum saturation for a bright color
    float brightness = random(70, 90); // Random brightness between 90 and 100
    float ellipseWidth = shapeSize * 1; // Increase this value to elongate the ellipses further

    pushMatrix(); // Save the current transformation matrix
    translate(x, y); // Translate the origin to the ellipse's position
    rotate(random(TWO_PI)); // Set a random rotation angle

    fill(hue, saturation, brightness, opacity); // Use opacity for fade-out effect
    ellipse(0, 0, ellipseWidth, shapeSize); // Draw the elongated ellipse (width is 4 times the height)

    popMatrix(); // Restore the previous transformation matrix
  }
}


// 波紋を描画する関数
void drawWave(int distance, int frames) {
  float maxRadius = 150; // 波紋の最大半径
  float increment = 0.1; // 波紋の増加量
  float angle = 0;
  float r = maxRadius * map(frames, 0, fadeOutFrames, 0, 2); // フェードアウトに合わせて半径を変化させる

  // リングの大きさを距離データに応じて変化させる
  float ringSize = map(distance, 0, 1023, 10, maxRadius * 2);

  while (angle < TWO_PI) {
    // 波紋の中心からの位置を計算
    float x = width / 2 + cos(angle) * r; // 中心からx座標を計算
    float y = height / 2 + sin(angle) * r; // 中心からy座標を計算

    // フェードアウトに合わせて透明度を計算
    float opacity = map(frames, 0, fadeOutFrames, 255, 0);
    fill(255, 90, 90, opacity);
    ellipse(x, y, ringSize, ringSize); // リングの大きさを距離データに応じて変化させる
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
