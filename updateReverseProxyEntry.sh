#!/bin/bash
# Author: Julian Reith
# E-Mail: julianreith@gmx.de
#
# Description:
# This script is updating the /etc/nginx/app.d/server.ReverseProxy.conf
# from a synology diskstation (version 6.x and higher). This update is
# necessary for all docker containers from https://hub.docker.com/u/jlesage
# to work properly.
# 
# Be aware!: After changing anything regarding the reverse proxy in DSM
# /etc/nginx/app.d/server.ReverseProxy.conf got overwritten!!! and this
# script has to be executed again!!!
#
# Usage:
# 1. enter your fqdn below
# 2. enter reverse proxy entries which need to be updated below
# 3. enter a backup location below
# 4. save this script somewhere to your nas
# 5. make sure admin, respectively root can at least read and execute (-r-x------ admin users updateReverseProxyEntry.sh)
# 6. create a new scheduled task -> User-defined script with: user = root, activated = no, 
#    path = path to your script location e.g.: /volume1/documents/scripts/updateReverseProxyEntry.sh
# 
# 7. execute this script after changing anything regarding the reverse proxy in DSM e.g.: adding/changing an entry
# 8. DONE!

### !!! Change to your own !!! ###
fqdn="3x3cut0r.synology.me" # your Full Qualified Domain Name e.g.: "diskstation.synology.me"
rpEntries=(	# reverse proxy entrys that need to be updated e.g.: "firefox"
	"filezilla"
	"firefox"
)
backupPath="/volume1/backup/nginx/" # backup path

### Don't change anything below !!! ###
nginxPath="/etc/nginx/" # nginx path
proxyPath="app.d/" # reverse proxy config location
locationPath="location.d/" # custom folder name for additional reverse proxy configuration
configFile="server.ReverseProxy.conf" # reverse proxy config file
path="$nginxPath$proxyPath$configFile" # path of reverse proxy entrys
tmpFile="/tmp/rpTmpFile" # path of a temporary file
nginxReloadRequired=0 # if 1, then nginx need to be reloaded

makeConfigBackup (){
	mkdir -p $backupPath$proxyPath
	cp $nginxPath$proxyPath$configFile $backupPath$proxyPath
	echo "$configFile copied to $backupPath$proxyPath"
}

returnProxyPass (){ # give reverse proxy entry
	pattern="server_name $1.$fqdn" # search pattern -> need to be unique
	line=$(grep -n "$pattern" "$path" | cut -d : -f 1) # line of reverse proxy entry
	tail -n +$line $path > $tmpFile # store entry in tmpFile
		
	pattern="location / {" # new pattern
	tmpLine=$(grep -n "$pattern" "$tmpFile" | head -n 1 | cut -d : -f 1) # new line
	line=$(expr $line + $tmpLine) # add lines
	tail -n +$line $path > $tmpFile # store entry in tmpFile
	
	pattern="proxy_pass "
	tmpLine=$(grep -n "$pattern" "$tmpFile" | head -n 1 | cut -d : -f 1) # new line
	line=$(expr $line + $tmpLine - 1) # add lines
	tail -n +$line $path > $tmpFile # store entry in tmpFile
	
	proxyPass=$(head -n 1 "$tmpFile")
	rm -rf $tmpFile # remove tmpFile

	echo $proxyPass # return reverse pass line
}

createLocationFile (){ # give reverse proxy entry which need to be (re)created
	locationFile="/var/tmp/nginx/$locationPath$1.location"
	proxyPass=$(returnProxyPass $1)
	pattern="server_name $1.$fqdn"
	exist=$(grep -n "$pattern" "$path")
	if [ ! -z "$exist" ]; then
		touch "$locationFile"
		echo -e "location /websockify {\n" > $locationFile 
		echo -e "\t proxy_connect_timeout 3600;\n" >> $locationFile
		echo -e "\t proxy_read_timeout 3600;\n" >> $locationFile
		echo -e "\t proxy_send_timeout 3600;\n" >> $locationFile
		echo -e "\t proxy_intercept_errors off;\n" >> $locationFile
		echo -e "\t proxy_http_version 1.1;\n" >> $locationFile
		echo -e "\t proxy_set_header \tHost \t\t\t\$http_host;\n" >> $locationFile
		echo -e "\t proxy_set_header \tX-Real-IP \t\t\$remote_addr;\n" >> $locationFile
		echo -e "\t proxy_set_header \tX-Forwarded-For \t\$proxy_add_x_forwarded_for;\n" >> $locationFile
		echo -e "\t proxy_set_header \tX-Forwarded-Proto \t\$scheme;\n" >> $locationFile
		echo -e "\t proxy_set_header \tUpgrade \t\t\$http_upgrade;\n" >> $locationFile
		echo -e "\t proxy_set_header \tConnection \t\t\$connection_upgrade;\n" >> $locationFile
		echo -e "\t $proxyPass\n" >> $locationFile
		echo -e "}\n" >> $locationFile
		echo "location file (re)created: $locationFile"
	fi
}

createLocationFolder (){
	folderPath="/var/tmp/nginx/"
	folder="$folderPath$locationPath"
	if [ ! -d "$folder" ]; then
		mkdir -p $folder
		if [ $? -eq 0 ]; then
			echo "folder $folder successfully created"
		fi
	else
		echo "skipping: folder $folder already exist"
	fi
	
	link="$nginxPath$locationPath"
	link=${link%?} # remove "/" from path because searching for link name not its content
	if [ ! -L "$link" ]; then
		ln -s $folder $link
		if [ $? -eq 0 ]; then
			echo "symbolic link $link successfully created"
		fi
	else
		echo "skipping: symbolic link $link already exist"
	fi
}	

searchInsertPosition (){ # use function updateReverseProxyEntry() below	!
	pattern="server_name $1.$fqdn" # search pattern -> need to be unique
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
	createLocationFile $1
	exist=$(grep -n "include location.d/$1.location;" $path | wc -l) # does insertLine already exist?
	if [ $exist -eq 0 ]; then # check if entry is already present
		insline=$(searchInsertPosition $1) # search position of reverse proxy entry
		headLine=$(expr $insline - 1) 
		head -n $headLine $path > $tmpFile # print first part
		
		echo "" >> $tmpFile
		echo "	include location.d/$1.location;" >> $tmpFile # print second part, need to be unique too !!!
		
		tail -n +$insline $path >> $tmpFile # print third part
		cp $tmpFile $path # copy to original location
		rm -rf $tmpFile # remove tmpFile
		exist=$(grep -n "include location.d/$1.location;" $path | wc -l)
		if [ $exist -eq 1 ]; then
			echo "successfully updated $1 in $path"
		fi
		nginxReloadRequired+=1 # nginx need to be reloaded
	fi
}

makeConfigBackup
createLocationFolder
for entry in "${rpEntries[@]}"; do # for every entry in array rpEntries[]
    updateReverseProxyEntry "$entry" # update entry
done
if [ $nginxReloadRequired -ge 1 ]; then
	echo "nginx reload required"
	echo "reloading nginx"
	nginx -s reload
	nginxReloadRequired=0
else
	echo "nginx reload NOT required"
fi
echo "all done"
