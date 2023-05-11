#!/bin/bash
# 10.05.2023: Automated Script for installing packages for a new linux system
# 10.05.2023: added CrowdSec installation with curl and adding Instance to CrowdSec with API Key (individual key)
# 10.05.2023: added Hostname-Configuration
# 11.05.2023: added function for new user with group sudo
############################################
# modify shell operation environment (terminate whenever an error occurs)
set -eu -o pipefail # fail on error and report it, debug all lines
# run as superuser
sudo -n true
# test for sudo privilige (test after sudo -n true if statement is 0 or 1)
test $? -eq 0 || exit 1 "you need sudo privilege to run this script!"
###########################################
# edit hostname + /etc/hosts with Y or N operation
###########################################
echo "do you want to change the hostname?"
read -p "Y or N: " changeHostname
if [ "$changeHostname" = "Y" ] || [ "$changeHostname" = "y" ]; then
	clear
	oldHostname=$(hostname)
	echo Its Time to change the Hostname!
	read -p "New Hostname: " newHostname
	hostnamectl set-hostname $newHostname
	sed -i "s/$oldHostname/$newHostname/g" /etc/hosts
	echo Hostname changed to $(hostname)
	echo Continue with new user process in 5 seconds...
	sleep 5
	clear
else
	echo Hostname - $(hostname) - will not change! continue with new software in 5 seconds...
	sleep 5
	clear
	sleep 3
fi
###########################################
# creating new user and add group sudo
###########################################
# date for usercomment
date=$(date +%e+%m+%Y+%H+%M)
# geco for usercomment with date
geco="script-at-$date"
echo do you want to create a NEW USER with group SUDO?
        read -p "Y or N: " addUser
if [ "$addUser" = "Y" ] || [ "$addUser" = "y" ]; then
        echo Please enter USERNAME:
        read -p "Username: " userName
# adduser with homedirectory, shell: bin/bash, no password and no geco for skipping dialogue
        adduser --home /home/$userName --shell /bin/bash --disabled-password --gecos "" $userName
        chfn -o $geco $userName 
# add password for new user
        echo "please enter PASSWORD for user $userName"
        passwd $userName
# add user to group sudo
        usermod -aG sudo $userName
		echo $userName added to group sudo!
		echo -e "\n"
		echo continue with software installation in 5 seconds...
		sleep 5
		clear
else
        echo NO user created -- continue with new software in 5 seconds...
        sleep 5
	clear
fi
###########################################
# installing new software
###########################################
echo update repository...
sleep 2
apt update
echo -e "\n"
echo repository is up2date!
echo -e "\n"
echo installing new software...
sleep 3
while read -r p ; do sudo apt-get install -y $p ; done < <(cat << "EOF"
	openssh-client
	xfce4
	htop
	ufw
	fail2ban
	curl
	wget
EOF
)
###########################################
# Message
###########################################
echo new software installed!!!
echo -e "\n"
echo CrowdSec installer in 5 seconds...
clear
echo hit Crtl+C to quit CrowdSec installation
sleep 5
###########################################
# installing CrowdSec + add Instance with individual API-Key
###########################################
echo please follow instruction for adding this instance to CrowdSec!
sleep 3
# ask for API Key
echo enter your CrowdSec API-Key for adding the instance!
read -p "CrowdSec personal API Key: " key
curl  -s https://packagecloud.io/install/repositories/crowdsec/crowdsec/script.deb.sh | sudo bash
sudo apt-get  -y install crowdsec
sudo apt  install  -y crowdsec-firewall-bouncer-iptables
sudo cscli  console enroll $key
echo instance added to CrowdSec! -- please check: https://www.crowdsec.net
echo -e "\n"
echo script finished!
echo -e "\n"
date
echo -- RESULTS --
hostname
cat /etc/passwd | grep $(userName)
groups $(userName)
cat /etc/hots
exit
###########################################
