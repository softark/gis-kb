# QGIS Web Client 2 using Docker
https://qwc-services.github.io/master/

## Docker Engine をインストール

```bash
dnf -y install dnf-plugins-core
dnf config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo
dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

docker version
docker compose version

systemctl start docker
systemctl enable docker
usermod -aG docker in-admin
```

## git をインストール

```bash
dnf install git
```

## QWC2 Docker Image を走らせる

Then, follow these steps:

Clone the qwc-docker sample setup at qwc-docker and copy the docker-compose and api-gateway configuration templates:

```bash
git clone https://github.com/qwc-services/qwc-docker.git
cd qwc-docker
cp docker-compose-example.yml docker-compose.yml
cp api-gateway/nginx-example.conf api-gateway/nginx.conf
```

Set the password for the postgres superuser in docker-compose.yml:

```
qwc-postgis:
  image: sourcepole/qwc-base-db:<version>
  environment:
    POSTGRES_PASSWORD: '<SET YOUR PASSWORD HERE>'
```

Create a secret key:

```bash
python3 -c 'import secrets; print("JWT_SECRET_KEY=\"%s\"" % secrets.token_hex(48))' >.env
```

Change the UID/GID which runs the QWC services to match the user/group which owns the shared volumes on the host by setting SERVICE_UID and SERVICE_GID in qwc-docker/docker-compose.yml.

Set permissions for the shared solr data volume:

```bash
sudo chown 8983:8983 volumes/solr/data
```

Start all containers (will download all images from dockerhub when executed the first time):

```bash
docker compose up
```

Note: If using the newer docker compose project, you need to write docker compose up instead of docker-compose up (and similarly for other docker-compose calls).

Note: The sample docker-compose-example.yml uses latest-YYYY-lts as image versions. It is recommended to replace these with a fix version tag when deploying the application to prevent docker from automatically pulling new versions when the application is launched, which may be undesired. See Keeping QWC services up to date.

The map viewer will run on http://localhost:8088/.

The admin GUI will run on http://localhost:8088/qwc_admin (default admin credentials: username admin, password admin, requires password change on first login).
