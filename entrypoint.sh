#!/bin/bash

set -e

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}  Cubic Odyssey Dedicated Server${NC}"
echo -e "${GREEN}======================================${NC}"

# Set defaults if not provided
STEAM_USER=${STEAM_USER:-anonymous}
STEAM_PASS=${STEAM_PASS:-}
STEAM_AUTH=${STEAM_AUTH:-}
GAME_PORT=${GAME_PORT:-20000}
MAX_PLAYERS=${MAX_PLAYERS:-20}
GAMEMODE=${GAMEMODE:-adventure}
SERVER_PASSWORD=${SERVER_PASSWORD:-}
AUTO_UPDATE=${AUTO_UPDATE:-1}
SRCDS_APPID=${SRCDS_APPID:-3858450}

# Function to install/update server
install_server() {
    echo -e "${YELLOW}Installing/Updating Cubic Odyssey Server...${NC}"

    # Handle anonymous login
    if [[ -z "${STEAM_USER}" ]] || [[ "${STEAM_PASS}" == "" ]]; then
        echo -e "${YELLOW}Steam credentials not set.${NC}"
        echo -e "${YELLOW}Using anonymous user to download server files.${NC}"
        STEAM_USER=anonymous
        STEAM_PASS=""
        STEAM_AUTH=""
    else
        echo -e "${GREEN}Using Steam account: ${STEAM_USER}${NC}"
    fi

    # Download SteamCMD if not exists
    if [ ! -f "/home/container/steamcmd/steamcmd.sh" ]; then
        echo -e "${YELLOW}Downloading SteamCMD...${NC}"
        mkdir -p /home/container/steamcmd
        cd /home/container/steamcmd
        curl -sSL -o steamcmd.tar.gz https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
        tar -xzvf steamcmd.tar.gz
        rm steamcmd.tar.gz
    fi

    cd /home/container/steamcmd

    # Install/Update game
    echo -e "${YELLOW}Running SteamCMD to install/update server files...${NC}"
    ./steamcmd.sh \
        +force_install_dir /home/container \
        +login "${STEAM_USER}" "${STEAM_PASS}" "${STEAM_AUTH}" \
        +app_license_request ${SRCDS_APPID} \
        +@sSteamCmdForcePlatformType windows \
        +app_update ${SRCDS_APPID} validate \
        +quit

    # Set up Steam client libraries
    mkdir -p /home/container/.steam/sdk32
    mkdir -p /home/container/.steam/sdk64

    if [ -f "/home/container/steamcmd/linux32/steamclient.so" ]; then
        cp -v /home/container/steamcmd/linux32/steamclient.so /home/container/.steam/sdk32/
    fi

    if [ -f "/home/container/steamcmd/linux64/steamclient.so" ]; then
        cp -v /home/container/steamcmd/linux64/steamclient.so /home/container/.steam/sdk64/
    fi

    echo -e "${GREEN}Installation/Update completed!${NC}"
}

# Function to configure server
configure_server() {
    echo -e "${YELLOW}Configuring server...${NC}"

    # Create config directory if it doesn't exist
    mkdir -p /home/container/config

    # Create or update server_config.txt
    cat > /home/container/config/server_config.txt <<EOF
{
	serverName "${SERVER_NAME}"
	privateServer ${PRIVATE_SERVER}
	galaxySeed ${GALAXY_SEED}
}
EOF

    echo -e "${GREEN}Configuration complete!${NC}"
}

# Check if server files exist
if [ ! -f "/home/container/server/CubicOdysseyServer.exe" ]; then
    echo -e "${YELLOW}Server files not found. Installing...${NC}"
    install_server
    configure_server
elif [ "${AUTO_UPDATE}" == "1" ]; then
    echo -e "${YELLOW}Auto-update enabled. Checking for updates...${NC}"
    install_server
    configure_server
else
    echo -e "${GREEN}Server files found. Skipping installation.${NC}"
    configure_server
fi

# Navigate to server directory
cd /home/container

# Display server configuration
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}Server Configuration:${NC}"
echo -e "${GREEN}======================================${NC}"
echo -e "Server Name: ${SERVER_NAME}"
echo -e "Game Port: ${GAME_PORT}"
echo -e "Max Players: ${MAX_PLAYERS}"
echo -e "Gamemode: ${GAMEMODE}"
echo -e "Private Server: ${PRIVATE_SERVER}"
echo -e "Galaxy Seed: ${GALAXY_SEED}"
echo -e "Password Protected: $([ -n "${SERVER_PASSWORD}" ] && echo "Yes" || echo "No")"
echo -e "${GREEN}======================================${NC}"

# Start server
echo -e "${GREEN}Starting Cubic Odyssey Server...${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"

exec wine ./server/CubicOdysseyServer.exe \
    -Port="${GAME_PORT}" \
    -Password="${SERVER_PASSWORD}" \
    -Gamemode="${GAMEMODE}" \
    -MaxNumPlayers="${MAX_PLAYERS}"
