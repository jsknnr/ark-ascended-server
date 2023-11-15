#!/bin/bash
# Update Ark Ascended
steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$ARK_PATH" +login anonymous +app_update 2430930 validate +quit

# Make sure required arguments are set
if [ -z "$SERVER_MAP" ]; then
    SERVER_MAP="TheIsland_WP"
    echo "WARN: SERVER_MAP not set, using default: $SERVER_MAP"
fi

if [ -z "$SESSION_NAME" ]; then
    echo "ERROR: SESSION_NAME environment variable must be set"
    exit 1
fi

if [ -z "$GAME_PORT" ]; then
    GAME_PORT="7777"
    echo "WARN: GAME_PORT not set, using default: $GAME_PORT UDP"
fi

if [ -z "$SERVER_PASSWORD" ]; then
    echo "ERROR: SERVER_PASSWORD environment variable must be set"
    exit 1
fi

if [ -z "$SERVER_ADMIN_PASSWORD" ]; then
    echo "ERROR: SERVER_ADMIN_PASSWORD environment variable must be set"
    exit 1
fi

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
    LAUNCH_COMMAND="${LAUNCH_COMMAND} ${MODS}"
fi

echo ""
echo "DEBUG: Launch command constructed as: $LAUNCH_COMMAND"
echo ""

export LAUNCH_COMMAND

# Launch Supervisor
supervisord
