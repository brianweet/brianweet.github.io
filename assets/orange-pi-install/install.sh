#!/bin/bash
 
## This script is developed from my Raspberry Pi script - for the Orange Pi PC
## But see the blog - you have to use a particular version of Debian
## and scripts - then expand, reboot and use this script having given it execute
## permissions. See http://tech.scargill.net/orange-pi-pc-battle-of-the-pis/
## Latest updates removing need for some manual work - thanks to Antonio Fragola. 
 
# Get time as a UNIX timestamp (seconds elapsed since Jan 1, 1970 0:00 UTC)
startTime="$(date +%s)"
columns=$(tput cols)
user_response=""
 
# Reset
Color_Off='\e[0m'       # Text Reset
 
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
NORMAL=$(tput sgr0)
 
# High Intensity
IBlack='\e[0;90m'       # Black
IRed='\e[0;91m'         # Red
IGreen='\e[0;92m'       # Green
IYellow='\e[0;93m'      # Yellow
IBlue='\e[0;94m'        # Blue
IPurple='\e[0;95m'      # Purple
ICyan='\e[0;96m'        # Cyan
IWhite='\e[0;97m'       # White
 
# Bold High Intensity
BIBlack='\e[1;90m'      # Black
BIRed='\e[1;91m'        # Red
BIGreen='\e[1;92m'      # Green
BIYellow='\e[1;93m'     # Yellow
BIBlue='\e[1;94m'       # Blue
BIPurple='\e[1;95m'     # Purple
BICyan='\e[1;96m'       # Cyan
BIWhite='\e[1;97m'      # White
#!/bin/bash
 
skip=0
 
clean_stdin()
{
while read -r -t 0; do
    read -n 256 -r -s
done
}
 
# Permanent loop until both passwords are the same..
function user_input {
  local VARIABLE_NAME=${1}
  local VARIABLE_NAME_1="A"
  local VARIABLE_NAME_2="B"
  while true; do
      printf "${BICyan}$2: ${BIWhite}";
      if [ "$3" = "hide" ] ; then
        stty -echo;
      fi
      read VARIABLE_NAME_1;
      stty echo;
      if [ "$3" = "hide" ] ; then
          printf "\n${BICyan}$2 (again) : ${BIWhite}";
          stty -echo;
          read VARIABLE_NAME_2;
          stty echo;
      else
          VARIABLE_NAME_2=$VARIABLE_NAME_1;
      fi
      if [ $VARIABLE_NAME_1 != $VARIABLE_NAME_2 ] ; then
         printf "\n${BIRed}Sorry, did not match!${BIWhite}\n";
      else
         break;
       fi
  done
  readonly ${VARIABLE_NAME}=$VARIABLE_NAME_1;
  if [ "$3" == "hide" ] ; then
     printf "\n";
  fi     
}
 
timecount(){
    sec=30
    while [ $sec -ge 0 ]; do
        printf "${BIPurple}Continue Y(es)/n(0)/s(kip)/a(ll)-  00:0$min:$sec remaining\033[0K\r${BIWhite}"
        sec=$((sec-1))
        trap '' 2
        stty -echo
        read -t 1 -n 1 user_response
        stty echo
        trap - 2
        if [ -n  "$user_response" ]; then
            break
        fi                 
    done
}
 
task_start(){
printf "${BIGreen}%*s\n" $columns | tr ' ' -
printf "$1"
clean_stdin
skip=0
printf "\n%*s${BIWhite}\n" $columns | tr ' ' -
elapsedTime="$(($(date +%s)-startTime))"
printf "Elapsed Time: %02d hrs %02d mins %02d secs\n" "$((elapsedTime/3600%24))" "$((elapsedTime/60%60))" "$((elapsedTime%60))"
clean_stdin
if [ "$user_response" != "a" ]; then
    timecount
fi
echo -e "                                                                        \033[0K\r"
if  [ "$user_response" = "n" ]; then
    printf "${BIWhite}"
    exit 1
fi 
if  [ "$user_response" = "s" ];then
    skip=1
fi 
if [ -n  "$2" ]; then
    if [ $skip -eq 0 ]; then
        printf "${BIYellow}$2${BIWhite}\n"
    else
        printf "${BICyan}%*s${BIWhite}\n" $columns '[SKIPPED]'
    fi
fi
}
 
