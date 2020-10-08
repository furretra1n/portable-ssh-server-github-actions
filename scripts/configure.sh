#!/bin/bash
# Portable SSH Server by PANCHO7532
# This script is executed when GitHub actions is initialized.
# Prepares dependencies, ngrok, and all stuff

# First, install required packages
sudo apt update
sudo apt install -y dropbear gcc cmake make unzip zip tmux build-essential

# Second, download ngrok
wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip
unzip ngrok-stable-linux-amd64.zip
chmod +x ngrok

# Third, configure dropbear, squid, and stunnel
sudo chmod 0777 /etc/default/dropbear
sudo chmod 0777 /etc/shells
sudo cp ./resources/dropbear_cfg.conf /etc/default/dropbear
echo -e "/bin/false\r\n/usr/sbin/nologin" >> /etc/shells
sudo cp ./resources/banner_msg.dat /etc/banner_msg.dat

# Fourth, download and install BadVPN
wget https://github.com/ambrop72/badvpn/archive/master.zip
unzip master.zip
mkdir badvpn-master/build && cd badvpn-master/build
cmake .. -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1
sudo make install
cd $GITHUB_WORKSPACE

# 5th, configuring users and etc
sudo echo -e "runner:$RUNNER_PASSWORD\r\n" | sudo chpasswd

# 6th, starting stuff
sudo service dropbear restart
tmux new-session -d -s b0 '/usr/local/bin/badvpn-udpgw --listen-addr 127.0.0.1:7300 --max-clients 250 --max-connections-for-client 3'

# 7th, preparing ngrok
./ngrok authtoken $NGROK_AUTH_TOKEN
exit