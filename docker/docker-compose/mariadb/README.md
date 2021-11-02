# MariaDB

**docker-compose.yml for MariaDB and PhpMyAdmin**  

## Index

1. [mariadb configuration](#mariadb_configuration)  
  1.1 [50-server.cnf](#50-server.cnf)  
  1.2 [OPTIONAL: database security](#database_security)  
2. [phpmyadmin configuration](#phpmyadmin_configuration)  
  2.1 [php.ini](#php.ini)  
  2.2 [config.user.inc.php](#config.user.inc.php)  
3. [deploy / docker-compose.yml](#deploy)  
4. [reverse-proxy / nginx configuration](#reverse-proxy)  
5. [usage](#usage)  
  5.1 [browse](#browse)  

\# [Find Me](#findme)  
\# [License](#license)  

# 1. mariadb configuration <a name="mariadb_configuration"></a>  

### 1.1 50-server.cnf <a name="50-server.cnf"></a>  
**copy and replace from repo**  
```shell
wget -q https://raw.githubusercontent.com/3x3cut0r/synology/master/docker/docker-compose/mariadb/50-server.cnf -O /volume1/docker/mariadb/conf/50-server.cnf

```

**OR modify /volume1/docker/mariadb/conf/50-server.cnf:**
```shell
...
skip-name-resolve

key_buffer_size        = 1G
max_allowed_packet     = 1G
thread_stack           = 192K
thread_cache_size      = 128
max_connections        = 100
table_cache            = 128
tmp_table_size         = 1G
max_heap_table_size    = 1G

expire_logs_days        = 10
max_binlog_size         = 100M

character-set-server  = utf8mb4
collation-server      = utf8mb4_general_ci

innodb_buffer_pool_size = 8G

```

**restart mariadb**  

# 1.2. OPTIONAL: database security <a name="database_security"></a>  
**download and exec mysqltuner.pl to check your database security:**  
[mysqltuner.pl on GitHub](https://github.com/major/MySQLTuner-perl)  

# 2. phpmyadmin configuration <a name="phpmyadmin_configuration"></a>  

### 2.1 php.ini <a name="php.ini"></a>  
**copy and replace from repo**  
```shell
wget -q https://raw.githubusercontent.com/3x3cut0r/synology/master/docker/docker-compose/mariadb/phpmyadmin/php.ini -O /volume1/docker/phpmyadmin/php.ini

```

### 2.2 config.user.inc.php <a name="config.user.inc.php"></a>  
**copy and replace from repo**  
```shell
wget -q https://raw.githubusercontent.com/3x3cut0r/synology/master/docker/docker-compose/mariadb/phpmyadmin/config.user.inc.php -O /volume1/docker/phpmyadmin/config.user.inc.php

```

# 3. deploy / docker-compose.yml <a name="deploy"></a>  
**[see docker/docker-compose/mariadb/docker-compose.yml](https://github.com/3x3cut0r/synology/blob/master/docker/docker-compose/mariadb/docker-compose.yml)**  

# 4. reverse-proxy / nginx configuration <a name="reverse-proxy"></a>  

### 4.1 goto DSM / Control Panel / Application Portal / Advanced / Reverse-Proxy (DSM 7.x)
### 4.2 create a new Reverse-Proxy entry
**phpmyadmin**  
```shell
Reverse-Proxy-Name: phpmyadmin

Source:
Protocol: HTTPS
Hostname: phpmyadmin.3x3cut0r.synology.me
Port: 443

Destination:
Protocol: HTTP
Hostname: 192.168.178.254 // IP of your NAS
Port: 2200 // Port of your Docker-Container
```
### 4.3 goto "Userdefined Header" and click on "Create / WebSocket"
### 4.4 Save your new created Reverse-Proxy entry

# 5. usage <a name="usage"></a>  

### 5.1 browse <a name="browse"></a>  
**Backend - PhpMyAdmin**  
[https://phpmyadmin.3x3cut0r.synology.me](https://phpmyadmin.3x3cut0r.synology.me)  

### Find Me <a name="findme"></a>

![E-Mail](https://img.shields.io/badge/E--Mail-executor55%40gmx.de-red)
* [GitHub](https://github.com/3x3cut0r)
* [DockerHub](https://hub.docker.com/u/3x3cut0r)

### License <a name="license"></a>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) - This project is licensed under the GNU General Public License - see the [gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.