task_end(){
    printf "${BICyan}%*s${BIWhite}\n" $columns '[OK]'
}
 
 
 
 
# This script is intended for the Orange Pi PC 2 using the basic setup here
# http://www.orangepi.org/orangepibbsen/forum.php?mod=viewthread&tid=867&extra=page%3D1&page=1
#
# Assuming access as orangepi user. Please note this will NOT WORK AS ROOT - The Node-Red install will fail.
# Do not use this script as SUDO.
#
# including Mosquitto with web sockets (Port 9001), SQLITE ( xxx.xxx.xxx.xxx/phpliteadmin),
# Node-Red-UI (xxx.xxx.xxx.xxx:1880/ui) and Webmin(xxx.xxx.xxx:10000)
#
# http://tech.scargill.net - much of this was thanks to help from others!
#
# If you want security you need to add this to the settings.js file in /home/orangepi/.node-red
#
# Suggested improvements welcome - I'm learning!!
#
#    functionGlobalContext: {
#        // os:require('os'),
#        // bonescript:require('bonescript'),
#        // jfive:require("johnny-five"),
#       moment:require('moment'),
#       fs:require('fs')
#    },
 
#    adminAuth: {
#    type: "credentials",
#    users: [{
#       username: "admin",
#        password: "your encrypted password see node red site",
#        permissions: "*"
#    }]
#},
#
#  httpNodeAuth: {user:"user", pass:"your encrypted password see node red site"},
 
task_start "Update" "Updating repositories then any programs"
if [ $skip -eq 0 ]  
then
cd
sudo apt-get remove -y --purge nginx nginx-common
sudo apt-get autoremove -y
sudo apt-get -qq -o=Dpkg::Use-Pty=0 --yes --force-yes update
sudo apt-get -qq -o=Dpkg::Use-Pty=0 --yes --force-yes upgrade
task_end
fi
 
task_start "Prerequisites" "Enabling PING and SAMBA (to access the hostname externally - and STUFF"
if [ $skip -eq 0 ]  
then
# fix for RPI treating PING as a root function - by Dave
sudo setcap cap_net_raw=ep /bin/ping
sudo setcap cap_net_raw=ep /bin/ping6
# this one ensures the unit shows up on the network by hostname... works a treat
# sudo apt-get install samba samba-common-bin
 
 
# Prerequisite suggested by Julian
sudo apt-get install -y bash-completion unzip build-essential git python-serial scons libboost-filesystem-dev libboost-program-options-dev libboost-system-dev libsqlite3-dev subversion libcurl4-openssl-dev libusb-dev cmake # libboost-thread-dev libboost-all-dev
task_end
fi
 
task_start "Mosquitto" "Loading Mosquitto and setting up user"
if [ $skip -eq 0 ]  
then
# installation of Mosquitto/w/Websockets
cd
wget http://repo.mosquitto.org/debian/mosquitto-repo.gpg.key
sudo apt-key add mosquitto-repo.gpg.key
cd /etc/apt/sources.list.d/
sudo wget http://repo.mosquitto.org/debian/mosquitto-jessie.list
sudo apt-get update -y
cd
sudo apt-get install -y mosquitto
 
# Setup kill anonymous, emable websockets then set username and password for accessing Mosquitto
# As we are PI - create temporary file with changes - then add to Mosquitto.conf
echo '======================================= UPdating mosquitto.conf'
cat <<EOT > /tmp/tmpnoderedfile
listener 9001
protocol websockets
listener 1883
allow_anonymous false
password_file /etc/mosquitto/passwords
EOT
sudo bash -c "cat /tmp/tmpnoderedfile >> /etc/mosquitto/mosquitto.conf"
rm /tmp/tmpnoderedfile
 
# Create or append to mosquitto passwords then add user
sudo bash -c "echo '' >> /etc/mosquitto/passwords"
user_input mquser "Enter desired user (admin for example) for Mosquitto"
user_input mqpass "Enter desired password for Mosquitto" "hide"
sudo mosquitto_passwd  -b /etc/mosquitto/passwords $mquser $mqpass
task_end
fi
 
