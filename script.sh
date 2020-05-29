#!/bin/bash

# Only run as a root user
if [ "$(sudo id -u)" != "0" ]; then
    echo "This script may only be run as root or with user with sudo privileges."
    exit 1
fi

HBAR="---------------------------------------------------------------------------------------"

# import messages
source <(curl -sL https://raw.githubusercontent.com/syscoin/Masternode-Install-Script/master/messages.sh) 

pause(){
  echo ""
  read -n1 -rsp $'Press any key to continue or Ctrl+C to exit...\n'
}

do_exit(){
  echo ""
  echo "======================================================================================"
  echo "            Update script for Governance GenKey"
  echo "======================================================================================"
  exit 0
}

start_syscoind(){
  echo "$MESSAGE_SYSCOIND"
  sudo service syscoind start     # start the service
  sudo systemctl enable syscoind  # enable at boot 
  clear
}

stop_syscoind(){
  echo "$MESSAGE_STOPPING"
  sudo service syscoind stop
  echo "Shutting down Syscoin Node"
  sleep 30
  clear
}

# errors are shown if LC_ALL is blank when you run locale
if [ "$LC_ALL" = "" ]; then export LC_ALL="$LANG"; fi

clear
echo "$MESSAGE_WELCOME"
pause
clear

echo "$MESSAGE_PLAYER_ONE"
sleep 1
clear

RESOLVED_ADDRESS=$(curl -s ipinfo.io/ip)

SYSCOIN_BRANCH="master"
DEFAULT_PORT=8369

# syscoin.conf value defaults
rpcuser="sycoinrpc"
rpcpassword="$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)"
masternodeprivkey=""
externalip="$RESOLVED_ADDRESS"
port="$DEFAULT_PORT"

# try to read them in from an existing install
if sudo test -f /home/syscoin/.syscoin/syscoin.conf; then
  sudo cp /home/syscoin/.syscoin/syscoin.conf ~/syscoin.conf
  sudo chown $(whoami).$(id -g -n $(whoami)) ~/syscoin.conf
  source ~/syscoin.conf
  rm -f ~/syscoin.conf
fi

RPC_USER="$rpcuser"
RPC_PASSWORD="$rpcpassword"
MASTERNODE_PORT="$port"


if [ "$externalip" != "$RESOLVED_ADDRESS" ]; then
  echo ""
  echo "WARNING: The syscoin.conf value for externalip=${externalip} does not match your detected external ip of ${RESOLVED_ADDRESS}."
  echo ""
fi
read -e -p "External IP Address [$externalip]: " EXTERNAL_ADDRESS
if [ "$EXTERNAL_ADDRESS" = "" ]; then
  EXTERNAL_ADDRESS="$externalip"
fi
if [ "$port" != "" ] && [ "$port" != "$DEFAULT_PORT" ]; then
  echo ""
  echo "WARNING: The syscoin.conf value for port=${port} does not match the default of ${DEFAULT_PORT}."
  echo ""
fi
read -e -p "Masternode Port [$port]: " MASTERNODE_PORT
if [ "$MASTERNODE_PORT" = "" ]; then
  MASTERNODE_PORT="$port"
fi

masternode_private_key(){
  read -e -p "Masternode Private Key [$masternodeprivkey]: " MASTERNODE_PRIVATE_KEY
  if [ "$MASTERNODE_PRIVATE_KEY" = "" ]; then
    if [ "$masternodeprivkey" != "" ]; then
      MASTERNODE_PRIVATE_KEY="$masternodeprivkey"
    else
      echo "You must enter a masternode private key!";
      masternode_private_key
    fi
  fi
}

masternode_private_key

#Generating Random Passwords
RPC_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

clear

# syscoin conf file
SYSCOIN_CONF=$(cat <<EOF
# rpc config
rpcuser=user
rpcpassword=$RPC_PASSWORD
rpcallowip=127.0.0.1
rpcbind=127.0.0.1
rpcport=8370
# syscoind config
listen=1
server=1
daemon=1
maxconnections=24
# masternode config
masternode=1
masternodeprivkey=$MASTERNODE_PRIVATE_KEY
externalip=$EXTERNAL_ADDRESS
port=$MASTERNODE_PORT
EOF
)

# testnet config
SYSCOIN_TESTNET_CONF=$(cat <<EOF
# testnet config
gethtestnet=1
addnode=54.203.169.179
addnode=54.190.239.153
EOF
)


# functions to install a masternode from scratch
update_conf(){
  echo "UPDATING CONF"

  echo "$SYSCOIN_CONF" > ~/syscoin.conf
  if [ ! "$IS_MAINNET" = "" ] && [ ! "$IS_MAINNET" = "y" ] && [ ! "$IS_MAINNET" = "Y" ]; then
    echo "$SYSCOIN_TESTNET_CONF" >> ~/syscoin.conf
  fi

  # create conf directory
  sudo mkdir -p /home/syscoin/.syscoin
  sudo rm -rf /home/syscoin/.syscoin/debug.log
  sudo mv -f ~/syscoin.conf /home/syscoin/.syscoin/syscoin.conf
  sudo chown -R syscoin.syscoin /home/syscoin/.syscoin
  sudo chmod 600 /home/syscoin/.syscoin/syscoin.conf
  clear
}

stop_syscoind
update_conf
start_syscoind

echo "Update Finished"
echo "Syscoin Node now started with new credentials"
