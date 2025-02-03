# Standalone QGIS Web Client 2

https://qwc-services.github.io/master/

## git をインストール

```bash
dnf install git
```

## Standalone QWC2 をインストールする

### nodejs, yarnpkg

```bash
# dnf module list nodejs        [List Node.js Stream]
# dnf module enable nodejs:20   [Enable Node.js 20 Stream]
# dnf install nodejs -y         [Install Node.js 20 Version]

# node -v
# npm -v

# dnf install yarnpkg
```

取りかかりとしては、デモ・アプリをローカルにクローンして、修正を加えていくのが良い。

ここでは、qgis/qwc2-demo-app のフォークである softark/qwc2-demo-app を使用する。

```bash
git clone --recursive https://github.com/softark/qwc2-demo-app.git
```

+ qwc2 サブ・ディレクトリはサブ・レポジトリなので --recursive が必要

必要な依存を全てインストールする。

```bash
cd qwc2-demo-app
yarn install
```

そして、開発版のデモ・アプリを開始する。

```bash
yarn start
```

### ファイアウォール

開発版アプリを表示するためにファイアウォールの設定を変更する必要がある。

```bash
firewall-cmd --add-port=8081/tcp --permanent
firewall-cmd --reload
```

開発版アプリは http://localhost:8081 または http://192.168.0.10:8081 で走る。

### 実行環境ファイルの作成とウェブサーバへの設置

開発版アプリの修正が済んだら、運用版のアプリを作成して、ウェブ・サーバで公開する。

```bash
yarn run prod
```

`prod` フォルダ以下に静的なファイルが生成されるので、これを `/var/www/gis` 以下に配置し、
nginx の設定をする。これは、通常の https://gis.vmware の静的サイトとして走る。