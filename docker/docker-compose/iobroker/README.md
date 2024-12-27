# iobroker

**docker-compose.yml for iobroker**

## Index

0. [prerequisites](#prerequisites)
1. [check network-interface name to creat a macvlan at](#check-iface)
2. [create a macvlan with portainer](#create-iface)
3. [create scheduled task on your synology DSM](#triggered-task)
4. [deploy / docker-compose.yml](#deploy)
5. [usage](#usage)

\# [Find Me](#findme)  
\# [License](#license)

# 0. prerequisites <a name="prerequisites"></a>

- Synology network is configured
- SSH is enabled and you know howto use it
- Docker is installed
- Portainer (as docker container or compose stack) is up and running

# 1. check network-interface name to creat a macvlan at <a name="check-iface"></a>

- connect to your synology via ssh as root and check on which interface your macvlan should be created

```bash
# list your available interfaces, check on which is your ip, select one.
# i choose 'ovs_eth1', my second interface.
ip addr show

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: sit0@NONE: <NOARP> mtu 1480 qdisc noop state DOWN group default qlen 1
    link/sit 0.0.0.0 brd 0.0.0.0
3: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master ovs-system state UP group default qlen 1000
    link/ether 00:11:32:92:95:93 brd ff:ff:ff:ff:ff:ff
4: eth1: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc mq master ovs-system state UP group default qlen 1000
    link/ether 00:11:32:92:95:94 brd ff:ff:ff:ff:ff:ff
5: ovs-system: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1
    link/ether 12:4c:3f:d3:70:97 brd ff:ff:ff:ff:ff:ff
6: ovs_eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1
    link/ether 00:11:32:92:95:93 brd ff:ff:ff:ff:ff:ff
    inet 192.168.178.254/24 brd 192.168.178.255 scope global ovs_eth0
       valid_lft forever preferred_lft forever
    inet6 2003:e4:ef15:1700:211:32ff:fe92:9593/64 scope global mngtmpaddr dynamic
       valid_lft 7129sec preferred_lft 1411sec
    inet6 fdd7:b5ad:f651:0:211:32ff:fe92:9593/64 scope global mngtmpaddr dynamic
       valid_lft 7129sec preferred_lft 3529sec
    inet6 fe80::211:32ff:fe92:9593/64 scope link
       valid_lft forever preferred_lft forever
7: ovs_eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1     <---
    link/ether 00:11:32:92:95:94 brd ff:ff:ff:ff:ff:ff
    inet 192.168.178.244/24 brd 192.168.178.255 scope global ovs_eth1
       valid_lft forever preferred_lft forever
    inet6 2003:e4:ef15:1700:211:32ff:fe92:9594/64 scope global mngtmpaddr dynamic
       valid_lft 7129sec preferred_lft 1411sec
    inet6 fdd7:b5ad:f651:0:211:32ff:fe92:9594/64 scope global mngtmpaddr dynamic
       valid_lft 7129sec preferred_lft 3529sec
    inet6 fe80::211:32ff:fe92:9594/64 scope link
       valid_lft forever preferred_lft forever
8: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 02:42:41:43:f4:f3 brd ff:ff:ff:ff:ff:ff
    inet 172.17.0.1/16 brd 172.17.255.255 scope global docker0
       valid_lft forever preferred_lft forever
    inet6 fe80::42:41ff:fe43:f4f3/64 scope link
       valid_lft forever preferred_lft forever
...
```

# 2. create a macvlan interface with portainer <a name="create-iface"></a>

- Create this 2 Networks in your Portainer webinterface -> Network -> Add Network:

```bash
Name: macvlan-ovs_eth1-template
Driver: macvlan
Macvlan configuration: Configuration
IPV4 Subnet: <your internet providers private subnet, e.g.: 192.168.178.0/24>
IPV4 Gateway: <your internet providers gateway/router, e.g.: 192.168.178.1>
IPV4 Range: <specify the range that docker should use for containers on the macvlan interface, e.g. 192.168.178.232/29>
Create the network
```

```bash
Name: macvlan-ovs_eth1
Driver: macvlan
Macvlan configuration: Creation
Configuration: macvlan-ovs_eth1-template
Create the network
```

# 3. create triggered task on your synology DSM <a name="triggered-task"></a>

- DSM -> Systemcontrol -> Task planner -> Create -> Triggered Task -> Custom Script

```bash
Name: macvlan-br
User: root
Event: startup
Enabled: yes
```

- Task Settings:

```bash
#!/bin/bash
while ! /usr/local/bin/docker info >/dev/null 2>&1;
do
	sleep 5s
done

ip link add macvlan-br link ovs_eth1 type macvlan mode bridge
ip addr add 192.168.178.234/32 dev macvlan-br # set ip inside your IPV4 Range on step 1
ip link set macvlan-br up
ip route add 192.168.178.232/29 dev macvlan-br
```

- Execute the created task once!

# 4. deploy / docker-compose.yml <a name="deploy"></a>

**[see docker/docker-compose/iobroker/docker-compose.yml](https://github.com/3x3cut0r/synology/blob/master/docker/docker-compose/iobroker/docker-compose.yml)**

# 5. usage <a name="usage"></a>

### 5.1 browse <a name="browse"></a>

**Frontend**  
[http://192.168.178.232:8081](http://192.168.178.232:8081)

### Find Me <a name="findme"></a>

![E-Mail](https://img.shields.io/badge/E--Mail-executor55%40gmx.de-red)

- [GitHub](https://github.com/3x3cut0r)
- [DockerHub](https://hub.docker.com/u/3x3cut0r)

### License <a name="license"></a>

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0) - This project is licensed under the GNU General Public License - see the [gpl-3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) for details.
