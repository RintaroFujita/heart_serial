import processing.serial.*;

Serial myPort; // シリアル通信用のオブジェクトを宣言

int distance = 0; // 受信したパルスデータを保持する変数
int fadeOutFrames = 255; // フェードアウトにかけるフレーム数（時間）
int frames = 0; // 現在のフレーム数

void setup() {
  // シリアルポートを開く
  String portName = "/dev/cu.usbserial-1410"; // Arduinoが接続されているポート名を指定（適宜変更してください）
  myPort = new Serial(this, portName, 9600);
  myPort.bufferUntil('\n'); // 改行文字を受信するまでバッファリング

  // ウィンドウサイズの設定
  fullScreen(2);
  noStroke();
}

void draw() {
  background(0, 0, 0); // 背景を黒で塗りつぶす

  // 中心の円を描画
  fill(255); // 白で塗りつぶす
  ellipse(width / 2, height / 2, 15, 15); // 中心の円を描く

  // 距離データが受信された場合に波紋を描画
  if (distance != 0) {
    // フェードアウトが完了したら距離データをリセット
    if (frames >= fadeOutFrames) {
      distance = 0; // 距離データをリセット
      frames = 0; // フレーム数をリセット
    } else {
      frames++; // フレーム数を増やす
    }
    drawWave(distance, frames); // 波紋の描画
  }

  // 背景の動的な形状を描画
  drawDynamicBackground();
}

// 背景に動的な形状を描画する関数
void drawDynamicBackground() {
  float numShapes = map(distance, 0, 1023, 1, 100); // パルスデータに応じて描画する形状の数を決定
  float shapeSize = map(distance, 0, 1023, 5, 50); // パルスデータに応じて形状のサイズを決定
  float opacity = map(frames, 0, fadeOutFrames, 255, 0); // フェードアウトに合わせて透明度を計算

  if (frames >= fadeOutFrames) {
    return; // フェードアウトが完了したら何もせずに関数を終了
  }

  for (int i = 0; i < numShapes; i++) {
    float x = random(width);
    float y = random(height);
    float hue = 200; // 緑色（hue = 200）
    float saturation = 255; // 鮮やかな色のための最大彩度
    float brightness = random(70, 90); // 90から100の間のランダムな明るさ
    float ellipseWidth = shapeSize * 1; // この値を大きくすると楕円形がより細長くなる

    pushMatrix(); // 現在の変換行列を保存
    translate(x, y); // 原点を楕円形の位置に移動
    rotate(random(TWO_PI)); // ランダムな回転角度を設定

    fill(hue, saturation, brightness, opacity); // フェードアウト効果を考慮した色を指定
    ellipse(0, 0, ellipseWidth, shapeSize); // 細長い楕円形を描画（幅は高さの何倍かを調整）

    popMatrix(); // 前の変換行列に戻す
  }
}

// 波紋を描画する関数
void drawWave(int distance, int frames) {
  float maxRadius = 230; // 波紋の最大半径
  float increment = 0.1; // 波紋の増加量
  float angle = 0;
  float r = maxRadius * map(frames, 0, fadeOutFrames, 0, 2); // フェードアウトに合わせて半径を変化させる

  // リングの大きさを距離データに応じて変化させる
  float ringSize = map(distance, 0, 1023, 10, maxRadius * 2);

  while (angle < TWO_PI) {
    // 波紋の中心からの位置を計算
    float x = width / 2 + cos(angle) * r; // x座標を計算
    float y = height / 2 + sin(angle) * r; // y座標を計算

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

// 受信したパルスデータを格納する関数
void receiveValue(int distanceValue) {
  // 受信したパルスデータをグローバル変数に格納
  distance = distanceValue;
  frames = 0; // フレーム数をリセットしてフェードアウトを始める

  // コンソールに受信したパルスデータを表示
  println("Received distance value: " + distanceValue);
}
