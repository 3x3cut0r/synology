#!/bin/bash
# Author: Julian Reith
# E-Mail: julianreith@gmx.de
#
# Description:
# This script is updating the /etc/nginx/app.d/server.ReverseProxy.conf
# from a synology diskstation (version 6.x and higher). This update is
# necessary for some synapse bridges to work properly.
#
# Be aware!: After changing anything regarding the reverse proxy in DSM
# /etc/nginx/app.d/server.ReverseProxy.conf got overwritten!!! and this
# script has to be executed again!!!
#
# Usage:
# 1. enter your fqdn and subdomain for synapse below
# 2. enter reverse proxy entries which need to be updated below
# 3. enter a backup location below
# 4. save this script somewhere on your nas
# 5. make sure admin, respectively root can at least read and execute (-r-x------ admin users updateReverseProxyEntry.sh)
# 6. create a new scheduled task -> User-defined script with: user = root, activated = no,
#    path = path to your script location e.g.: /volume1/documents/scripts/updateReverseProxyEntry.sh
#
# 7. execute this script after changing anything regarding the reverse proxy in DSM e.g.: adding/changing an entry
# 8. DONE!

### GLOBAL VARS ###

### !!! Change to your own !!! ###
fqdn="3x3cut0r.synology.me" # your Full Qualified Domain Name of your Synapse-Server e.g.: "diskstation.synology.me"
subdomain="matrix" # your Subdomain (Hostname) e.g.: "matrix"
rpEntries=(	# bridges that need to be updated e.g.: "federation"
    "client" # for clients and federation
    "server" # for federation
    "maubot" # for maubot
)
client_max_body_size="100M" # client_max_body_size
backupPath="/volume1/backup/nginx/" # backup path

### Don't change anything below !!! ###
nginxPath="/etc/nginx/" # nginx path
proxyPath="app.d/" # reverse proxy config location
locationPath="location.d/" # custom folder name for additional reverse proxy configuration
configFile="server.ReverseProxy.conf" # reverse proxy config file
path="$nginxPath$proxyPath$configFile" # path of reverse proxy entrys
tmpFile="/tmp/rpTmpFile" # path of a temporary file
nginxReloadRequired=0 # if 1, then nginx need to be reloaded

### FUNCTIONS ###

makeConfigBackup (){ # make a backup of the original config
	mkdir -p $backupPath$proxyPath
	cp $path $backupPath$proxyPath
	echo "$configFile copied to $backupPath$proxyPath"
}

setLocation (){
    case "$1" in
        client)
            echo "" >> $tmpFile
            echo -e "\tlocation /.well-known/matrix/client {" >> $tmpFile
            echo -e "\t\treturn 200 '{\"m.homeserver\": {\"base_url\": \"https://$subdomain.$fqdn:443\"}}';" >> $tmpFile
            echo -e "\t\tadd_header Content-Type application/json;" >> $tmpFile
            echo -e "\t\tadd_header Access-Control-Allow-Origin *;" >> $tmpFile
            echo -e "\t}" >> $tmpFile
            ;;

        server)
            echo "" >> $tmpFile
            echo -e "\tlocation /.well-known/matrix/server {" >> $tmpFile
            echo -e "\t\treturn 200 '{\"m.server\": \"$subdomain.$fqdn:443\"}';" >> $tmpFile
            echo -e "\t\tadd_header Content-Type application/json;" >> $tmpFile
            echo -e "\t\tadd_header Access-Control-Allow-Origin *;" >> $tmpFile
            echo -e "\t}" >> $tmpFile
            ;;

        maubot)
            echo "" >> $tmpFile
            echo -e "\tlocation /_matrix/maubot/v1/logs" >> $tmpFile
            echo -e "\t\tproxy_pass http://localhost:29316;" >> $tmpFile
            echo -e "\t\tproxy_http_version 1.1;" >> $tmpFile
            echo -e "\t\tproxy_set_header Upgrade \$http_upgrade;" >> $tmpFile
            echo -e "\t\tproxy_set_header Connection \"Upgrade\";" >> $tmpFile
            echo -e "\t\tproxy_set_header X-Forwarded-For \$remote_addr;" >> $tmpFile
            echo -e "\t}" >> $tmpFile
            echo "" >> $tmpFile
            echo -e "\tlocation /_matrix/maubot" >> $tmpFile
            echo -e "\t\tproxy_pass http://localhost:29316;" >> $tmpFile
            echo -e "\t\tproxy_set_header X-Forwarded-For \$remote_addr;" >> $tmpFile
            echo -e "\t}" >> $tmpFile
            ;;
        *)
    esac
}

searchInsertPosition (){ # use function updateReverseProxyEntry() below	!
    pattern="server_name $subdomain.$fqdn" # search pattern -> need to be unique
    line=$(grep -n "$pattern" "$path" | cut -d : -f 1) # line of reverse proxy entry
    tail -n +$line $path > $tmpFile # store entry in tmpFile

    pattern="location / {" # new pattern
    tmpLine=$(grep -n "$pattern" "$tmpFile" | head -n 1 | cut -d : -f 1) # new line
    line=$( expr $line + $tmpLine) # add lines
    tail -n +$line $path > $tmpFile # store entry in tmpFile

    pattern="}"
    tmpLine=$(grep -n "$pattern" "$tmpFile" | head -n 1 | cut -d : -f 1) # new line
    line=$(expr $line + $tmpLine) # add lines
    tail -n +$line $path > $tmpFile # store entry in tmpFile

    rm -rf $tmpFile # remove tmpFile
    echo $line
}

updateReverseProxyEntry (){ # give unique!! name of reverse proxy entry as parameter, e.g.: "firefox"
    insline=$(searchInsertPosition) # search position of reverse proxy entry
    headLine=$(expr $insline - 3)
    head -n $headLine $path > $tmpFile # print first part

    echo "" >> $tmpFile
    echo -e "\t\tclient_max_body_size $client_max_body_size" >> $tmpFile # add client_max_body_size
    echo "" >> $tmpFile
    echo -e "\t}" >> $tmpFile # print second part, need to be unique too !!!

    for entry in "${rpEntries[@]}"; do # for every entry in array rpEntries[]
        setLocation "$entry" # update entry
    done

    tail -n +$insline $path >> $tmpFile # print third part
    cp $tmpFile $path # copy to original location
    rm -rf $tmpFile # remove tmpFile
    exist=$(grep -n "well-known/matrix/client" $path | wc -l)
    if [ $exist -eq 1 ]; then
        echo "successfully updated ReverseProxy"
    fi
}

### START OF SCRIPT ###

makeConfigBackup # make a backup of the original config. location see function
updateReverseProxyEntry # update matrix / synapse reverse proxy entry
echo "reloading nginx"
nginx -s reload # perform nginx reload
echo "all done"
