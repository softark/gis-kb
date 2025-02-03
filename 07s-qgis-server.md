# QGIS Server まとめ

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

## ファイアウォール

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

AlmaLinux 9 では、dnf でインストール出来る。

crb レポジトリを有効にする。

```bash
# dnf config-manager --enable crb
```

/etc/yum.repos.d/almalinux-crb.repo を編集しても良い。

dnf でインストール。

```editorconfig
# dnf list *qgis*
# dnf install qgis-server
```

/usr/bin に以下がインストールされる

- qgis (QGIS Desktop)
- qgis_mapserver (QGIS Map Server)
- qgis_process (QGIS Processing Executor)

/usr/libexec/qgis に以下がインストールされる

- qgis_mapserv.fcgi

## Systemd を使用する nginx 設定

https://docs.qgis.org/3.34/en/docs/server_manual/getting_started.html は
Debian ベースのシステムのための説明だが、nginx で qgis server を動かす場合、
3つの選択肢があると言っている。

1. fcgi
   1. spawn-fcgi,
   2. fcgiwrap,
2. systemd

fcgi を使う場合、fcgiwrap は簡単だけど遅いので運用サーバでは spawn-fcgi をお奨めするとのこと。
さらにより良いのは systemd を使うやり方らしい。この説明を AlmaLinux 9 に当て嵌めて、systemd でやりたい。

以下は、AlmaLinux 9 で NGINX と systemd を使って QGIS Server をセットアップする手順。

プロジェクトの動的切替えが出来るように、systemd のテンプレート・ユニット
を使った設定にする。

### 1. Systemd サービスファイルの作成
QGIS Server を systemd で直接起動するためのユニットファイルを作成します。

```[bash]
sudo vi /etc/systemd/system/qgis-server@.service
```

以下を内容として保存。

```[ini]
[Unit]
Description=QGIS Server instance for %i
After=network.target

[Service]
Type=simple
# プロジェクト・ファイルは nginx の設定で指定する
# Environment=QGIS_PROJECT_FILE=/var/www/gis-svr/projects/%i/%i.qgs
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

ログファイルの保存場所として /var/log/gis-svr のディレクトリを作成する。
このディレクトリを nginx から書き込み可能に設定しておく。

```[basho]
sudo mkdir /var/log/gis-svr
sudo chmod 777 /var/log/gis-svr
```

### 2. Systemd ソケットファイルの作成
QGIS Server にリクエストを転送するソケットを作成。

```[bash]
sudo vi /etc/systemd/system/qgis-server.socket
```

```[ini]
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

### 3. サービスとソケットの有効化と起動
systemd の設定をリロードし、ソケットを有効化して起動。

```[bash]
sudo systemctl daemon-reload
sudo systemctl enable qgis-server@i-gis.socket
sudo systemctl start qgis-server@i-gis.socket
sudo systemctl enable qgis-server@i-gis-test.socket
sudo systemctl start qgis-server@i-gis-test.socket
```

"i-gis" がテンプレート・ユニットに渡されるパラメータ。

qgis-server@i-gis.service は qgis-server@i-gis.socket 
によって起動されるのでここで起動する必要は無い。

ソケットが正しく起動していることを確認。

```[bash]
sudo systemctl status qgis*
```

ソケットファイル /run/qgis-server-i-gis.sock および
/run/qgis-server-i-gis-test.sock が存在しているか確認。

### 4. NGINX の設定

次に、NGINX を設定して QGIS Server と連携させる。

```[bash]
sudo vi /etc/nginx/conf.d/gis-svr.conf
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
        fastcgi_pass unix:/run/qgis-server-i-gis.sock;
        fastcgi_param SCRIPT_FILENAME /usr/libexec/qgis/qgis_mapserv.fcgi;
        fastcgi_param QGIS_PROJECT_FILE /var/www/gis-svr/projects/i-gis/i-gis.qgs;
    }

    location /i-gis-test/ {
        include fastcgi_params;
        fastcgi_pass unix:/run/qgis-server-i-gis-test.sock;
        fastcgi_param SCRIPT_FILENAME /usr/libexec/qgis/qgis_mapserv.fcgi;
        fastcgi_param QGIS_PROJECT_FILE /var/www/gis-svr/projects/i-gis/i-gis-test.qgs;
    }

    error_log /var/log/nginx/gis-svr-error.log;
    access_log /var/log/nginx/gis-svr-access.log;

    ssl_certificate /etc/pki/tls/certs/vmware.crt;
    ssl_certificate_key /etc/pki/tls/certs/vmware.key;
}
````

### 5. NGINX の再起動

設定をテストして NGINX を再起動。

```[bash]
sudo nginx -t
sudo systemctl restart nginx
```

### 6. SELinux の設定 (必要な場合)

SELinux を有効にしている場合は、ソケットとプロジェクトファイルへのアクセスを許可する必要があります。

```[bash]
sudo setsebool -P httpd_can_network_connect 1
sudo chcon -R -t httpd_sys_content_t /path/to/your/project.qgs
sudo chcon -t httpd_sys_rw_content_t /run/qgis-server.sock
```

### 7. 動作確認
ブラウザで以下の URL にアクセスして動作を確認。

```
https://gis-svr.vmware/i-gis/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.3.0&CRS=EPSG:6673&WIDTH=600&HEIGHT=600
```

ん？ Internal Server Error？

Ivalid map settings ???

BBOX のパラメータが必要と言うことらしい。

BBOX パラメータを追加するとエラーは出なくなったが、真っ白な四角形が表示されるだけ。
BBOX の設定をきちんとやらないと、プロジェクトの範囲内から外れて、何も表示されないわけだ。

レイヤーを指定しないと、やはり真っ白な画像になってしまう。

最終的な動作確認用の URL は以下の通り
```url
http://gis.vmware/i-gis/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.3.0&CRS=EPSG:6673&WIDTH=600&HEIGHT=600&BBOX=-97500,48500,-94500,51500&LAYERS=g-satellite,cs,isarigami,spots,tanada
http://gis.vmware/i-gis-test/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.3.0&CRS=EPSG:6673&WIDTH=600&HEIGHT=600&BBOX=-97500,48500,-94500,51500&LAYERS=gsijp-std,cs,isarigami,spots,tanada
```

WMS Version 1.1.1 の場合は以下の通り
```url
http://gis.vmware/i-gis/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&SRS=EPSG:6673&WIDTH=600&HEIGHT=600&BBOX=48500,-97500,51500,-94500&LAYERS=g-satellite,cs,isarigami,spots,tanada
http://gis.vmware/i-gis-test/?SERVICE=WMS&REQUEST=GetMap&VERSION=1.1.1&SRS=EPSG:6673&WIDTH=600&HEIGHT=600&BBOX=48500,-97500,51500,-94500&LAYERS=gsijp-std,cs,isarigami,spots,tanada
```
Version 1.1.1 では、CRS でなく SRS、BBOX は ymin,xmin,ymax,xmax でなく xmin,ymin,xmax,ymax

MapCache では、Version 1.1.1 を使う。


### 8. ログの確認

問題が発生した場合は、以下のログを確認。

- NGINX のエラーログ: /var/log/nginx/gis-svr-error.log
- QGIS Server のログ: /var/log/gis-svr/{project_name}.log

これで、systemd を使った QGIS Server のセットアップが完了。
