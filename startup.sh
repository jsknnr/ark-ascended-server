#!/bin/bash
# Update Ark Ascended
steamcmd +@sSteamCmdForcePlatformType windows +force_install_dir "$ARK_PATH" +login anonymous +app_update 2430930 validate +quit
# Launch Supervisor
supervisord