task_start "Node-Red" "Loading Node-Red"
if [ $skip -eq 0 ]  
then
# Dave provided most of this - installation of Node-Red and my selection of nodes
sudo apt-get remove -y nodered nodejs nodejs-legacy npm
sudo apt-get autoremove -y
curl -sL https://deb.nodesource.com/setup_4.x | sudo bash -
sudo apt-get install -y build-essential python-dev nodejs
sudo npm cache clean
sudo npm install -g --unsafe-perm node-red
sudo wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/nodered.service -O /lib/systemd/system/nodered.service
sudo wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/node-red-start -O /usr/bin/node-red-start
sudo wget https://raw.githubusercontent.com/node-red/raspbian-deb-package/master/resources/node-red-stop -O /usr/bin/node-red-stop
sudo sed -i -e 's#=pi#=orangepi#g' /lib/systemd/system/nodered.service
sudo chmod +x /usr/bin/node-red-st*
sudo systemctl daemon-reload
mkdir .node-red
cd .node-red
sudo npm install -g node-red-admin
npm install moment
npm install node-red-contrib-grove
npm install node-red-contrib-bigtimer
npm install node-red-contrib-esplogin
npm install node-red-node-pushbullet
npm install node-red-contrib-freeboard
npm install node-red-node-openweathermap
npm install node-red-node-google
npm install node-red-node-sqlite
npm install node-red-contrib-ui
npm install node-red-node-emoncms
npm install node-red-node-geofence
#npm install node-red-contrib-ivona
npm install node-red-contrib-moment
npm install node-red-contrib-particle
npm install node-red-contrib-graphs
npm install node-red-node-ledborg
npm install node-red-node-ping
npm install node-red-node-random
npm install node-red-node-smooth
npm install node-red-contrib-npm
#npm install raspi-io
#npm install node-red-contrib-gpio
npm install node-red-contrib-admin
npm install node-red-node-arduino
task_end
fi
 
task_start "Install Webmin" "Installing Webmin - expect interaction"
if [ $skip -eq 0 ]  
then
cd
mkdir webmin
cd webmin
wget --no-verbose http://prdownloads.sourceforge.net/webadmin/webmin-1.780.tar.gz
sudo gunzip -q webmin-1.780.tar.gz
sudo tar xf webmin-1.780.tar
cd webmin-1.780
sudo ./setup.sh /usr/local/Webmin
cd
cd webmin
sudo rm *.tar
task_end
fi
 
