# Umbrel

[umbrel](https://getumbrel.com/) - run your personal bitcoin node  
umbrel was adjusted here so that it runs on a virtual private server  

## Index

1. [prepare volume](#volume)  
2. [download config-files](#download-config-files)  
3. [prepare config-files](#prepare-config-files)  
4. [get hidden_service_url](#get-hidden_service_url)  
5. [change umbrel permissions](#change-umbrel-permissions)  
6. [deploy docker-compose.yml](#deploy-docker-compose)  
7. [configure umbrel using tor browser](#configure-umbrel)  
8. [wait bitcoind to be syned](#bitcoind-sync)  

\# [Find Me](#findme)  
\# [License](#license)  

# 1. prepare volume <a name="volume"></a>
**change UMBREL_ROOT to your needs**
```shell
UMBREL_ROOT=/volume1/docker/umbrel
DEVICE_HOSTNAME="umbrel.3x3cut0r.synology.me"
mkdir -p $UMBREL_ROOT
cd $UMBREL_ROOT
wget -p https://github.com/getumbrel/umbrel/archive/master.zip -O master.zip
unzip master.zip
mv umbrel-master/* .
rm -rf master.zip umbrel-master
mkdir -p $UMBREL_ROOT/db/jwt-public-key
mkdir -p $UMBREL_ROOT/db/jwt-private-key

```

# 2. download config-files <a name="download-config-files"></a>
```shell
wget -p https://raw.githubusercontent.com/3x3cut0r/synology/main/docker/docker-compose/umbrel/tor/torrc -O $UMBREL_ROOT/tor/torrc
wget -p https://raw.githubusercontent.com/3x3cut0r/synology/main/docker/docker-compose/umbrel/bitcoin/bitcoin.conf -O $UMBREL_ROOT/bitcoin/bitcoin.conf
wget -p https://raw.githubusercontent.com/3x3cut0r/synology/main/docker/docker-compose/umbrel/lnd/lnd.conf -O $UMBREL_ROOT/lnd/lnd.conf
wget -p https://raw.githubusercontent.com/3x3cut0r/synology/main/docker/docker-compose/umbrel/nginx/nginx.conf -O $UMBREL_ROOT/nginx/nginx.conf
wget -p https://raw.githubusercontent.com/3x3cut0r/synology/main/docker/docker-compose/umbrel/electrs/electrs.toml -O $UMBREL_ROOT/electrs/electrs.toml
wget -p https://raw.githubusercontent.com/3x3cut0r/synology/main/docker/docker-compose/umbrel/docker-compose.yml -O $UMBREL_ROOT/docker-compose.yml
wget -p https://raw.githubusercontent.com/3x3cut0r/synology/main/docker/docker-compose/umbrel/.env -O $UMBREL_ROOT/.env

```

# 3. prepare config-files <a name="prepare-config-files"></a>
**tor:**
```shell
TOR_PASSWORD=$($UMBREL_ROOT/scripts/rpcauth.py "itdoesntmatter" | tail -1)
TOR_HASHED_PASSWORD=$(docker run --rm getumbrel/tor:latest --quiet --hash-password "$TOR_PASSWORD")
sed -i s/#HashedControlPassword\ 16:872860B76453A77D60CA2BB8C1A7042072093276A3D701AD684053EC4C/HashedControlPassword\ $TOR_HASHED_PASSWORD/g $UMBREL_ROOT/tor/torrc

```
**bitcoin:**
```shell
BITCOIN_RPC_DETAILS=$($UMBREL_ROOT/scripts/rpcauth.py umbrel)
BITCOIN_RPC_PASS=$(echo "$BITCOIN_RPC_DETAILS" | tail -1)
BITCOIN_RPC_AUTH=$(echo "$BITCOIN_RPC_DETAILS" | head -2 | tail -1 | sed -e "s/^rpcauth=//")
sed -i s/rpcauth=charlie\:b3508846e1e7f8899ddbbd80dac4ded8\$98dcf22145ea56a240f7dcef408ad2d82a2d839aa73ebabfee13f1d48be098ed/rpcauth=$BITCOIN_RPC_AUTH/g $UMBREL_ROOT/bitcoin/bitcoin.conf

```
**lnd:**
```shell
sed -i s/\;\ bitcoind.rpcpass=kek/bitcoind.rpcpass=$BITCOIN_RPC_PASS/g $UMBREL_ROOT/lnd/lnd.conf
sed -i s/\;\ tor.password=plsdonthackme/tor.password=$TOR_PASSWORD/g $UMBREL_ROOT/lnd/lnd.conf

```
**docker-compose.yml:**
```shell
sed -i s/\<BITCOIN_RPC_PASSWORD\>/\"$BITCOIN_RPC_PASS\"/g $UMBREL_ROOT/docker-compose.yml
sed -i s#/var/run/docker.sock\:/var/run/docker.sock#/run/user/$(id -u)/docker.sock\:/var/run/docker.sock#g $UMBREL_ROOT/docker-compose.yml
sed -i s#/volume1/docker/umbrel#$UMBREL_ROOT#g $UMBREL_ROOT/docker-compose.yml
sed -i s#/usr/local/bin/docker\:/usr/bin/docker#$(which docker):/usr/bin/docker#g $UMBREL_ROOT/docker-compose.yml
sed -i s#DEVICE_HOSTNAME=\"umbrel.3x3cut0r.synology.me\"#DEVICE_HOSTNAME=\"$DEVICE_HOSTNAME\"#g $UMBREL_ROOT/docker-compose.yml

```
**.env:**
```shell
sed -i s/BITCOIN_RPC_PASS=\<password\>/BITCOIN_RPC_PASS=\"$BITCOIN_RPC_PASS\"/g $UMBREL_ROOT/.env
sed -i s/BITCOIN_RPC_AUTH=\<rpcauth\>/BITCOIN_RPC_AUTH=\"$BITCOIN_RPC_AUTH\"/g $UMBREL_ROOT/.env
sed -i s/TOR_PASSWORD=\<password\>/TOR_PASSWORD=\"$TOR_PASSWORD\"/g $UMBREL_ROOT/.env
sed -i s/TOR_HASHED_PASSWORD=\<password\>/TOR_HASHED_PASSWORD=\"$TOR_HASHED_PASSWORD\"/g $UMBREL_ROOT/.env
sed -i s#DOCKER_BINARY=\<path\>#DOCKER_BINARY=\"$(which docker)\"#g $UMBREL_ROOT/.env

```
**statuses:**
```shell
touch "$UMBREL_ROOT/statuses/configured"
touch "$UMBREL_ROOT/statuses/node-status-bitcoind-ready"

```

# 4. get hidden_service_url <a name="get-hidden_service_url"></a>
**start tor:**  
```shell
sudo chmod 777 -R $UMBREL_ROOT/tor

docker network create \
    --driver=bridge \
    --subnet=10.21.21.0/24 \
    --gateway=10.21.21.1 \
    umbrel

docker container run -d --restart=unless-stopped \
    --name=umbrel-tor \
    --network=umbrel \
    --ip=10.21.21.11 \
    -v $UMBREL_ROOT/tor/torrc:/etc/tor/torrc \
    -v $UMBREL_ROOT/tor/data:/var/lib/tor/ \
    -v $UMBREL_ROOT/tor/run:/var/run/tor/ \
    lncm/tor:latest

```
**save hidden_service_url to DEVICE_HOSTS:**  
```shell
hidden_service_url=$(sudo cat "${UMBREL_ROOT}/tor/data/web/hostname")
DEVICE_HOSTS="http://${hidden_service_url}"
# if you have already set DEVICE_HOSTS, then do instead:
# DEVICE_HOSTS="${DEVICE_HOSTS},http://${hidden_service_url}"
sed -i s#\<DEVICE_HOSTS\>#\"$DEVICE_HOSTS\"#g $UMBREL_ROOT/docker-compose.yml

```
**stop and remove tor (to avoid errors with docker-compose):**  
```shell
docker container rm -f umbrel-tor
docker network rm umbrel

```

# 5. change umbrel file permissions <a name="change-umbrel-permissions"></a>
**if you are running docker normal:**
```shell
sudo chown -R 1000:1000 $UMBREL_ROOT

```

**if you are running docker in rootless-mode:**  

**check owner of umbrel files:**  
```shell
ls -la $UMBREL_ROOT/tor/web/hostname
-rw------- 1 166535 166535 63 Mar 15 12:52 tor/data/web/hostname
```
**change owner of all files:**  
```shell
sudo chown -R 166535:166535 $UMBREL_ROOT

```

# 6. deploy docker-compose.yml from your UMBREL_ROOT <a name="deploy-docker-compose"></a>

# 7. configure umbrel using tor browser <a name="configure-umbrel"></a>
**browse your hidden_service_url using latest [tor-browser](https://www.torproject.org/de/download/):
```shell
echo $hidden_service_url
# <your_random_generated_hidden_service_url.onion>

```

# 8. wait bitcoind to be syned <a name="bitcoind-sync"></a>
**check your umbrel-bitcoind logs to see progress ...**  
**or visit your hidden_service_url and login**  

**restarting the whole stack after working state can huge bring performance boost**  

### Find Me <a name="findme"></a>

![E-Mail](https://img.shields.io/badge/E--Mail-executor55%40gmx.de-red)
* [GitHub](https://github.com/3x3cut0r)
* [DockerHub](https://hub.docker.com/u/3x3cut0r)

### License <a name="license"></a>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) - This project is licensed under the GNU General Public License - see the [gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.
