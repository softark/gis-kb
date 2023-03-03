# GeoServer

## 1. インストール

geoserver.org > Documentation > User Manual > Installation に従う

### 1.1 java をインストールする

```
# dnf install java-17
```

### 1.2 GeoServer をインストール

geoserver.org > Downloads

GeoServer 2.22.2 をダウンロードして、`/usr/share/geoserver` に展開する

`/usr/share/geoserver` 以下を geoserver 実行ユーザーの所有とする

```
# dnf install -y wget unzip

# cd /tmp
# wget http://sourceforge.net/projects/geoserver/files/GeoServer/2.22.2/geoserver-2.22.2-bin.zip

# mkdir /usr/share/geoserver
# unzip -d /usr/share/geoserver/ geoserver-2.22.2-bin.zip

# useradd -m -U -d /usr/share/geoserver -s /bin/false geoserver
# chown -R geoserver:geoserver /usr/share/geoserver

```

### 1.3 ファイアウォール設定

```
# firewall-cmd --permanent --add-port=8080/tcp
# firewall-cmd --reload
```

### 1.4 サービスの起動・停止設定

geoserver をサービスとして起動・停止するための `/usr/lib/systemd/system/geoserver.service` を作成する

```
# cd /usr/lib/systemd/system
# vi geoserver.service
```

```
Description=GeoServer Service
After=network.target

[Service]
Type=simple

User=geoserver
Group=geoserver

Environment="GEOSERVER_HOME=/usr/share/geoserver"

ExecStart=/usr/share/geoserver/bin/startup.sh
ExecStop=/usr/share/geoserver/bin/shutdown.sh

[Install]
WantedBy=multi-user.target
```

サービスを有効にする

```
# systemctl daemon-reload
# systemctl enable --now geoserver.service
```

サービスを起動

```
# systemctl start geoserver
```

### 1.5 テスト

`http://softark.net:8080/geoserver/` にアクセス出来ることを確認する

### 1.6 既存ウェブのサブディレクトリとして設定する

`/etc/nginx/conf.d/????.conf`

```
server {
    charset utf-8;
    client_max_body_size 128M;

    listen 443 ssl http2; ## listen for ipv4
    #listen [::]:80 default_server ipv6only=on; ## listen for ipv6

    server_name ????.softark.net;
    root        /var/www/????/web;
    index       index.php;

    access_log  /var/log/nginx/????_access.log;
    error_log   /var/log/nginx/????_error.log;

    location ^~ /geoserver {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $http_host;
        proxy_set_header X-Forwarded-Proto http;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://127.0.0.1:8080/geoserver;
    }
    location / {
        try_files $uri $uri/ /index.php$is_args$args;
    }
    ...
}
```

これと同時に、`http://softark.net:8080/geoserver/` からアクセスして、ログインし、プロキシベースURLを設定しておく必要がある。

設定 > グローバル > プロキシベースURL ... `https://????.softark.net/geoserver`

これをしないと、ログイン機能がうまく動かない。

### 1.7 テスト2

`https://????.softark.net/geoserver/` にアクセス出来ることを確認する

