# 兵庫県全県土高精度3次元データ

兵庫県が公開している全県土の高精度3次元データ。

- DSM 地球表面データ ... 建物・樹木などの高さを含む
- DEM 地表面データ ... 建物・樹木などの高さを含まない
- CS立体図

DSM, DEM は 50cm メッシュ。

## 参考文献
- 
- [【実習編】非専門家のためのQGIS ～兵庫県オープンデータ「CS立体図」を3Dで描画しよう～](https://note.com/kinari_iro/n/n0641c3d93001)
- [【実習編】～兵庫県オープンデータ「DSM」をQGISで描画しよう～](https://note.com/kinari_iro/n/nd291716f021b)


## 兵庫県 50cmメッシュ 数値地形図ポータル（2021～2022年度）

[兵庫県 50cmメッシュ 数値地形図ポータル（2021～2022年度）](https://www.geospatial.jp/ckan/dataset/2022-hyougo-geo-potal)

ダウンロードするために Chrome Browser を使った。
DuckDuckGo Browser では、複数ファイルのダウンロードがうまく行かなかった。

### ダウンロードする範囲

"行政区画-多可町-buffered-bbox" を含む範囲のメッシュを選択してダウンロードする。

対象範囲を地図上で図示すると下記のようになる。

```
             N
  +--------+-----+--------+
  | O5MF81 | ... | O5MF85 |
  +--------+-----+--------+
W | .....  | ... | ...... | E
  +--------+-----+--------+
  | O5NF81 | ... | O5NF85 |
  +--------+-----+--------+
              S
```

岩座神に限定したデータ範囲は

```
  +---------+---------+
  | O5NF121 | O5NF122 |
  +---------+---------+
  | O5NF123 | O5NF124 |
  +---------+---------+
  | O5NF221 | O5NF222 |
  +---------+---------+
  | O5NF223 | O5NF224 |
  +---------+---------+
```

### zip files

以下のフォルダに取得した zip files を格納。

- i-gis/hyogo/CS/zip ... CS
- i-gis/hyogo/DSM/zip ... DSM
- i-gis/hyogo/DEM/zip ... DEM

以下のフォルダに zip files を展開したデータを格納

- i-gis/hyogo/CS/raster ... CS
- i-gis/hyogo/DSM/txt ... DSM
- i-gis/hyogo/DEM/txt ... DEM

## GeoTIFF への変換

DSM, DEM データを GeoTIFF に変換する

- script/dsm-conv.bat
- script/dem-conv.bat

変換後の GeoTIFF (JGD2011-JPRCS-V)

- i-gis/hyogo/DSM/temp ... DSM
- i-gis/hyogo/DEM/temp ... DEM

何故か分らないが、gdal_translate で生成した GeoTIFF は
そのままでは gdal_merge 出来ない。何で？

一度 QGIS に読み込んで、GeoTIFF としてエクスポートしたファイルなら
大丈夫。何故か分らない。

- i-gis/hyogo/DSM/raster ... DSM
