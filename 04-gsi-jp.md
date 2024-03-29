# 国土地理院基盤地図情報

[国土地理院](https://gsi.go.jp)が公開している基盤地図情報(基本項目) および数値標高モデル(10m DEM)のデータ。

## 基盤地図情報ダウンロードサービス

[基盤地図情報 https://www.gsi.go.jp/kiban/index.html](https://www.gsi.go.jp/kiban/index.html) > [基盤地図情報のダウンロード https://fgd.gsi.go.jp/download/menu.php](https://fgd.gsi.go.jp/download/menu.php)

### 利用者登録

ダウンロードサービスを利用するためには利用者登録が必要

- ID : softark
- Password : {Zw3vA4P|
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

変換先の座標参照系(CRS) JGD2011 または JGD2011-Japan Zone 5 を選択可能。

base/shapefiles 以下に保存。

変換後の shapefile は Shift-JIS でエンコードされているので要注意。

## 数値標高モデルの変換

数値標高モデルのデータは株式会社絵子リスが提供する[標高DEMデータ変換ツール](https://www.ecoris.co.jp/contents/demtool.html) を使って GeoTiff に変換する。

ダウンロードした zip ファイルから抽出した xml ファイルを jpgis ディレクトリに置いて、上記のツールで変換し、結果を geotiff ディレクトリに保存する。

変換先の座標参照系(CRS)は、JGD2000, JGD2000-UTM53N, JGD2000-PRCS-V の三種類。


## 基盤地図情報の整理

以下の shapefile を作成する。

必要なファイルを base 以下のディレクトリから base-work 以下にコピーして作業する。
（作業の途中で属性テーブルを編集する必要がある場合があるので、ダウンロードした生データには手を着けないようにする。）

以下の作業は JGD2000-PRCS-V の座標参照系で作業する。

### 行政区画の整理

最初に行政区画の shapefiles を整理する。

1. 8個の行政区画 shapefile を QGIS にロードして、ベクタ・レイヤのマージを行って結合する。
2. 名前の同じ地物を結合して、分割されている行政区画をまとめる。
3. 属性テーブルを編集し、不要なフィールドを削除し、フィールド名は全て英字に変更する。
4. "行政区画.shp" としてエクスポートする。
5. 多可町を示す地物だけを "多可町.shp" としてエクスポートする。
6. 1500m のバッファで "多可町-buffered" を作成。
7. "多可町" および "多可町-buffered" の包含矩形を作成。
8. "行政区画" を "多可町-buffered-b-box" でクリップして、"行政区画-master" を作成。

以上で、次の shapefiles が作成される。★印のものはマスターとして、base-master ディレクトリにコピーして保存する。

- 行政区画
- ★多可町
- ★多可町-buffered
- ★多可町-b-box
- ★多可町-buffered-b-box
- ★行政区画-master

作業中には、**演算を行った結果を直接ファイルにエクスポートしない** ことが重要。面倒だが、いったん一時レイヤに出力して、後でファイルにエクスポートする。直接ファイルに出力すると、全ての文字が Shift-JIS でエンコードされて、後々、もっと面倒くさいことになる。

以下の項目についても、結合と属性整理をして結合ファイルを作成し、それを "多可町-buffered-b-box" でクリップしてマスター・ファイルを作成する。

- 水域
- ★水域-master
- 水涯線
- ★水涯線-master
- 水部構造物線
- 水部構造物線-master
- 水部構造物面
- 水部構造物面-master
- 等高線
- ★等高線-master
- 道路縁
- ★道路縁-master

多可町内には水部構造物線、水部構造物面の地物は無いので、それらはマスターに含めない。

#### 結合に失敗する場合の対策

項目によっては、文字列の最大長が異なることが原因で、結合に失敗する。例えば、水部構造物面では、"id" のフィールドの長さがファイルによって異なる。また、等高線では、"標高" のフィールドの長さが異なる。

この場合、フィールド計算機を使って、フィールドの長さを揃える作業が必要になる。

shapefiles を書き換えることになるので、ダウンロードして変換しただけのファイルではなく、base-work にコピーしたファイルを使用しなければならない。


