#!/bin/bash

# Quick function to generate a timestamp
timestamp () {
  date +"%Y-%m-%d %H:%M:%S,%3N"
}

# Make sure required arguments are set
if [ -z "$SERVER_MAP" ]; then
    SERVER_MAP="TheIsland_WP"
    echo "$(timestamp) WARN: SERVER_MAP not set, using default: $SERVER_MAP"
fi

if [ -z "$SESSION_NAME" ]; then
    echo "$(timestamp) ERROR: SESSION_NAME environment variable must be set"
    exit 1
fi

if [ -z "$GAME_PORT" ]; then
    GAME_PORT="7777"
    echo "$(timestamp) WARN: GAME_PORT not set, using default: $GAME_PORT UDP"
fi

if [ -z "$SERVER_PASSWORD" ]; then
    echo "$(timestamp) ERROR: SERVER_PASSWORD environment variable must be set"
    exit 1
fi

if [ -z "$SERVER_ADMIN_PASSWORD" ]; then
    echo "$(timestamp) ERROR: SERVER_ADMIN_PASSWORD environment variable must be set"
    exit 1
fi

# Check for correct ownership
if ! touch "${ARK_PATH}/ShooterGame/Saved/test"; then
    echo ""
    echo "$(timestamp) ERROR: The ownership of /home/steam/ark/ShooterGame/Saved is not correct and the server will not be able to save..."
    echo "the directory that you are mounting into the container needs to be owned by 10000:10000 (by default)"
    echo "from your container host attempt the following command 'chown -R 10000:10000 /your/ark/folder'"
    echo ""
    exit 1
fi

# Cleanup test write
rm "${ARK_PATH}/ShooterGame/Saved/test"

# Update Ark Ascended
echo "$(timestamp) INFO: Updating Ark Survival Ascended Dedicated Server"
steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$ARK_PATH" +login anonymous +app_update 2430930 validate +quit

# Check that steamcmd was successful
if [ $? != 0 ]; then
    echo "$(timestamp) ERROR: steamcmd was unable to successfully initialize and update Ark Survival Ascended Dedicated Server"
    exit 1
fi

# Check that log directory exists, if not create
if ! [ -d "${ARK_PATH}/ShooterGame/Saved/Logs/" ]; then
    mkdir -p "${ARK_PATH}/ShooterGame/Saved/Logs/"
fi

# Check that log file exists, if not create
if ! [ -f "${ARK_PATH}/ShooterGame/Saved/Logs/ShooterGame.log" ]; then
    touch "${ARK_PATH}/ShooterGame/Saved/Logs/ShooterGame.log"
fi

# Link logfile to stdout of pid 1 so we can see logs
ln -sf /proc/1/fd/1 "${ARK_PATH}/ShooterGame/Saved/Logs/ShooterGame.log"

# Build Ark Ascended launch command
LAUNCH_COMMAND="${SERVER_MAP}?SessionName=${SESSION_NAME}?Port=${GAME_PORT}?ServerPassword=${SERVER_PASSWORD}?ServerAdminPassword=${SERVER_ADMIN_PASSWORD}"

if [ -n "${RCON_PORT}" ]; then
    LAUNCH_COMMAND="${LAUNCH_COMMAND}?RCONEnabled=True?RCONPort=${RCON_PORT}"
fi

if [ -n "${EXTRA_SETTINGS}" ]; then
    LAUNCH_COMMAND="${LAUNCH_COMMAND}${EXTRA_SETTINGS}"
fi

if [ -n "${EXTRA_FLAGS}" ]; then
    LAUNCH_COMMAND="${LAUNCH_COMMAND} ${EXTRA_FLAGS}"
fi

if [ -n "${MODS}" ]; then
    LAUNCH_COMMAND="${LAUNCH_COMMAND} -mods=${MODS}"
fi

# Launch ASE Server in Proton
echo "$(timestamp) INFO: Starting Ark Survival Ascended dedicated server"
${STEAM_PATH}/compatibilitytools.d/GE-Proton${GE_PROTON_VERSION}/proton run ${ARK_PATH}/ShooterGame/Binaries/Win64/ArkAscendedServer.exe ${LAUNCH_COMMAND}

# Capture Proton process pid that launches ASA
ASE_PID=$!

# If pid closes, we close
wait $ASE_PID

echo "$(timestamp) WARN: ASA dedicated server pid has closed, exitting container"
exit 0