task_start "Apache Installation with PHP and SQLITE and PHPLITEADMIN" "Installing Apache and PHP and SQLITE and PHPLITEADMIN..."
if [ $skip -eq 0 ]  
then
cd
sudo groupadd -f -g33 www-data
sudo apt-get -qq --yes -o=Dpkg::Use-Pty=0 --force-yes install apache2 php5 libapache2-mod-php5
 
 
cd
sudo apt-get install -y sqlite3 php5-sqlite
mkdir dbs
sqlite3 /home/orangepi/dbs/iot.db << EOF
CREATE TABLE IF NOT EXISTS \`pinDescription\` (
  \`pinID\` INTEGER PRIMARY KEY NOT NULL,
  \`pinNumber\` varchar(2) NOT NULL,
  \`pinDescription\` varchar(255) NOT NULL
);
CREATE TABLE IF NOT EXISTS \`pinDirection\` (
  \`pinID\` INTEGER PRIMARY KEY NOT NULL,
  \`pinNumber\` varchar(2) NOT NULL,
  \`pinDirection\` varchar(3) NOT NULL
);
CREATE TABLE IF NOT EXISTS \`pinStatus\` (
  \`pinID\` INTEGER PRIMARY KEY NOT NULL,
  \`pinNumber\` varchar(2)  NOT NULL,
  \`pinStatus\` varchar(1) NOT NULL
);
CREATE TABLE IF NOT EXISTS \`users\` (
  \`userID\` INTEGER PRIMARY KEY NOT NULL,
  \`username\` varchar(28) NOT NULL,
  \`password\` varchar(64) NOT NULL,
  \`salt\` varchar(8) NOT NULL
);
CREATE TABLE IF NOT EXISTS \`device_list\` (
  \`device_name\` varchar(80) NOT NULL DEFAULT '',
  \`device_description\` varchar(80) DEFAULT NULL,
  \`device_attribute\` varchar(80) DEFAULT NULL,
  \`logins\` int(11) DEFAULT NULL,
  \`creation_date\` datetime DEFAULT NULL,
  \`last_update\` datetime DEFAULT NULL,
  PRIMARY KEY (\`device_name\`)
);
CREATE TABLE IF NOT EXISTS \`readings\` (
  \`location\` varchar(20) NOT NULL,
  \`value\` int(11) NOT NULL,
  \`logged\` timestamp NULL DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE IF NOT EXISTS \`pins\` (
  \`gpio0\` int(11) NOT NULL DEFAULT '0',
  \`gpio1\` int(11) NOT NULL DEFAULT '0',
  \`gpio2\` int(11) NOT NULL DEFAULT '0',
  \`gpio3\` int(11) NOT NULL DEFAULT '0'
);
INSERT INTO PINS VALUES(0,0,0,0);
CREATE TABLE IF NOT EXISTS \`temperature_record\` (
  \`device_name\` varchar(64) NOT NULL,
  \`rec_num\` INTEGER PRIMARY KEY,
  \`temperature\` float NOT NULL,
  \`date_time\` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
.exit
EOF
 
chmod 777 /home/orangepi/dbs
chmod 666 /home/orangepi/dbs/iot.db
cd
 
cd /var/www/html
sudo mkdir phpliteadmin
cd phpliteadmin
sudo wget --no-verbose https://bitbucket.org/phpliteadmin/public/downloads/phpLiteAdmin_v1-9-6.zip
sudo unzip phpLiteAdmin_v1-9-6.zip
sudo mv phpliteadmin.php index.php
sudo mv phpliteadmin.config.sample.php phpliteadmin.config.php
sudo rm *.zip
sudo mkdir themes
cd themes
sudo wget --no-verbose https://bitbucket.org/phpliteadmin/public/downloads/phpliteadmin_themes_2013-12-26.zip
sudo unzip phpliteadmin_themes_2013-12-26.zip
sudo rm *.zip
user_input litepasswd "Enter desired password for PHPLiteAdmin" "hide"
sudo sed -i -e 's#\$directory = \x27.\x27;#\$directory = \x27/home/orangepi/dbs/\x27;#g' /var/www/html/phpliteadmin/phpliteadmin.config.php
sudo sed -i -e "s#\$password = \x27admin\x27;#\$password = \x27$litepasswd\x27;#g" /var/www/html/phpliteadmin/phpliteadmin.config.php
sudo sed -i -e "s#\$subdirectories = false;#\$subdirectories = true;#g" /var/www/html/phpliteadmin/phpliteadmin.config.php
cd
 
task_end
fi
 
task_start "MPG3 Installation" "Installing mpg123..."
if [ $skip -eq 0 ]  
then
sudo apt-get install -y mpg123
task_end
fi
 
#task_start "Internet Time Updater for Webmin" "Ntpdate installing..."
#if [ $skip -eq 0 ]  
#then
#sudo apt-get -qq --yes -o=Dpkg::Use-Pty=0 --force-yes install ntpdate
#task_end
#fi
 
 
#task_start "Email SMTP Installation" "Installing mail utils and SMTP..."
#if [ $skip -eq 0 ]  
#then
#cd
#sudo apt-get  -qq --yes -o=Dpkg::Use-Pty=0 --force-yes install mailutils ssmtp
#task_end
#fi
 
task_start "Install SCREEN" "Installing SCREEN"
if [ $skip -eq 0 ]  
then
cd
sudo apt-get install screen
task_end
fi
 
sudo service nodered start ; sleep 5 ; sudo service nodered stop
sed -i -e "s/\/\/\ os:require('os')\,/os:require('os')\,\n\tmoment:require('moment')/g" .node-red/settings.js
echo " "

sudo systemctl set-default multi-user.target
#sudo systemctl set-default graphical.target

sudo usermod -aG dialout orangepi
sudo systemctl enable nodered.service

echo "All done. Rebooting"
sudo reboot