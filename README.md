# InitialSettings.sh
## Description

This Bash script automates various initial system configuration tasks. It is designed to be used with a configuration file to set up system parameters. The script performs tasks such as updating the sources.list file, changing network settings, configuring NTP, creating a new user, changing the root password, finding processes, installing and configuring SSH, and setting up a basic firewall using nftables.

## Setup
1. Clone this repository to your desired folder.
```
git clone https://github.com/mhmdrzrasi/Bash-Script.git
```
2. Review the configuration file format and update it accordingly.

## Usage
Run the code with this command
```
bash InitialSettings.sh <conf file address>
```

## Concepts
- Update Sources File
- Change Nameserver
- Change IP, Gateway, and DNS Nameservers
- Change Network Time
- Create New User
- Change Root Password
- Find specific processes
  - Finds processes owned by a specified user
  - Finds processes with a pid less than a specified number
- Install SSH
- Configure nftables
