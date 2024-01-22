#!/bin/bash

####################################
# Author: MohammadReza Rasi
# Created: 2023-09-22
# Last Modified: 2024-01-22
# Description: 
# Usage: bash InitialSettings.sh <conf file address>
####################################

update_sources_file(){
    if [[ -f $SOURCES_PATH ]]; then
        sudo cp $SOURCES_PATH /etc/apt/sources.list
        echo "The sources.list file was updated"
    else
        echo "Please create the sources.list file."
    fi
}

change_nameserver(){
    echo "nameserver $NAMESERVER1" | sudo tee /etc/resolv.conf
    sudo systemctl restart networking
    echo "dns-nameservers was updated"
}

change_ip_and_gateway_and_dns_nameservers() {
    cat <<EOF | sudo tee /etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

auto enp0s3
iface enp0s3 inet static
    address $IP
    gateway $GATEWAY
    dns-nameservers $NAMESERVER1 $NAMESERVER2
EOF

    sudo systemctl restart networking
    echo "The interfaces file was updated"
}

change_network_time() {
    # Check if the entry already exists in the ntp.conf file
    if ! grep -q "pool $NTPSERVER1 iburst" /etc/ntp.conf; then
    
        sudo apt update
        sudo apt install -y ntp
        # sed -i '23d' /etc/ntp.conf
        echo -e "\npool $NTPSERVER1 iburst" | sudo tee -a /etc/ntp.conf

        sudo systemctl restart ntp
        echo -e "\nThe ntp.conf file was updated"
    else
        # If the entry already exists, inform the user
        echo "The ntp.conf file already contains the specified NTP server entry"
    fi
}

create_new_user(){
    if id $NEW_USER_NAME &>/dev/null; then
        echo "User $NEW_USER_NAME already exists."
    else
        sudo useradd $NEW_USER_NAME
        echo "$NEW_USER_NAME user created successfully"

        echo "$NEW_USER_NAME:$NEW_USER_PASSWORD" | sudo chpasswd
        echo "The password for the $NEW_USER_NAME user has been applied successfully"

        sudo chage -M $NEW_USER_PASSWORD_EXPIRES_DAY $NEW_USER_NAME
        echo "Password expiration date applied for $NEW_USER_PASSWORD_EXPIRES_DAY days"

        local now=$(date +'%Y-%m-%d')
        local one_month_later=$(date -d "$now +$NEW_USER_ACCOUNT_EXPIRES_MONTH month" +%Y-%m-%d)
        sudo chage -E $one_month_later $NEW_USER_NAME
        echo "Account expiration date applied for $NEW_USER_ACCOUNT_EXPIRES_MONTH month"
    fi
}

change_root_pass(){
    echo "root:$NEW_ROOT_PASSWORD" | sudo chpasswd
    echo "The password for the root user has been applied successfully"
    # passwd root
}

find_processes(){
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

install_ssh(){
    sudo apt install -y openssh-server
    sudo systemctl start ssh
    sudo systemctl enable ssh

    sudo apt install -y ufw
    sudo ufw allow ssh
    sudo ufw enable

    echo -e "\nssh configuration is done successfully"
}

Configure_nftable() {
    local nft_conf="/etc/nftables.conf"

    cat <<EOF | sudo tee $nft_conf
#!/usr/sbin/nft -f

flush ruleset

table ip filter {
    chain input {
        type filter hook input priority 0; policy drop;
        iif lo accept
        ct state established,related accept
        tcp dport 22 accept
    }

    chain forward {
        type filter hook forward priority 0; policy accept;
    }

    chain output {
        type filter hook output priority 0; policy accept;
    }
}
EOF

    # Load the configuration using nft
    sudo nft -f "$nft_conf"

    # Restart and enable nftables service
    sudo systemctl restart nftables
    sudo systemctl enable nftables

    echo -e "\nnft firewall successfully configured."
}


if [[ "$#" -eq 0 ]]; then
    echo "Usage: $0 <conf file address>"
    exit 1
fi

if [[ -f "$1" ]]; then
    source $1
    echo "The conf file has been loaded"
else
    echo "Conf file not found"
    exit 1
fi

update_sources_file
sleep 1
change_nameserver
sleep 1
change_ip_and_gateway_and_dns_nameservers
sleep 1
change_network_time
sleep 1
create_new_user
sleep 1
change_root_pass
sleep 1
find_processes
sleep 1
install_ssh
sleep 1
Configure_nftable
sleep 1
