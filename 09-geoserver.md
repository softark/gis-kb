# GeoServer

Documentation : https://docs.geoserver.org/

## Installation

https://docs.geoserver.org/stable/en/user/installation/linux.html

### Java runtime

```shell
sudo dnf install java
```

上記で java 17 がインストールされる。

### geoserver-2.26.1-bin.zip

```shell
sudo unzip geoserver-2.26.1-bin.zip -d /usr/share/geoserver
sudo chown -R USER_NAME /usr/share/geoserver/
```

```shell
echo "export GEOSERVER_HOME=/usr/share/geoserver" >> ~/.bash_profile
. ~/.bash_profile
```

### firewall

```shell
sudo firewall-cmd --add-service=http --permanent
sudo firewall-cmd --add-service=https --permanent
sudo firewall-cmd --add-port=8080/tcp --permanent
sudo firewall-cmd --reload
```

```shell
cd geoserver/bin
sh startup.sh
```

http://gis.vmware:8080/geoserver にアクセス