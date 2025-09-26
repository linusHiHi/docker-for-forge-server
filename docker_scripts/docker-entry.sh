#!/bin/bash

if [ ! -f "eula.txt" ]; then
    echo "eula.txt not found, creating with eula=true"
    echo "eula=true" > eula.txt
fi

if [ -f "/app/modified_files/user_jvm_arg.txt" ]; then
    echo "user_jvm_args.txt found, copying from modified_files"
    cp "/app/modified_files/user_jvm_arg.txt" "user_jvm_args.txt"
fi

# Start Minecraft server
echo "Starting Minecraft Forge Server..."
java @user_jvm_args.txt @libraries/net/minecraftforge/forge/${MC_VERSION:-1.18.2}-${FORGE_VERSION:-40.2.4}/unix_args.txt "$@"

