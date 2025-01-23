# 農林水産省「筆ポリゴン」データ

https://www.maff.go.jp/j/tokei/porigon/index.html

農林水産省が提供している農地の区画情報。

- 市町村単位で無料でダウンロード出来る
- 形式は GeoJSON

以下のフォルダに取得した zip file を格納。

- i-gis/maff/download/

同じフォルダに、zip file を展開した json ファイルを保存

QGIS には、そのまま読み込むことが出来る。

岩座神の範囲以外のポリゴンを削除し、不要なフィールドも削除して
shapefile に格納。
