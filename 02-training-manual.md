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

### 3.2. Lesson: Labels ラベル

### 3.3. Lesson: Classification 分類

## 4. Module: Laying out the Maps 地図をレイアウトする

### 4.1. Lesson: Using Print Layout 印刷レイアウトを使う

### 4.2. Lesson: Creating a Dynamic Print Layout 動的印刷レイアウトを作成する

### 4.3. Assignment 1 課題 1

## 5. Module: Creating Vector Data ベクター・データを作成する

### 5.1. Lesson: Creating a New Vector Dataset ベクター・データセットを作ってみる

### 5.2. Lesson: Feature Topology 地物のトポロジー

### 5.3. Lesson: Forms 入力フォーム

#### 5.3.6. Follow Along: Creating a New Form 新しいフォームを作る

QT Designer のインストールが必要になる。

QT 全体の評価版などをダウンロードしてインストールするのでなく、https://build-system.fman.io/qt-designer-download の QT Designer だけのインストーラを使うのが良い。

C:\OSGeo4W\apps\qt-designer にインストールする。

### 5.4. Lesson: Actions アクション

## 6. Module: Vector Analysis ベクトル分析

### 6.1. Lesson: Reprojecting and Transforming Data データの再投影と変形

GCS (Geomgraphic Coordinate System) および PCS (Projected Coordinate System) の基本的な話だが、まあ、よく判らない。

### 6.2. Lesson: Vector Analysis ベクトル分析

UTM は Universan Transverse Mercator ユニバーサル横メルカトル図法である。

### 6.3. Lesson: Network Analysis ネットワーク分析

### 6.4. Lesson: Spatial Statistics 空間統計学

## 7. Module: Rasters ラスタ

### 7.1. Lesson: Working with Raster Data ラスタ・データを扱う

### 7.2. Lesson: Changing Raster Symbology ラスタのシボロジーを変更する

### 7.3. Lesson: Terrain Analysis 地形分析

## 8. Module: Completing the Analysis 分析を完成させる

### 8.1. Lesson: Raster to Vector Conversion ラスタからベクタへの変換

### 8.2. Lesson: Combining the Analyses 分析を組み合わせる

### 8.3. Assignment 課題

### 8.4. Lesson: Supplementary Exercise 補充問題

DEM の解像度や座標系を変更したものを元に hillshade/slope/aspect を作成すると不自然な縞模様が目立つラスターが生成される。これを回避するためには、ラスター解析をする前にガウス・フィルターで平滑化しておくと良いようだ。

## 9. Module: Plugins プラグイン

### 9.1. Lesson: Installing and Managing Plugins プラグインのインストールと管理

### 9.2. Lesson: Useful QGIS Plugins 便利な QGIS プラグイン

#### 9.2.1. Follow Along: The QuickMapServices Plugin

QuickMapServices は、何故か分らないが、うまく動かない。データをロードするのだが、何も表示されない。

#### 9.2.2. Follow Along: The QuickOSM Plugin

#### 9.2.3. Follow Along: The QuickOSM Query engine

#### 9.2.4. Follow Along: The DataPlotly Plugin

## 10. Module: Online Resources オンライン・リソース

### 10.1. Lesson: Web Mapping Services ウェブ地図サービス

### 10.2. Lesson: Web Feature Services ウェブ地物サービス

## 11. Module: QGIS Server

現在、Cent-OS に qgis-server をインストールする方法は無いようだ。
ELGIS (Enterprise linux GIS) のレポジトリがかつては存在したが、もう保守されていない。仕方がないので読み飛ばした。

## 12. Module: GRASS

### 12.1. Lesson: GRASS Setup

#### 12.1.3. Follow Along: Loading Vector Data into GRASS

マニュアルでは GeoPackage から roads レイヤをマップセットにロードしているが、やってみると、「トポロジがありません」というエラーになって、ロードできない。
試しに、roads レイヤを shapefile にエクスポートして、それを D&D でマップセットに持って行ったら、ロードすることが出来た。

### 12.2. Lesson: GRASS Tools

斜め読み。

## 終り

トレーニング・マニュアルの主要部分は終ったので、これでやめる。