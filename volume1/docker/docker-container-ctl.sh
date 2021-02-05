#!/bin/bash
# Author: Julian Reith <julianreith@gmx.de>
# Date: 2021-02-05
#
# Description:
#  start/stop/restart all of your defined docker containers in a logical order.
#  it is intended to be executed when the diskstation is restarted.
#
# Usage:
#  1. define your containers in the DECLARATION section
#  2. chmod +x ./docker-container-ctl.sh
#  3. ./docker-container-ctl.sh --help
#

### DECLARATION ###
declare -a DOCKER_CONTAINERS_WITHOUT_DEPS=(
    # docker container without dependencies from other containers
    "adminer"
    "element-web"
    "filezilla"
    "firefox"
    "firefox2"
    "guacamole"
    "jdownloader2"
    "mopidy"
    "nextcloud"
    "nextcloud-onlyoffice-documentserver"
    "oscam"
    "pgadmin"
    "phpmyadmin"
    "pihole"
    "pyload"
    "send"
    "speedtest"
    "sshd"
    "sspks"
    "synapse"
    "teamspeak"
    "tvheadend"
    "wekan"
    "xwiki"
    "watchtower"
)

declare -a DOCKER_CONTAINERS_WITH_DEPS_1=(
    # other docker containers depend on these
    "mautrix-signal"
    "mautrix-telegram"
    "mautrix-whatsapp"
    "mx-puppet-discord"
    "guacamole-guacd"
    "rocketchat"
    "signald"
)

declare -a DOCKER_CONTAINERS_WITH_DEPS_2=(
    # other docker containers depend on these
    "mono"
    "redis-nopw"
    "redis"
)

declare -a DOCKER_CONTAINERS_DATABASES=(
    # docker containers with databases, which should be stopped last
    "mongo"
    "mariadb10"
    "postgres"
    # for every SLEEP ... sleep 5 seconds
    "SLEEP"
    "SLEEP"
)

declare -a DOCKER_CONTAINERS_DAEMONS=(
    # docker containers who manage the docker daemon itself
    "yacht"
    "portainer"
)

declare -a DOCKER_CONTAINERS_SKIP=(
    # docker containers which will be skipped
)

### FUNCTIONS ###
function cleanup () {
    # cleanup service-files (prevent port conflicts while starting containers)
    if [[ ! $CLEAN_UP -eq "0" ]];then
        printf '\n\e[0;33m%-6s\e[m\n' "rm -rf /usr/local/etc/services.d/docker_*"
        rm -rf /usr/local/etc/services.d/docker_*
    fi
}

function start () {
    # if docker-daemon is stopped, start
    DOCKER_DAEMON_STARTED="$( synoservice --status pkgctl-Docker | grep pkgctl-Docker | grep start )"
    if [[ -z $DOCKER_DAEMON_STARTED ]]; then
        printf '\n\e[0;33m%-6s\e[m' "start docker-daemon: "
        output="$( synoservice --start pkgctl-Docker )"
        if [[ $? -ne 0 ]]; then
            printf '\e[1;31m%-6s\e[m\n' "$output"
        else
            printf '\e[1;32m%-6s\e[m\n' "STARTED"
        fi
    fi
    declare -a DOCKER_CONTAINERS=(
        # define starting order
        "${DOCKER_CONTAINERS_DAEMONS[@]}"
        "${DOCKER_CONTAINERS_DATABASES[@]}"
        "${DOCKER_CONTAINERS_WITH_DEPS_2[@]}"
        "${DOCKER_CONTAINERS_WITH_DEPS_1[@]}"
        "${DOCKER_CONTAINERS_WITHOUT_DEPS[@]}"
    )
    printf '\n\e[0;33m%-6s\e[m\n\n' "start all docker containers: "
    for CONTAINER in ${DOCKER_CONTAINERS[@]}; do
        if [[ ! "${DOCKER_CONTAINERS_SKIP[@]}" =~ "${CONTAINER}" ]]; then
            if [[ "${CONTAINER}" = "SLEEP" ]]; then
                sleep 5
            else
                printf "docker container start $CONTAINER: "
                output="$( docker container start $CONTAINER )"
                if [[ $? -ne 0 ]]; then
                    printf '\e[1;31m%-6s\e[m\n' "$output"
                else
                    printf '\e[1;32m%-6s\e[m\n' "STARTED"
                fi
            fi
        fi
    done
}

