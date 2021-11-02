# MariaDB

# 1. deploy docker-compose.yml

# 2. fine-tune 50-server.cnf configuration
**copy and replace from repo**  
```shell
wget -q https://raw.githubusercontent.com/3x3cut0r/synology/main/docker/docker-compose/mariadb/50-server.cnf -O /volume1/docker/mariadb/conf/50-server.cnf

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

# 3. restart mariadb
```shell
docker container restart mariadb

```

# 4. database security
**download and exec mysqltuner.pl to check your database security:**  
[mysqltuner.pl on GitHub](https://github.com/major/MySQLTuner-perl)  

### Find Me <a name="findme"></a>

![E-Mail](https://img.shields.io/badge/E--Mail-executor55%40gmx.de-red)
* [GitHub](https://github.com/3x3cut0r)
* [DockerHub](https://hub.docker.com/u/3x3cut0r)

### License <a name="license"></a>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) - This project is licensed under the GNU General Public License - see the [gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.
