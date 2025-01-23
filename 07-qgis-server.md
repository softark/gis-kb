# QGIS Server

## マニュアル

+ [QGIS Server Guide/Manual](https://docs.qgis.org/3.34/en/docs/server_manual/index.html#qgis-server-manual)

## nginx

`/etc/yum.repos.d/nginx.repo` を作成

```editorconfig
[nginx-stable]
name=nginx stable repo
baseurl=http://nginx.org/packages/centos/$releasever/$basearch/
gpgcheck=1
enabled=1
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

[nginx-mainline]
name=nginx mainline repo
baseurl=http://nginx.org/packages/mainline/centos/$releasever/$basearch/
gpgcheck=1
enabled=0
gpgkey=https://nginx.org/keys/nginx_signing.key
module_hotfixes=true

```

```shell
# dnf install nginx
```

ユーザ nginx を apache グループに追加しておく。
session ファイルに書き込めなかったり、php-fpm が動作しなかったりという障害を防止するため。

ユーザ nginx のグループを確認
```shell
# groups nginx
nginx : nginx
```
ユーザ apache のグループを確認
```shell
# groups apache
groups: ‘apache’: no such user
```

apache は無い。じゃ、後で。

`/etc/nginx/nginx.conf` を編集。ipV6 ポートのリスンをしないように変更する。

```shell
        listen       80;
#       listen       [::]:80;
```

ファイアウォールのインストールと設定変更。

```shell
# dnf install firewalld
# systemctl start firewalld
# firewall-cmd --add-service=http --permanent
# firewall-cmd --add-service=https --permanent
# systemctl restart firewalld
# systemctl enable firewalld
```

nginx を起動する。

```shell
# systemctl start nginx
# systemctl enable nginx
```

## QGIS Server インストール

Cent-OS 9 では、dnf でインストール出来る。

crb レポジトリを有効にしておく必要がある。

```bash
# dnf config-manager --enable crb
```

/etc/yum.repos.d/almalinux-crb.repo を編集しても良い。

```editorconfig
# dnf list | grep qgis
# dnf install qgis-server
```

/usr/bin に以下がインストールされる

- qgis (QGIS Desktop)
- qgis_mapserver (QGIS Map Server)
- qgis_process (QGIS Processing Executor)

/usr/libexec/qgis に以下がインストールされる

- qgis_mapserv.fcgi

その他に、注目すべきものとしては、以下がインストールされる

- /usr/share/doc/qgis-server/qgis-server-README.fedora
- /etc/httpd/conf.d/qgis-server.conf

nginx 用のサンプル設定ファイルは無い。

以下、ChatGPT との会話

## fcgiwrap を使用する nginx 設定

うん、AlmaLinux 9 では、"dnf install qgis-server" でインストールは出来たんだよ。
Apache の設定例もインストールに含まれている。
しかし、ウェブ・サーバとしては NGINX を使いたいんだよね。それで行き詰ってる。

NGINX を使って QGIS Server をセットアップするには、FastCGI 経由で 
QGIS Server を動作させるように設定する必要があります。以下は具体的な手順です。

### 1. 必要なパッケージの確認
既に dnf install qgis-server を実行しているので、QGIS Server はインストール済みですね。
次に、NGINX がインストールされていることを確認してください。

```[bash]
sudo dnf install nginx
```

### 2. QGIS Server の FastCGI ソケット設定
通常、qgis_mapserv.fcgi は /usr/libexec/qgis/qgis_mapserv.fcgi に存在します。
このパスを確認してください。

```[bash]
ls /usr/libexec/qgis/qgis_mapserv.fcgi
```

### 3. NGINX の設定
以下のような設定ファイルを /etc/nginx/conf.d/qgis.conf に作成します。

```[nginx]
server {
listen 80;
server_name your-server-domain-or-ip;

    location /qgis/ {
        include fastcgi_params;
        fastcgi_pass unix:/run/fcgiwrap.socket;
        fastcgi_param SCRIPT_FILENAME /usr/libexec/qgis/qgis_mapserv.fcgi;
        fastcgi_param QGIS_PROJECT_FILE /path/to/your/project.qgs;
        fastcgi_param QGIS_SERVER_LOG_FILE /var/log/qgis-server.log;
        fastcgi_param QGIS_SERVER_LOG_LEVEL 0; # 0=INFO, 1=DEBUG
    }

    error_log /var/log/nginx/qgis-error.log;
    access_log /var/log/nginx/qgis-access.log;
}
```

### 4. NGINX 用 FastCGI Wrapper のセットアップ
NGINX は FastCGI を扱うために fcgiwrap が必要です。以下をインストールしてください。

```[bash]
sudo dnf install fcgiwrap
```
 
### 5. fcgiwrap サービスの起動
fcgiwrap サービスを有効化し、起動します。

```[bash]
sudo systemctl enable fcgiwrap
sudo systemctl start fcgiwrap
```

FastCGI ソケットが /run/fcgiwrap.socket に存在することを確認します。

```[bash]
ls /run/fcgiwrap.socket
```

### 6. NGINX の再起動
設定ファイルをテストしてから NGINX を再起動します。

```[bash]
sudo nginx -t
sudo systemctl restart nginx
```

### 7. SELinux の設定 (必要な場合)
SELinux が有効な場合、NGINX と QGIS Server 間の通信を許可するために
ポリシーを調整する必要があります。

```[bash]
sudo setsebool -P httpd_can_network_connect 1
sudo chcon -R -t httpd_sys_content_t /path/to/your/project.qgs
```

### 8. 動作確認
ブラウザで http://your-server-domain-or-ip/qgis/ にアクセスして、動作を確認します。

これでもうまく動作しない場合、エラーログを確認してください。

- NGINX のエラーログ: /var/log/nginx/qgis-error.log
- QGIS Server のログ: /var/log/qgis-server.log (上記設定に基づく)

問題の詳細に応じて追加のサポートを提供できます！

## Systemd を使用する nginx 設定

ありがとう。

https://docs.qgis.org/3.34/en/docs/server_manual/getting_started.html は
Debian ベースのシステムのための説明なんだけれど、nginx で qgis server を動かす場合、
3つの選択肢があると言っている。

1. fcgi
   1. spawn-fcgi,
   2. fcgiwrap,
2. systemd

fcgi を使う場合、fcgiwrap は簡単だけど遅いので運用サーバでは spawn-fcgi をお奨めするとのこと。
さらにより良さそうなのは systemd を使うやり方らしい。この説明を AlmaLinux 9 に当て嵌めて、systemd でやりたい。

以下は、AlmaLinux 9 で NGINX と systemd を使って QGIS Server をセットアップする手順です。この方法は高性能で運用環境に適しています。

### 1. QGIS Server の確認
すでに dnf install qgis-server を実行済みなら、QGIS Server がインストールされていることを確認します。

``` [bash]
which qgis_mapserv.fcgi
```
通常、/usr/libexec/qgis/qgis_mapserv.fcgi にインストールされます。

上記のコマンドは失敗するが、qgis_mapserv.fcgi の場所が分ればそれで問題は無い。

### 2. Systemd サービスファイルの作成
QGIS Server を systemd で直接起動するためのユニットファイルを作成します。

```[bash]
sudo nano /etc/systemd/system/qgis-server.service
```

以下を内容として保存します。

```[ini]
[Unit]
Description=QGIS Server (FastCGI)
After=network.target

[Service]
ExecStart=/usr/libexec/qgis/qgis_mapserv.fcgi
User=nginx
Group=nginx
Environment=QGIS_SERVER_LOG_FILE=/var/log/gis-svr/qgis-server.log
Environment=QGIS_SERVER_LOG_LEVEL=0
Environment=QGIS_PROJECT_FILE=/var/www/gis-svr/projects/i-gis/i-gis.qgz
StandardInput=socket

[Install]
WantedBy=multi-user.target
```

ログファイルの保存場所として /var/log/gis-svr のディレクトリを作成する。
このディレクトリを nginx から書き込み可能に設定しておく。

```[basho]
sudo mkdir /var/log/gis-svr
sudo chmod 777 /var/log/gis-svr
```

### 3. Systemd ソケットファイルの作成
QGIS Server にリクエストを転送するソケットを作成します。

```[bash]
sudo nano /etc/systemd/system/qgis-server.socket
```

```[ini]
[Unit]
Description=QGIS Server Socket

[Socket]
ListenStream=/run/qgis-server.sock
SocketUser=nginx
SocketGroup=nginx
SocketMode=0660

[Install]
WantedBy=sockets.target
```

### 4. サービスとソケットの有効化と起動
systemd の設定をリロードし、ソケットを有効化して起動します。

```[bash]
sudo systemctl daemon-reload
sudo systemctl enable qgis-server.socket
sudo systemctl start qgis-server.socket
```

qgis-server.service は qgis-server.socket によって起動されるので
ここで起動する必要は無い。

QGIS Server が正しく起動していることを確認します。

```[bash]
sudo systemctl status qgis-server.socket
```

ソケットファイル /run/qgis-server.sock が存在しているか確認します。

### 5. NGINX の設定
次に、NGINX を設定して QGIS Server と連携させます。

```[bash]
sudo nano /etc/nginx/conf.d/gis-svr.conf
````

以下の内容を追加します。

```[nginx]
server {
    listen 80;
    server_name gis-svr.vmware;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    http2 on;
    server_name gis-svr.vmware;
    root /var/www/gis-svr;

    location /i-gis/ {
        include fastcgi_params;
        fastcgi_pass unix:/run/qgis-server.sock;
        fastcgi_param SCRIPT_FILENAME /usr/libexec/qgis/qgis_mapserv.fcgi;
        fastcgi_param QGIS_PROJECT_FILE /var/www/gis-svr/projects/i-gis/i-gis.qgz;
        fastcgi_param QGIS_SERVER_LOG_FILE /var/log/gis-svr/qgis-server.log;
        fastcgi_param QGIS_SERVER_LOG_LEVEL 0;
    }

    error_log /var/log/nginx/gis-svr-error.log;
    access_log /var/log/nginx/gis-svr-access.log;

    ssl_certificate /etc/pki/tls/certs/vmware.crt;
    ssl_certificate_key /etc/pki/tls/certs/vmware.key;
}
````

### 6. NGINX の再起動
設定をテストして NGINX を再起動します。

```[bash]
sudo nginx -t
sudo systemctl restart nginx
```

### 7. SELinux の設定 (必要な場合)
SELinux を有効にしている場合は、ソケットとプロジェクトファイルへのアクセスを許可する必要があります。

```[bash]
sudo setsebool -P httpd_can_network_connect 1
sudo chcon -R -t httpd_sys_content_t /path/to/your/project.qgs
sudo chcon -t httpd_sys_rw_content_t /run/qgis-server.sock
```

### 8. 動作確認
ブラウザで以下の URL にアクセスして動作を確認します。

```
https://gis-svr.vmware/i-gis/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.3.0&CRS=EPSG:6673&WIDTH=600&HEIGHT=600
```

んあ？ Internal Server Error だと？

Ivalid map settings ???

BBOX のパラメータが必要と言うことらしい。エラーは出なくなったが、真っ白な四角形が表示されるだけ。

なるほど、BBOX の設定をきちんとやらないと、プロジェクトの範囲内から外れて、何も表示されないわけだ。

さらに、レイヤーを指定しないと、やはり真っ白な画像になってしまう。

最終的な URL は以下の通り
```
https://gis-svr.vmware/i-gis/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.3.0&CRS=EPSG:6673&WIDTH=600&HEIGHT=600&BBOX=-97500,48500,-94500,51500&LAYERS=cs,isarigami,spots,tanada
```

### 9. ログの確認
問題が発生した場合は、以下のログを確認してください。

- NGINX のエラーログ: /var/log/nginx/gis-svr-error.log
- QGIS Server のログ: /var/log/gis-svr/qgis-server.log

これで、systemd を使った QGIS Server のセットアップが完了です。
必要に応じてさらに調整を行ってください！

おおー、ありがとう。

ところで、nano というのはどういうコマンドなの？

nano は、Linux や UNIX 系のシステムで使えるシンプルで軽量なテキストエディタです。
（以下省略）

nano は知らなかった。vim に慣れているので vim で行きます。

了解しました！今後は、vim を使う前提で説明します。何か他にも質問があればお気軽にどうぞ！

やってみて行き詰ったらまた尋ねます。ありがとう。

どういたしまして！ぜひ試してみてください。問題が出たらいつでも聞いてくださいね。
うまくいくことを祈っています！ 😊

## プロジェクトの切替

qgis server でプロジェクト・ファイルを指定する方法について教えて欲しい。

### Environment=QGIS_PROJECT_FILE と fastcgi_param QGIS_PROJECT_FILE

現在は、/etc/systemd/system/qgis-server.service の中で、
Environment=QGIS_PROJECT_FILE=/var/www/gis-svr/projects/i-gis/i-gis.qgz
と記述している。

一方、/etc/nginx/conf.d/gis-svr.conf の中でも
fastcgi_param QGIS_PROJECT_FILE /var/www/gis-svr/projects/i-gis/i-gis.qgz;
という記述を追加している。

この場合、どうも、後者の設定でどんなプロジェクトを設定しても、前者のプロジェクトしか有効にならないみたい。
これは、想定された動作なの？

ChatGPT:
QGIS Server における QGIS_PROJECT_FILE の指定については、以下の動作が関係しています。

#### 1. systemd 設定の優先度

/etc/systemd/system/qgis-server.service 内の環境変数 Environment=QGIS_PROJECT_FILE=... は、
QGIS Server プロセス全体の デフォルトのプロジェクト を指定します。
この設定は、QGIS Server プロセスが起動時に使用され、明示的に上書きされない限り、
このファイルがロードされます。

#### 2. NGINX の fastcgi_param の挙動

fastcgi_param QGIS_PROJECT_FILE ... は、NGINX 経由のリクエストごとに特定のプロジェクトを指定します。
ただし、これは 環境変数としてシステム全体で設定されている値を上書きしない 場合があります。

QGIS Server が systemd 環境で動作している場合、Environment に設定された値が強く適用され、
リクエストレベルで上書きすることができない可能性があります。

#### 3. 想定された動作か

この動作は 想定された動作 といえます。Environment で設定された変数は、プロセス全体で使われるため、
リクエストレベルでの変数変更を妨げる場合があります。

#### 4. 解決策

以下の方法で問題を解消できます。

##### (a) systemd の環境変数を削除

systemd の Environment=QGIS_PROJECT_FILE=... を削除することで、NGINX 経由の設定が有効になります。
以下の手順を行います：

+ /etc/systemd/system/qgis-server.service から Environment=QGIS_PROJECT_FILE=... を削除。
+ QGIS Server を再起動。

```bash
sudo systemctl daemon-reload
sudo systemctl restart qgis-server
```

この場合、NGINX の fastcgi_param でプロジェクトを動的に指定できます。

##### (b) URL パラメータでプロジェクトを指定

特定のプロジェクトを URL パラメータで指定する方法もあります。
SERVICE=WMS リクエストに MAP パラメータを付加することで、任意のプロジェクトファイルを指定可能です。

例:

```
http://yourserver.com/qgis-server?SERVICE=WMS&MAP=/var/www/gis-svr/projects/i-gis/i-gis.qgz
```
これにより、QGIS_PROJECT_FILE の設定に依存せずプロジェクトを切り替えることができます。

##### (c) システム全体のプロジェクトを変更する場合

システム全体のプロジェクトを固定したい場合は、systemd の Environment 設定をそのまま使用し、
NGINX の fastcgi_param を削除してください。これにより、すべてのリクエストで同じプロジェクトが使用されます。

#### 5. おすすめの設定方法

動的にプロジェクトを切り替える 必要がある場合は、Environment=QGIS_PROJECT_FILE を削除し、
NGINX の設定または URL パラメータで制御する方法が柔軟性が高くおすすめです。

用途に応じて設定を調整してください！

あなた:
なるほど。

### プロジェクトの動的切替

QGIS Server で複数のプロジェクトを使用する場合、動的な切替にかかるオーバーヘッドが気になるのだけれど、
その点についてはどう？ wrapfcgi を使う場合は、リクエストごとにプロセスを起動するので、
もともとオーバーヘッドが大きく、プロジェクト切替のオーバーヘッドはあんまり問題にならないと思う（この理解で合ってる？）
systemd を使うメリットは、いったん起動したプロセスを以後のリクエストでも使い続ける、
というところにあるのだと理解している。（正しい？）
systemd の設定で QGIS_PRJECT_FILE の記述を削除し、nginx の設定で動的にプロジェクトを切り替える場合、
systemd で動作している qgis server のプロセスって、どういう動きをするの？

ChatGPT:
あなたの理解は正しい点が多く、特に以下のような点で整理できます：

#### 1. fcgiwrap の場合

fcgiwrap はリクエストごとに新しいプロセスを生成して処理を行います。
そのため、プロセス起動のオーバーヘッドが大きく、プロジェクト切替のオーバーヘッドが相対的に気にならなくなります。
各リクエストが独立したプロセスとして処理されるため、QGIS_PROJECT_FILE の変更はリクエスト単位で簡単に反映されます。

#### 2. systemd を使用する場合

systemd を使用すると、QGIS Server のプロセスは 常駐プロセス として維持されます。
これにより、リクエストごとにプロセスを起動するオーバーヘッドが解消され、高速なレスポンスが期待できます（特に負荷が高い環境で有効）。

正確なメリット:
+ プロセスの再生成が不要。
+ プロセス間でキャッシュが維持される（例: プロジェクトの一部をメモリに保持）。

#### 3. NGINX で動的プロジェクト切替時の systemd プロセス挙動

systemd の設定で QGIS_PROJECT_FILE を削除し、NGINX で動的にプロジェクトを切り替えた場合、
QGIS Server の動きは以下のようになります：

+ プロセスは常駐: systemd により起動された QGIS Server プロセスは、リクエストを受け続ける限り動作を維持します。
+ 動的なプロジェクト切替の処理:
NGINX の fastcgi_param QGIS_PROJECT_FILE ... または URL パラメータの MAP に基づき、
QGIS Server はそのリクエストで必要なプロジェクトを読み込みます。
systemd によるプロセス管理では、リクエストごとにプロジェクトのロード処理が発生しますが、プロセスそのものの再生成は不要です。
+ キャッシュ効果:
同じプロジェクトを連続してリクエストする場合、プロジェクトがメモリに保持されることが多く、ロード時間が短縮されます。
プロジェクトを頻繁に切り替えると、新しいプロジェクトをロードする際に多少のオーバーヘッドが発生します。

#### 4. プロジェクト切替のオーバーヘッドは大きいか？

QGZ ファイルの解凍や、大規模なプロジェクトのロードはオーバーヘッドの原因になり得ます。
ただし、通常の使用では1～2秒以内に処理されることが多いです。

プロジェクトが非常に大きい場合、以下の工夫でオーバーヘッドを軽減できます：

+ プロジェクトを事前にメモリにロードする（systemd を使い続けるメリット）。
+ 圧縮形式 (QGZ) ではなく、非圧縮形式 (QGS) を使用する。

#### 5. おすすめの構成

複数プロジェクトを効率的に運用したい場合は以下を検討してください：

+ systemd を使用してプロセスを常駐。
+ /etc/systemd/system/qgis-server@.service のように、プロジェクトごとに systemd インスタンスを用意
（ポート番号やソケットを分ける）。
+ NGINX の設定でリクエストのパスに応じて異なるインスタンスにルーティング。
    + 例: /project1 は qgis-server@project1.service に、/project2 は qgis-server@project2.service にルーティング。

#### 結論

+ systemd を使う場合、プロセスは常駐し続けます。
+ プロジェクト切替はリクエストごとに QGIS Server が行いますが、プロセス自体は再生成されません。
+ プロジェクトの規模や切替頻度が高い場合、systemd インスタンスを分けることで負荷を分散できます。

あなた:
なるほど、なるほど。

### プロジェクトごとに qgis-server インスタンスを用意する

プロジェクトごとに systemd で起動する qgis-server インスタンスを分けておく訳だな。

/etc/systemd/system/qgis-server@.service というのの @ というのは、何かそういう記述方法があるの？

ChatGPT:
はい、@ は systemd のテンプレートユニットを定義するための特別な記法です。
テンプレートユニットを利用することで、1つの設定ファイルをもとに複数のサービスインスタンスを動的に生成できます。

#### テンプレートユニットとは？

テンプレートユニットは、@ を含む名前のユニットファイルを作成し、特定のパラメータを渡してインスタンス化できる仕組みです。

例:

+ テンプレートユニット: /etc/systemd/system/qgis-server@.service
+ インスタンス: /etc/systemd/system/qgis-server@project1.service

この仕組みによって、project1 や project2 など、複数の異なるインスタンスを簡単に管理できます。

具体例: QGIS Server 用のテンプレートユニット

#### 1. テンプレートユニットファイルの作成

以下は、/etc/systemd/system/qgis-server@.service の例です：

```ini
[Unit]
Description=QGIS Server instance for %i
After=network.target

[Service]
Type=simple
Environment=QGIS_PROJECT_FILE=/var/www/gis-svr/projects/%i/%i.qgz
Environment=QGIS_SERVER_LOG_LEVEL=0
Environment=QGIS_SERVER_LOG_FILE=/var/log/gis-svr/%i.log
ExecStart=/usr/libexec/qgis/qgis_mapserv.fcgi
Restart=on-failure
RestartSec=5
User=nginx
Group=nginx
StandardInput=socket

[Install]
WantedBy=multi-user.target
```

ポイント：
+ %i: インスタンス名（@ の後に指定された文字列）がここに展開されます。

例: qgis-server@project1.service を起動すると、%i は project1 に置き換えられます。

Environment=QGIS_PROJECT_FILE=...: プロジェクトファイルをインスタンス名に基づいて動的に指定しています。

#### 2. インスタンスの起動

例えば、project1 と project2 の2つのプロジェクトがある場合、それぞれ以下のようにインスタンスを起動できます。

```bash
sudo systemctl start qgis-server@project1.service
sudo systemctl start qgis-server@project2.service
```

#### 3. インスタンスの管理

有効化（自動起動）:
```bash
sudo systemctl enable qgis-server@project1.service
sudo systemctl enable qgis-server@project2.service
```

ステータス確認:

```bash
sudo systemctl status qgis-server@project1.service
```

停止:
```bash
sudo systemctl stop qgis-server@project1.service
```

Nginx の設定例
プロジェクトごとにリクエストを適切なインスタンスに振り分けます。

```nginx
server {
listen 80;
server_name example.com;

    location /project1/ {
        fastcgi_pass unix:/run/qgis-server-project1.sock;
        include fastcgi_params;
    }

    location /project2/ {
        fastcgi_pass unix:/run/qgis-server-project2.sock;
        include fastcgi_params;
    }
}
```

テンプレートユニットのメリット

+ 柔軟性: プロジェクトごとにプロセスを分離できる。
+ 管理の簡略化: 1つのテンプレートで複数のインスタンスを管理できる。
+ リソース分離: インスタンスごとにリソース使用状況を監視しやすい。

この方法を使うと、プロジェクトごとの動的な切替や負荷分散が非常に管理しやすくなります！

### プロジェクトごとのソケット

あなた:
この場合、ソケットは2つ用意する必要があるんだね？

ChatGPT:
はい、その通りです！
QGIS Server をプロジェクトごとに分離した systemd インスタンスで動作させる場合、
プロジェクトごとに専用のソケットを用意する必要があります。これにより、各インスタンスを独立して動作させつつ、
NGINX で適切にルーティングできるようになります。

#### 1. ソケットファイルの構成

systemd でソケットを使用する場合、以下のような構成になります。

ソケットユニット例

/etc/systemd/system/qgis-server@.socket:

```ini
[Unit]
Description=QGIS Server socket for %i
PartOf=qgis-server@%i.service

[Socket]
ListenStream=/run/qgis-server-%i.sock
SocketUser=nginx
SocketGroup=nginx
SocketMode=0660

[Install]
WantedBy=sockets.target
```

サービスユニットと連携

上記のソケットファイルは、qgis-server@.service と連携します。
PartOf=qgis-server@%i.service により、サービスが停止・開始されるとソケットも一緒に管理されます。

#### 2. インスタンスごとのソケットを起動

例えば、project1 と project2 の2つのインスタンスを設定した場合：

ソケットの起動:

```bash
sudo systemctl start qgis-server@project1.socket
sudo systemctl start qgis-server@project2.socket
```

サービスの起動（必要に応じて）:

```bash
sudo systemctl start qgis-server@project1.service
sudo systemctl start qgis-server@project2.service
```

#### 3. NGINX の設定

ソケットごとに NGINX の fastcgi_pass を設定します。

NGINX 設定例

```nginx
編集する
server {
listen 80;
server_name example.com;

    location /project1/ {
        fastcgi_pass unix:/run/qgis-server-project1.sock;
        include fastcgi_params;
    }

    location /project2/ {
        fastcgi_pass unix:/run/qgis-server-project2.sock;
        include fastcgi_params;
    }
}
```

ポイント：

fastcgi_pass unix:/run/qgis-server-project1.sock; で、各プロジェクトのソケットに接続します。

/run/ ディレクトリは一時ファイルシステムであり、ソケットファイルの置き場所として適切です。

#### 4. 自動起動の設定

各インスタンスをシステム起動時に自動起動させる場合、以下のコマンドを使用します。

```bash
sudo systemctl enable qgis-server@project1.socket
sudo systemctl enable qgis-server@project2.socket
```

これにより、システム起動時にソケットが有効化され、リクエストがあった場合に自動的に対応するサービスが起動します。

#### まとめ

プロジェクトごとに QGIS Server を分離して動作させる場合、以下が必要です：

+ プロジェクトごとの systemd サービスとソケットのセットアップ。
+ NGINX でリクエストをプロジェクトごとのソケットにルーティング。
+ リソースの独立性と動的な切替の柔軟性を確保。

この設定により、負荷が高い環境や複数プロジェクトを並行運用するケースでも安定した動作が可能になります！

### テンプレート化のメリット

あなた:
そうか、ソケットもテンプレート化できるのだ。便利だね。

ChatGPT:
その通りです！😊
systemd のテンプレートユニットはソケットにも適用できるので、プロジェクトごとに個別のソケットを用意する際にも非常に便利です。
同じ構造で複数のインスタンスを管理できるので、設定がシンプルになります。

特に以下の点で便利です：


#### 設定の一元化
1つのテンプレート (qgis-server@.service と qgis-server@.socket) を用意すれば、
インスタンス名 (%i) を変えるだけで複数のサービスやソケットを簡単に生成できます。

#### 動的管理
必要に応じて新しいプロジェクトを簡単に追加・削除できます。
たとえば、新しいプロジェクトを追加したい場合は以下のようにコマンドを実行するだけです：

```bash
sudo systemctl start qgis-server@newproject.socket
sudo systemctl start qgis-server@newproject.service
```

#### 柔軟な運用

負荷の高いプロジェクトだけ別のサーバーや高性能なマシンに移動する場合でも、
systemd のテンプレートを使えば移行がスムーズです。

#### ファイル数の削減

プロジェクトごとに個別の .service や .socket ファイルを作る必要がなくなるため、設定ファイルの管理が楽になります。

もし他にも気になる点があれば、気軽に聞いてください！
テンプレート化のアイデアをもっと広げて使いこなせるようにサポートします！ 🚀

あなた:
ありがとう。とりあえず、これで十分。

ChatGPT:
どういたしまして！😊 お役に立てて何よりです。
設定がうまくいくことを祈っています！また何か質問があれば、いつでも気軽にどうぞ。頑張ってくださいね！ 🚀





