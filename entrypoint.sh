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

install_server() {
    echo -e "${YELLOW}Installing/Updating Cubic Odyssey Server...${NC}"

    cd /home/container/steamcmd

    echo -e "${YELLOW}Warming up SteamCMD...${NC}"
    ./steamcmd.sh \
        +login "${STEAM_USER}" "${STEAM_PASS}" "${STEAM_AUTH}" \
        +app_license_request ${SRCDS_APPID} \
        +quit || true

    echo -e "${YELLOW}Running SteamCMD to install/update server files...${NC}"
    ./steamcmd.sh \
        +force_install_dir /home/container/cubic-odyssey \
        +login "${STEAM_USER}" "${STEAM_PASS}" "${STEAM_AUTH}" \
        +app_license_request ${SRCDS_APPID} \
        +@sSteamCmdForcePlatformType windows \
        +app_update ${SRCDS_APPID} validate \
        +quit

    echo -e "${GREEN}Installation/Update completed!${NC}"
}

configure_server() {
    echo -e "${YELLOW}Configuring server...${NC}"

    mkdir -p /home/container/cubic-odyssey/config

    cat > /home/container/cubic-odyssey/config/server_config.txt <<EOF
GameParams
{
        m_server ServerParams
        {
                startingPort ${STARTING_PORT}
                endingPort ${ENDING_PORT}
                serverName "${SERVER_NAME}"
                serverPassword "${SERVER_PASSWORD}"
                maxPlayers ${MAX_PLAYERS}
                galaxySeed ${GALAXY_SEED}
                allowRelaying ${ALLOW_RELAYING}
                privateServer ${PRIVATE_SERVER}
                enableCrashDumps ${ENABLE_CRASH_DUMPS}
                enableLogging ${ENABLE_LOGGING}
        }

        m_difficulty DifficultySettings
        {
                damagePlayerScale ${DAMAGE_PLAYER_SCALE}
                damagePirateScale ${DAMAGE_PIRATE_SCALE}
                damageCreatureScale ${DAMAGE_CREATURE_SCALE}
                damageDarknessScale ${DAMAGE_DARKNESS_SCALE}
                damagePlayerShipScale ${DAMAGE_PLAYER_SHIP_SCALE}
                damagePirateShipScale ${DAMAGE_PIRATE_SHIP_SCALE}
                craftingCostScale ${CRAFTING_COST_SCALE}
                tradingCostScale ${TRADING_COST_SCALE}
                damageGearOnDeath ${DAMAGE_GEAR_ON_DEATH}
                loseQbitsOnDeath ${LOSE_QBITS_ON_DEATH}
        }
}
EOF

    echo -e "${GREEN}Configuration complete!${NC}"
}

game_server_is_up_to_date() {
    local manifest="/home/container/cubic-odyssey/steamapps/appmanifest_${SRCDS_APPID}.acf"
    if [ ! -f "$manifest" ]; then
        return 1
    fi

    local installed_buildid
    installed_buildid=$(sed -n 's/.*"buildid"[[:space:]]*"\([0-9]*\)".*/\1/p' "$manifest")
    if [ -z "$installed_buildid" ]; then
        echo -e "${YELLOW}Could not determine currently installed version, updating to be safe...${NC}"
        return 1
    fi

    local latest_buildid
    latest_buildid=$(curl -sSL "https://api.steamcmd.net/v1/info/${SRCDS_APPID}" | sed -n 's/.*"buildid" *: *"\([0-9]*\)".*/\1/p' | head -1)
    if [ -z "$latest_buildid" ]; then
        echo -e "${YELLOW}Could not check for updates, updating to be safe...${NC}"
        return 1
    fi

    if [ "$installed_buildid" != "$latest_buildid" ]; then
        echo -e "${YELLOW}Update available: build ${installed_buildid} -> ${latest_buildid}${NC}"
        return 1
    fi

    echo -e "${GREEN}Server is up to date (build ${installed_buildid})${NC}"
    return 0
}

if [ ! -f "/home/container/cubic-odyssey/server/CubicOdysseyServer.exe" ]; then
    echo -e "${YELLOW}Server files not found. Installing...${NC}"
    install_server
elif [ "${AUTO_UPDATE}" == "1" ] && ! game_server_is_up_to_date; then
    install_server
else
    echo -e "${GREEN}Server files found. Skipping installation.${NC}"
fi

configure_server

cd /home/container/cubic-odyssey

echo -e "${GREEN}Starting Cubic Odyssey Server...${NC}"

exec wine ./server/CubicOdysseyServer.exe \
    -Gamemode="${GAMEMODE}"
