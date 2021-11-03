# Nextcloud

**docker-compose.yml for nextcloud - nextcloud is a ...**  

## Index

3. [configuration](#configuration)  
  1.1 [download php-filesize.ini](#php-filesize.ini)  
  2.1 [download 000-default.conf](#000-default.conf)  
2. [deploy / docker-compose.yml](#deploy)  
3. [reverse-proxy / nginx configuration](#reverse-proxy)  
4. [usage](#usage)  
  4.1 [browse](#browse)  
5. [optimize](#optimize)  
  5.1 [maintenance mode](#maintenance)  
  5.2 [disable app richdocumentscode](#richdocumentscode)  

\# [Find Me](#findme)  
\# [License](#license)  

# 1. configuration <a name="configuration"></a>  

# 1.1 download php-filesize.ini <a name="php-filesize.ini"></a>  
**copy and replace from repo**  
```shell
mkdir -p /home/docker/config-files/nextcloud
wget -q https://raw.githubusercontent.com/3x3cut0r/synology/main/docker/docker-compose/nextcloud/php-filesize.ini -O /volume1/docker/nextcloud/php-filesize.ini

```

# 2.1 download 000-default.conf <a name="000-default.conf"></a>  
**copy and replace from repo**  
```shell
mkdir -p /home/docker/config-files/nextcloud
wget -q https://raw.githubusercontent.com/3x3cut0r/synology/main/docker/docker-compose/nextcloud/000-default.conf -O /volume1/docker/nextcloud/sites-available/000-default.conf

```

# 2. deploy / docker-compose.yml <a name="deploy"></a>  
**[see docker/docker-compose/nextcloud/docker-compose.yml](https://github.com/3x3cut0r/synology/blob/master/docker/docker-compose/nextcloud/docker-compose.yml)**  

# 3. reverse-proxy / nginx configuration <a name="reverse-proxy"></a>  

### 3.1 goto DSM / Control Panel / Application Portal / Advanced / Reverse-Proxy (DSM 7.x)
### 3.2 create a new Reverse-Proxy entry
**nextcloud**  
```shell
Reverse-Proxy-Name: nextcloud

Source:
Protocol: HTTPS
Hostname: nextcloud.3x3cut0r.synology.me
Port: 443

Destination:
Protocol: HTTP
Hostname: 192.168.178.254 // IP of your NAS
Port: 2210 // Port of your Docker-Container
```
### 3.3 goto "Userdefined Header" and click on "Create / WebSocket"
### 3.4 Save your new created Reverse-Proxy entry

# 4. usage <a name="usage"></a>  

### 4.1 browse <a name="browse"></a>  
**Frontend**  
[https://nextcloud.3x3cut0r.synology.me](https://nextcloud.3x3cut0r.synology.me)  

# 5. optimize <a name="optimize"></a>  

### 5.1 maintenance mode <a name="maintenance"></a>  
```shell
docker container exec -u www-data -it nextcloud php occ maintenance:mode --on
docker container exec -u www-data -it nextcloud php occ maintenance:mode --off
```

### 5.2 disable app richdocumentscode (makes nextcloud fast again) <a name="richdocumentscode"></a>  
```shell
docker exec -u www-data nextcloud php occ app:disable richdocumentscode

```

### 5.3 config.php <a name="config.php"></a>  
**make sure these settings are set in your config/config.php**  
**you need to do this as root**  
```shell
<?php
$CONFIG = array (
  ...
  'redis' =>
  array (
    'host' => 'redis',
    'password' => '<REDIS_PASSWORD>',
    'port' => 6379,
  ),
  ...
  'trusted_proxies' =>
  array (
   	0 => '192.168.178.254'
  ),
  ...
  'trusted_domains' =>
  array (
    0 => 'nextcloud.3x3cut0r.synology.me',
  ),
  ...
  'overwriteprotocol' => 'https',
  'overwritehost' => 'nextcloud.3x3cut0r.synology.me',
  'overwrite.cli.url' => 'https://nextcloud.3x3cut0r.synology.me',
  ...
  'filelocking.enabled\' => 'true',
  'onlyoffice' =>
  array (
    'verify_peer_off' => true,
  ),
  'loglevel' => 2,
  'logdateformat' => 'Y-m-d:H:m:s',
  'default_locale' => 'de_DE',
  'default_phone_region' => 'DE',
  'maintenance' => false,
  ...

```

### Find Me <a name="findme"></a>

![E-Mail](https://img.shields.io/badge/E--Mail-executor55%40gmx.de-red)
* [GitHub](https://github.com/3x3cut0r)
* [DockerHub](https://hub.docker.com/u/3x3cut0r)

### License <a name="license"></a>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) - This project is licensed under the GNU General Public License - see the [gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.