function stop () {
    declare -a DOCKER_CONTAINERS=(
        # define stopping order
        "${DOCKER_CONTAINERS_WITHOUT_DEPS[@]}"
        "${DOCKER_CONTAINERS_WITH_DEPS_1[@]}"
        "${DOCKER_CONTAINERS_WITH_DEPS_2[@]}"
        "${DOCKER_CONTAINERS_DATABASES[@]}"
        "${DOCKER_CONTAINERS_DAEMONS[@]}"
    )
    printf '\n\e[0;33m%-6s\e[m\n\n' "stop all docker containers: "
    for CONTAINER in ${DOCKER_CONTAINERS[@]}; do
        if [[ ! "${DOCKER_CONTAINERS_SKIP[@]}" =~ "${CONTAINER}" && ! "${CONTAINER}" = "SLEEP" ]]; then
            printf "docker container stop $CONTAINER: "
            output="$( docker container stop $CONTAINER )"
            if [[ $? -ne 0 ]]; then
                printf '\e[1;31m%-6s\e[m\n' "$output"
            else
                printf '\e[1;32m%-6s\e[m\n' "STOPPED"
            fi
        fi
    done
    if [[ ! "${INCLUDE_DAEMON}" -eq "0" ]]; then
        printf '\n\e[0;33m%-6s\e[m' "stop docker-daemon: "
        output="$( synoservice --stop pkgctl-Docker )"
        if [[ $? -ne 0 ]]; then
            printf '\e[1;31m%-6s\e[m\n' "$output"
        else
            printf '\e[1;32m%-6s\e[m\n\n' "STOPPED"
            cleanup
        fi
    fi
}

function restart () {
    INCLUDE_DAEMON="1"
    stop
    start
}

function help () {
    printf "USAGE:\n"
    printf "  ./docker-container-ctl.sh [OPTIONS]\n\n"
    printf "OPTIONS:\n"
    printf "  --start\tstart all docker containers\n\n"
    printf "  --stop\tstop all docker containers\n\n"
    printf "  --restart\tstop all docker containers,\n"
    printf "\t\trestart the docker-daemon,\n"
    printf "\t\tstart all docker containers\n\n"
    printf "  --cleanup\tremove service-files, if docker-daemon stops\n"
    printf "\t\t(rm -rf /usr/local/etc/services.d/docker_*)\n\n"
    printf "  --include-daemon\n\t\tif --stop, also stop the docker-daemon\n\n"
    printf "  --skip\tlist of docker containers to be skipped\n"
    printf "\t\t(if --restart, they will be skipped from starting)\n\n"
    printf "  --sleep, --wait\n\t\tsleep (n) seconds after docker-daemon was started\n\n"
    printf "EXAMPLES:\n"
    printf "  ./docker-container-ctl.sh --stop --include-daemon --cleanup\n"
    printf "  ./docker-container-ctl.sh --start --sleep 60 --skip nextcloud,tvheadend\n\n"
}

### ARGS ###
if (( ! "$#" )); then
    help
    exit 0
fi
ACTION=""
INCLUDE_DAEMON="0"
CLEAN_UP="0"
SLEEP="0"
while (( "$#" )); do
    case "$1" in
    --help)
        help
        exit 0
        ;;
    --include-daemon)
        INCLUDE_DAEMON="1"
        shift
        ;;
    --cleanup)
        CLEAN_UP="1"
        shift
        ;;
    --start|--stop|--restart)
        if [ "${ACTION}" = "" ]; then
            ACTION="${1:2}"
            shift
        else
            printf '\e[1;31m%-6s\e[m\n\n' "Error: you cannot combine $1 with --${ACTION}"
            help
            exit 1
        fi
        ;;
    --wait|--sleep)
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
            if [[ "$2" -gt "0" ]]; then
                if [[ "${SLEEP}" -gt "600" ]]; then
                    SLEEP="600"
                else
                    SLEEP="$2"
                fi
            else
                printf '\e[1;31m%-6s\e[m\n\n' "Error: $1 must be int() >= 0"
            fi
            shift 2
        else
            printf '\e[1;31m%-6s\e[m\n\n' "Error: argument for $1 is missing"
            exit 1
        fi
        ;;
    --skip)
        if [ -n "$2" ] && [ ${2:0:1} != "-" ]; then
            declare -a DOCKER_CONTAINERS_SKIP=(
                "${DOCKER_CONTAINERS_SKIP[@]}"
                "$( echo "$2" | sed 's/,/ /g' )"
            )
            shift 2
        else
            printf '\e[1;31m%-6s\e[m\n\n' "Error: argument for $1 is missing"
            exit 1
        fi
        ;;
    -*|--*=) # unsupported flags
        printf '\e[1;31m%-6s\e[m\n\n' "Error: there is no such argument: $1"
        help
        exit 1
        ;;
    *)
        help
        exit 0
        ;;
    esac
done

### START OF SCRIPT ###
# execute sleep ${SLEEP}
printf '\n\e[0;33m%-6s\e[m\n\n' "sleep ${SLEEP}"
eval "sleep ${SLEEP}"
# execute $ACTION (start|stop|restart)
eval "${ACTION}"
printf '\n\e[1;32m%-6s\e[m\n\n' "DONE"
