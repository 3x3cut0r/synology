# skel

**docker-compose.yml for skel - skel is a ...**  

## Index

1. [deploy / docker-compose.yml](#deploy)  
2. [reverse-proxy / nginx configuration](#reverse-proxy)  
3. [configuration](#configuration)  
  3.1 [config-file](#config-file)  
4. [usage](#usage)  
  4.1 [browse](#browse)  

\# [Find Me](#findme)  
\# [License](#license)  

# 1. deploy / docker-compose.yml <a name="deploy"></a>  
**[see docker/docker-compose/skel/docker-compose.yml](https://github.com/3x3cut0r/synology/blob/master/docker/docker-compose/skel/docker-compose.yml)**  

# 2. reverse-proxy / nginx configuration <a name="reverse-proxy"></a>  

### 2.1 goto DSM / Control Panel / Application Portal / Advanced / Reverse-Proxy (DSM 7.x)
### 2.2 create a new Reverse-Proxy entry
**skel**  
```shell
Reverse-Proxy-Name: skel

Source:
Protocol: HTTPS
Hostname: skel.3x3cut0r.synology.me
Port: 443

Destination:
Protocol: HTTP
Hostname: 192.168.178.254 // IP of your NAS
Port: 5808 // Port of your Docker-Container
```
### 2.3 goto "Userdefined Header" and click on "Create / WebSocket"
### 2.4 Save your new created Reverse-Proxy entry

# 3. configuration <a name="configuration"></a>  

### 3.1 config-file <a name="config-file"></a>  
**/etc/skel/settings.conf**  
```shell
# ...

```

# 4. usage <a name="usage"></a>  

### 4.1 browse <a name="browse"></a>  
**Frontend**  
[https://skel.3x3cut0r.synology.me](https://skel.3x3cut0r.synology.me)  

**Backend**  
[https://skel.3x3cut0r.synology.me/admin](https://skel.3x3cut0r.synology.me/admin)  

### Find Me <a name="findme"></a>

![E-Mail](https://img.shields.io/badge/E--Mail-executor55%40gmx.de-red)
* [GitHub](https://github.com/3x3cut0r)
* [DockerHub](https://hub.docker.com/u/3x3cut0r)

### License <a name="license"></a>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) - This project is licensed under the GNU General Public License - see the [gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.
