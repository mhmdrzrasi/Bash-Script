#!/bin/bash

####################################
# Author: MohammadReza Rasi
# Created: 2023-09-22
# Last Modified: 2023-09-23
# Description: 
# Usage: bash p1.sh
####################################

check_action3=0

action1(){
    if [[ -f $SOURCES_PATH ]]; then
        cp $SOURCES_PATH /etc/apt/sources.list
        echo "The sources.list file was updated"
    else
        echo "Please create the sources.list file."
    fi
}

action2(){
    if [[ check_action3 -eq 1 ]]; then
        echo "    dns-nameservers $NAMESERVER1 $NAMESERVER2" >> /etc/network/interfaces

        systemctl restart networking

        echo "The interfaces file was updated"
    else
        echo "Please do the action3 first and then do this action again"
    fi
}

action3(){
    echo "# This file describes the network interfaces available on your system" > /etc/network/interfaces
    echo "# and how to activate them. For more information, see interfaces(5)." >> /etc/network/interfaces
    echo "" >> /etc/network/interfaces
    echo "# source /etc/network/interfaces.d/*" >> /etc/network/interfaces
    echo "" >> /etc/network/interfaces
    echo "# The loopback network interface" >> /etc/network/interfaces
    echo "auto lo" >> /etc/network/interfaces
    echo "iface lo inet loopback" >> /etc/network/interfaces
    echo "" >> /etc/network/interfaces
    echo "auto enp0s3" >> /etc/network/interfaces
    echo "iface enp0s3 inet static" >> /etc/network/interfaces
    echo "    address $IP" >> /etc/network/interfaces
    echo "    gateway $GATEWAY" >> /etc/network/interfaces

    systemctl restart networking

    echo "The interfaces file was updated"

    check_action3=1
}

action4(){
    apt install ntp
    # sed -i '23d' /etc/ntp.conf
    echo "" >> /etc/ntp.conf
    echo "pool $NTPSERVER1 iburst" >> /etc/ntp.conf

    systemctl restart ntp
    echo ""
    echo "The ntp.conf file was updated"
}

action5(){
    if id $NEW_USER_NAME &>/dev/null; then
        echo "User $NEW_USER_NAME already exists."
    else
        useradd $NEW_USER_NAME
        echo "$NEW_USER_NAME user created successfully"

        echo "$NEW_USER_NAME:$NEW_USER_PASSWORD" | chpasswd
        echo "The password for the $NEW_USER_NAME user has been applied successfully"

        chage -M $NEW_USER_PASSWORD_EXPIRES_DAY $NEW_USER_NAME
        echo "Password expiration date applied for $NEW_USER_PASSWORD_EXPIRES_DAY days"

        local now=$(date +'%Y-%m-%d')
        local one_month_later=$(date -d "$now +$NEW_USER_ACCOUNT_EXPIRES_MONTH month" +%Y-%m-%d)
        chage -E $one_month_later $NEW_USER_NAME
        echo "Account expiration date applied for $NEW_USER_ACCOUNT_EXPIRES_MONTH month"
    fi
}

action6(){
    # echo "root:$NEW_ROOT_PASSWORD" | chpasswd
    # echo "The password for the root user has been applied successfully"
    passwd root
}

action7(){
    apt install git
    echo ""
    echo "The git has been successfully installed"
}

action8(){
    local pid=""
    for ((i = 1; i < $PID_NUMBER_LESS_THAN; i++)); do
        user=$(ps -o user -p $i --no-header)
        if [[ "$user" == "$PRCESSES_USER" ]]; then
            pid="${pid}$i,"
        fi
    done

    pid="${pid%,}"
    ps -p $pid -o "pid,user,cmd"
    echo ""
}

action9(){
    apt install openssh-server
    systemctl start ssh
    systemctl enable ssh

    apt install ufw
    ufw allow ssh
    ufw enable

    echo ""
    echo "ssh configuration is done successfully"
}

action10(){
    echo "#!/usr/sbin/nft -f" > /etc/nftables.conf
    echo "" >> /etc/nftables.conf
    echo "flush ruleset" >> /etc/nftables.conf
    echo "" >> /etc/nftables.conf
    echo "table ip filter {" >> /etc/nftables.conf
    echo "    chain input {" >> /etc/nftables.conf
    echo "        type filter hook input priority 0; policy drop;" >> /etc/nftables.conf
    echo "        iif lo accept" >> /etc/nftables.conf
    echo "        tcp dport 22 accept" >> /etc/nftables.conf
    echo "    }" >> /etc/nftables.conf
    echo "    chain forward {" >> /etc/nftables.conf
    echo "        type filter hook forward priority 0; policy drop;" >> /etc/nftables.conf
    echo "    }" >> /etc/nftables.conf
    echo "    chain output {" >> /etc/nftables.conf
    echo "        type filter hook output priority 0; policy drop;" >> /etc/nftables.conf
    echo "        ct state established,related accept" >> /etc/nftables.conf
    echo "    }" >> /etc/nftables.conf
    echo "}" >> /etc/nftables.conf

    # nft -f /etc/nftables.conf

    # systemctl restart nftables
    # systemctl enable nftables

    echo "nft firewall successfully configured."
}

if [[ $USER != "root" ]];then
    echo "Please switch to root user and run the file again."
    sleep 2
    clear
    exit 1
fi

if [[ -f conf.env ]]; then
    source conf.env
else
    echo "peyda nashod"
    exit 1
fi

action1
sleep 1
action3
sleep 1
action2
sleep 1
action4
sleep 1
action5
sleep 1
action6
sleep 1
action7
sleep 1
action8
sleep 1
action9
sleep 1
action10
sleep 1


echo "movafaghiat"
