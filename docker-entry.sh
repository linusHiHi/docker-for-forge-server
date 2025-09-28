#!/bin/bash
cd /app
if [ ! -f "eula.txt" ]; then
    echo "eula.txt not found, creating with eula=true"
    echo "eula=true" > eula.txt
fi

cat eula.txt | grep -q "eula=true"
if [ $? -ne 0 ]; then
    echo "eula.txt does not contain 'eula=true'. Please read and accept the EULA at https://account.mojang.com/documents/minecraft_eula"
    echo "eula=true" > eula.txt
fi

if [ -f "/app/modified_data/user_jvm_args.txt" ]; then
    echo "user_jvm_args.txt found, copying from modified_data"
    cp "/app/modified_data/user_jvm_args.txt" "/app/user_jvm_args.txt"
fi

if [ ! -f "server.properties" ]; then
    echo "server.properties not found, creating default..."
    cp /app/default_files/server.properties /app/server.properties
fi

cp /app/modified_data/* /app/ -r

# Ensure user_jvm_args.txt exists before starting server
if [ ! -f "/app/user_jvm_args.txt" ]; then
    echo "user_jvm_args.txt not found, creating default..."
    echo "-Xmx10G -Xms2G" > user_jvm_args.txt
fi

# Start Minecraft server
echo "Starting Minecraft Forge Server..."
if [ "${JAVA_VERSION:-8}" -lt 17 ]; then
    # Extract only non-comment lines from user_jvm_args.txt
    JVM_ARGS=$(grep -v '^#' user_jvm_args.txt | grep -v '^$' | tr '\n' ' ')
    echo "Using JVM args: $JVM_ARGS"
    java $JVM_ARGS -jar forge-$MC_VERSION-$FORGE_VERSION.jar nogui "$@"
else
    java @user_jvm_args.txt @libraries/net/minecraftforge/forge/${MC_VERSION:-1.18.2}-${FORGE_VERSION:-40.2.4}/unix_args.txt nogui "$@"
fi


