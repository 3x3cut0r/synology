# Portainer

**docker-compose.yml for portainer**  

## Index

1. [docker run portainer-temp](#docker_run)  
2. [reverse-proxy / nginx configuration](#reverse-proxy)  
3. [download portainer.env](#portainer.env)  
4. [deploy docker-compose.yml stack using portainer-temp](#deploy)  
5. [remove portainer-temp](#remove_portainer)  
6. [usage](#usage)  
  6.1 [browse](#browse)  

\# [Find Me](#findme)  
\# [License](#license)  

### 1. docker run portainer-temp <a name="docker_run"></a>  
**you need to run a temporarily portainer instance because you cannot**  
**create a portainer stack inside it is own instance**  
**it is only for cosmetic reasons**  
**you cannot change the portainer stack anyway!**  
```shell
docker container run -d --restart=always \
    --name=portainer-temp \
    --network=portainer \
    --ip=10.24.1.3 \
    -p 3101:9000 \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /volume1/docker/portainer:/data \
    portainer/portainer-ce:alpine

```

# 2. reverse-proxy / nginx configuration <a name="reverse-proxy"></a>  

### 2.1 goto DSM / Control Panel / Application Portal / Advanced / Reverse-Proxy (DSM 7.x)
### 2.2 create a new Reverse-Proxy entry
**portainer**  
```shell
Reverse-Proxy-Name: portainer

Source:
Protocol: HTTPS
Hostname: portainer.3x3cut0r.synology.me
Port: 443

Destination:
Protocol: HTTP
Hostname: 192.168.178.254 // IP of your NAS
Port: 3101 // Port of your Docker-Container
```
### 2.3 goto "Userdefined Header" and click on "Create / WebSocket"
### 2.4 Save your new created Reverse-Proxy entry

# 3. download portainer.env <a name="portainer.env"></a>  
**copy and replace from repo**  
```shell
wget -q https://raw.githubusercontent.com/3x3cut0r/synology/master/docker/docker-compose/portainer/portainer.env -O /volume1/docker/portainer/env-files/portainer.env

```

# 4. deploy docker-compose.yml stack using portainer-temp <a name="deploy"></a>  
**Frontend**  
[https://portainer.3x3cut0r.synology.me](https://portainer.3x3cut0r.synology.me)  
**[see docker/docker-compose/portainer/docker-compose.yml](https://github.com/3x3cut0r/synology/blob/master/docker/docker-compose/portainer/docker-compose.yml)**  
**hint: once deployed ... you cannot change the portainer stack using portainer!**  
**you need to redeploy it using portainer-temp instance again!**  

# 5. remove portainer-temp <a name="remove_portainer"></a>
```shell
docker container rm -f portainer-temp

```

# 6. usage <a name="usage"></a>  

### 6.1 browse <a name="browse"></a>  
**Frontend**  
[https://portainer.3x3cut0r.synology.me](https://portainer.3x3cut0r.synology.me)  

### Find Me <a name="findme"></a>

![E-Mail](https://img.shields.io/badge/E--Mail-executor55%40gmx.de-red)
* [GitHub](https://github.com/3x3cut0r)
* [DockerHub](https://hub.docker.com/u/3x3cut0r)

### License <a name="license"></a>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) - This project is licensed under the GNU General Public License - see the [gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.
