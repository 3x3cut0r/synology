# Yacht

# 1. create new postgres user and database: yacht
**user:**  
```shell
General:
  Name: yacht

Definition:
  Password: <YACHT_POSTGRES_PASSWORD>
  Connection Limit: -1

Priviledges:
  Can login?: Yes

```
**database:**  
```shell
General:
  Database: yacht
  Owner: yacht

Definition:
  Encoding: UTF8
  Template: postgres
  Tablespace: pg_default
  Collation: en_US.utf8
  Character type: en_US.utf8
  Connection Limit: -1

```

# 2. deploy docker-compose.yml

# 3. configure your nginx reverse proxy
**see: [yacht.conf](https://github.com/3x3cut0r/vps/blob/main/docker/docker-compose/nginx/conf.d/yacht.conf)**

# 4. login with your email and change the default password !!!
**default password: pass**

### Find Me <a name="findme"></a>

![E-Mail](https://img.shields.io/badge/E--Mail-executor55%40gmx.de-red)
* [GitHub](https://github.com/3x3cut0r)
* [DockerHub](https://hub.docker.com/u/3x3cut0r)

### License <a name="license"></a>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) - This project is licensed under the GNU General Public License - see the [gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.
