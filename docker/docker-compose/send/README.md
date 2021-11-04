# send

**docker-compose.yml for mozilla send**  

## Index

1. [deploy / docker-compose.yml](#deploy)  
2. [reverse-proxy / nginx configuration](#reverse-proxy)  
3. [usage](#usage)  
  3.1 [browse](#browse)  

\# [Find Me](#findme)  
\# [License](#license)  

# 1. deploy / docker-compose.yml <a name="deploy"></a>  
**[see docker/docker-compose/send/docker-compose.yml](https://github.com/3x3cut0r/synology/blob/master/docker/docker-compose/send/docker-compose.yml)**  

# 2. reverse-proxy / nginx configuration <a name="reverse-proxy"></a>  

### 2.1 goto DSM / Control Panel / Application Portal / Advanced / Reverse-Proxy (DSM 7.x)
### 2.2 create a new Reverse-Proxy entry
**send**  
```shell
Reverse-Proxy-Name: send

Source:
Protocol: HTTPS
Hostname: send.3x3cut0r.synology.me
Port: 443

Destination:
Protocol: HTTP
Hostname: 192.168.178.254 // IP of your NAS
Port: 1443 // Port of your Docker-Container
```
### 2.3 goto "Userdefined Header" and click on "Create / WebSocket"
### 2.4 Save your new created Reverse-Proxy entry

# 3. usage <a name="usage"></a>  

### 3.1 browse <a name="browse"></a>  
**Frontend**  
[https://send.3x3cut0r.synology.me](https://send.3x3cut0r.synology.me)  

### Find Me <a name="findme"></a>

![E-Mail](https://img.shields.io/badge/E--Mail-executor55%40gmx.de-red)
* [GitHub](https://github.com/3x3cut0r)
* [DockerHub](https://hub.docker.com/u/3x3cut0r)

### License <a name="license"></a>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) - This project is licensed under the GNU General Public License - see the [gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.
