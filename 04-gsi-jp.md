# 国土地理院基盤地図情報

[国土地理院](https://gsi.go.jp)が公開している基盤地図情報(基本項目) および数値標高モデル(10m DEM)のデータ。

## 基盤地図情報ダウンロードサービス

[基盤地図情報 https://www.gsi.go.jp/kiban/index.html](https://www.gsi.go.jp/kiban/index.html) > [基盤地図情報のダウンロード https://fgd.gsi.go.jp/download/menu.php](https://fgd.gsi.go.jp/download/menu.php)

### 利用者登録

ダウンロードサービスを利用するためには利用者登録が必要

- ID : softark
- Password : P~j74Y@mN
- mail address : softark@gmail.com

### ダウンロードする範囲

兵庫県多可郡多可町を含む範囲のメッシュを選択してダウンロードする。

対象範囲を地図上で図示すると下記のようになる。

```
           N
  +--------+--------+
  | 523466 | 523467 |
  +--------+--------+
  | 523456 | 523457 |
W +--------+--------+ E
  | 523446 | 523447 |
  +--------+--------+
  | 523436 | 523437 |
  +--------+--------+
           S
```

523466 は多可町を含まないが、切りの良い矩形にしたいので、ダウンロード範囲に含める。

### zip files

以下のフォルダに取得した zip files を格納。

- i-gis/gsi-jp/downloads/base ... 基本項目
- i-gis/gsi-jp/downloads/dem10m ... DEM 10m
- i-gis/gsi-jp/downloads/dem5m ... DEM 5m


### TODO

なお、5m DEM は日本全土を覆っておらず、多可町の領域にも大きなデータ欠落がある。千ヶ峰も岩座神も抜け落ちている。従って、ここでは使わない。

## 基盤地図情報の変換

基盤地図情報のデータは XML で提供されている。そのままでは使い辛いので、同じく国土地理院が公開している
[基盤地図情報ビューア FGDV.exe](https://fgd.gsi.go.jp/download/documents.html) を使って、shapefile に変換する。

- i-gis/gsi-jp/tools/FGDV ... ダウンロード zip ファイル
- OSGeo4W/apps/FGDV ... 実行ファイルのフォルダを展開

ダウンロードした基盤地図情報の zip ファイルを全部読み込ませて、
一つのデータに統合して shapefile に変換することが可能。

変換先の座標参照系(CRS)は JGD2011-Japan Zone 5。

変換後の shapefile は Shift-JIS でエンコードされているので要注意。

- i-gis/gsi-jp/org/shapefiles ... 変換された shapefiles を保存 (JGD2011-JPRCS-V)

## 数値標高モデル DEM の変換

数値標高モデルのデータは株式会社エコリスが提供する[標高DEMデータ変換ツール](https://www.ecoris.co.jp/contents/demtool.html) を使って GeoTiff に変換する。

- i-gis/gsi-jp/tools/demtool ... ダウンロード zip ファイル
- OSGeo4w/apps/demtool ... 実行ファイルのフォルダを展開

ダウンロードした zip ファイルから抽出した xml ファイルを置いたディレクトリを指定して、
上記のツールで変換する。
そのディレクトリに tiff ファイルが作成されるので、別のフォルダに移動しておく。

変換先の座標参照系(CRS)は、JGD2000, JGD2000-UTM53N, JGD2000-PRCS-V の三種類を指定可能。

- i-gis/gsi-jp/org/geotiffs/2000 ... 変換された geotiff を保存 (JGD2000)
- i-gis/gsi-jp/org/geotiffs/2000-5 ... 変換された geotiff を保存 (JGD2000-PRCS-V)

必要なものは、どちらのディレクトリでも、merge.tif だけ。

## 基盤地図情報の整理

オリジナルのファイルを開いた後、レイヤを複製して、複製したレイヤで作業をする。
オリジナル・ファイルのレイヤには手を触れてはいけない。

- レイヤのプロパティ > ソース > エンコーディング で Shift_JIS を選ぶこと。
- エクスポート時には UTF-8 を選ぶ。

作業中のファイルは以下のワーク・ディレクトリに保存する。

- i-gis\gsi-jp\work\shapefiles

以下の作業は JGD2011-PRCS-V の座標参照系で作業する。

### 行政区画の整理

最初に行政区画の shapefiles を整理する。

1. 名前の同じ地物を結合して、分割されている行政区画をまとめる。
   - ベクタ > 空間演算ツール > 融合 で新規レイヤを作成
2. 属性テーブルを編集し、不要なフィールドを削除し、名前も英字に変更する。
   - レイヤのプロパティ > フィールド
3. "行政区画.shp" としてエクスポートする。
4. 多可町を示す地物だけを "行政区画-多可町.shp" としてエクスポートする。
5. 1500m のバッファで "行政区画-多可町-buffered" を作成。
   - ベクタ > 空間演算ツール > バッファ で新規レイヤを作成
6. "行政区画-多可町-buffered.shp" としてエクスポートする。
7. "行政区画-多可町-buffered" の包含矩形を作成する。
   - プロセシング > ベクタジオメトリ > BBox
8. "行政区画-多可町-buffered-bbox.shp" としてエクスポートする。
9. "行政区画" を "行政区画-多可町-buffered-bbox" でクリップ。
10. "行政区画-master.shp" としてエクスポートする。

以上で、ワーク・ディレクトリに次の shapefiles が作成される。
★印のものはマスターとして、master ディレクトリにコピーして保存する。

- 行政区画
- ★行政区画-多可町
- ★行政区画-多可町-buffered
- ★行政区画-多可町-buffered-bbox
- ★行政区画-master

作業中には、**演算を行った結果を直接ファイルにエクスポートしない** ことが重要。
いったん一時レイヤに出力して、後でファイルにエクスポートする。
直接ファイルに出力すると、全ての文字が Shift-JIS でエンコードされて、面倒くさいことになる。

以下の項目についても、属性整理をして、"行政区画-多可町-buffered-bbox" でクリップした
マスター・ファイルを作成する。

- ★建築物-master
- ★建築物の外周線-master
- ★水域-master
- ★水涯線-master
- ★水部構造物線-master
- ★水部構造物面-master
- ★等高線-master
- ★道路縁-master
- ★道路構成線-master

## 数値標高モデル DEM の整理

ラスタ > 抽出 > マスクレイヤで切り抜く

- 入力 CRS ... JGD2000-CS-V
- 出力 CRS ... JGD2011-CS-V

- ★DEM-master.tif として保存する。