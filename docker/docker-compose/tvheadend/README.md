# TvHeadend

**docker-compose.yml for tvheadend and oscam**  

## Index

1. [deploy / docker-compose.yml](#deploy)  
2. [usage](#usage)  
  2.1 [browse](#browse)  
3. [channels.m3u download](#channels.m3u)  

\# [Find Me](#findme)  
\# [License](#license)  

# 1. deploy / docker-compose.yml <a name="deploy"></a>  
**[see docker/docker-compose/tvheadend/docker-compose.yml](https://github.com/3x3cut0r/synology/blob/master/docker/docker-compose/tvheadend/docker-compose.yml)**  

# 2. usage <a name="usage"></a>  

### 2.1 browse <a name="browse"></a>  
**Backend**  
[https://3x3cut0r.synology.me:9981](https://3x3cut0r.synology.me:9981)  

# 3. channels.m3u download <a name="channels.m3u"></a>  
**pass**
```shell
wget --user=tvh --password=<TVH_PASSWORD> http://3x3cut0r.synology.me:9981/playlist/channels.m3u?profile=pass

```
**htsp**
```shell
wget --user=tvh --password=<TVH_PASSWORD> http://3x3cut0r.synology.me:9981/playlist/channels.m3u?profile=htsp

```

### Find Me <a name="findme"></a>

![E-Mail](https://img.shields.io/badge/E--Mail-executor55%40gmx.de-red)
* [GitHub](https://github.com/3x3cut0r)
* [DockerHub](https://hub.docker.com/u/3x3cut0r)

### License <a name="license"></a>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) - This project is licensed under the GNU General Public License - see the [gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.
