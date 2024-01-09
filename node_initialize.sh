#!/usr/bin/env bash
CONFIG_FILE="/root/.blocx/blocx.conf"
url_array=(
    "https://api4.my-ip.io/ip"
    "https://checkip.amazonaws.com"
    "https://api.ipify.org"
)

function get_ip() {
    for url in "$@"; do
        WANIP=$(curl --silent -m 15 "$url" | tr -dc '[:alnum:].')
        # Remove dots from the IP address
        IP_NO_DOTS=$(echo "$WANIP" | tr -d '.')
        # Check if the result is a valid number
        if [[ "$IP_NO_DOTS" != "" && "$IP_NO_DOTS" =~ ^[0-9]+$ ]]; then
            break
        fi
    done
}

if [[ -f "$CONFIG_FILE" ]]; then
    RPCUSER=$(grep "^rpcuser=" "$conf_file" | cut -d "=" -f 2)
    PASSWORD=$(grep "^rpcpassword=" "$conf_file" | cut -d "=" -f 2)
else
    get_ip "${url_array[@]}"
    RPCUSER=$(pwgen -1 8 -n)
    PASSWORD=$(pwgen -1 20 -n)
    echo "rpcuser=$RPCUSER" >> "$CONFIG_FILE"
    echo "rpcpassword=$PASSWORD" >> "$CONFIG_FILE"
    echo "rpcallowip=127.0.0.1" >> "$CONFIG_FILE"
    echo "listen=1" >> "$CONFIG_FILE"
    echo "server=1" >> "$CONFIG_FILE"
    echo "daemon=1" >> "$CONFIG_FILE"
    echo "externalip=$WANIP" >> "$CONFIG_FILE"
    echo "masternode=1" >> "$CONFIG_FILE"
    echo "maxconnections=256" >> "$CONFIG_FILE"
    echo "masternodeblsprivkey=$KEY" >> "$CONFIG_FILE"
fi

if ! grep -q "^RPCUSER=" ~/.bashrc; then
    echo RPCUSER=$RPCUSER >> ~/.bashrc
    echo PASSWORD=$PASSWORD >> ~/.bashrc
    echo RPCPORT=12972 >> ~/.bashrc
fi
source ~/.bashrc

while true; do
 if [[ $(pgrep blocxd) == "" ]]; then 
   echo -e "Starting daemon..."
   blocxd -daemon
 fi
 sleep 120
done
