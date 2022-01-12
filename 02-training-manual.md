# トレーニング・マニュアル

## 1. Course Introduction コースの紹介

### 1.1. Foreword 前書き

### 1.2. About the exercises 練習について

#### 1.2.3. Data

練習用のサンプル・データをダウンロードする。

## 2. Module: Creating and Exploring a Basic Map 基本的な地図の作成と探索

### 2.1. Lesson: An Overview of the Interface インターフェイスの概観

### 2.2. Lesson: Adding your first layers まずはレイヤーを追加してみる

これまで一度も QGIS を使ったことが無い場合は、マニュアル記載の手順に従えば十分であろう。

私の場合、以前に QGIS で多可町の地図を扱っていたため、QGIS デフォルトの座標参照系が兵庫県向けに設定されていた。

- メニュー > 設定 > オプション > CRS と Transform > 座標参照系 (CRS)
    - プロジェクトの座標参照系
        - 新規プロジェクトが作られたとき
            - 最初のレイヤの CRS を使う
            - ○ デフォルトの CRS を使う : EPSG 6673 - JGD2011 / Japan Plane Rectangular CS V
    - レイヤの CRS
        - レイヤのデフォルト CRS : EPSG 6673 - JGD2011 / Japan Plane Rectangular CS V
        - 新規レイヤが作成された場合、あるいは CRS のないレイヤが読み込まれた場合
            - 未知の CRS のまま
            - CRS ダイアログを表示
            - ○ プロジェクトの CRS を使う
            - デフォルト CRS を使う

このため、シェープファイルを読み込んだときに座標変換を促すダイアログが表示された。
これをキャンセルで閉じると、マニュアルで見るのとは傾きが違う地図が表示された。
そして、プロジェクトのプロパティで適切な座標参照系(WGS 84)に設定し直すと、正しい傾きの地図が表示された。

新規プロジェクトの座標参照系のデフォルトを「最初のレイヤの CRS を使う」にしておけば良かったのかな。
それとも、デフォルト CRS を WGS 84 にしておくのが良いのかな。

取りあえず、トレーニング・マニュアルをやる間は、WGS 84 をプロジェクト CRS とするのが良いようだ。

### 2.3. Lesson: Navigating the Map Canvas 地図キャンバスを見て回る

### 2.4. Lesson: Symbology 

symbology って、どう和訳すれば良いのだ？ 適切な言葉が見つからない。

#### 2.4.8 Follow Along: Ordering Symbol Leves シンボル・レベルの順序付け

複数のシンボル・レイヤを持つレイヤで複数の地物を描画するときに、デフォルトでは、シンボル・レイヤ
の順序に従った描画が**地物ごとに**行われる。

1. 地物 A のシンボル・レイヤ 0
2. 地物 A のシンボル・レイヤ 1
3. 地物 B のシンボル・レイヤ 0
4. 地物 B のシンボル・レイヤ 1
5. 地物 C のシンボル・レイヤ 0
6. 地物 C のシンボル・レイヤ 1

しかし、シンボル・レベルを有効にしてその順序付けを行うと、**シンボル・レイヤごと**の描画になる。

1. 地物 A のシンボル・レイヤ 0
2. 地物 B のシンボル・レイヤ 0
3. 地物 C のシンボル・レイヤ 0
4. 地物 A のシンボル・レイヤ 1
5. 地物 B のシンボル・レイヤ 1
6. 地物 C のシンボル・レイヤ 1

#### 2.4.13. Follow Along: Geometry generator symbology

これも訳しづらい。幾何学的計算による symbology

## 3. Module: Classifying Vector Data ベクタ・データを分類する

### 3.1. Lesson: Vector Attribute Data ベクタ属性データ

#### 3.1.1. Follow Along: Viewing Layer Attributes レイヤの属性を見る
