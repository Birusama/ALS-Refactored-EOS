#!/bin/bash

# --- Configuration ---
# Path to your UE5 Dedicated Server executable
UE5_SERVER_PATH="/path/to/YourProject/Binaries/Linux/YourProjectServer" 
# Example: /home/user/UnrealEngine/YourProject/Binaries/Linux/YourProjectServer

NODE_VERSION="lts"

GAME_PORT="7777"

STATS_PORT="6666"

REMOTE_CONTROL_PORT_HTTP="30010"

REMOTE_CONTROL_PORT_WEBSOCKET="30020"

# Arguments to pass to the UE5 Dedicated Server
UE5_ADDTL_SERVER_ARGS="-log"

printf -v UE5_SERVER_ARGS "%s -port=%d -statsPort=%d\n" "$UE5_ADDTL_SERVER_ARGS" "$GAME_PORT" "$STATS_PORT"


# Arguments to pass to the UE5 Dedicated Server
# UE5_SERVER_ARGS="-log -port=7777" 
# Example: -log -port=7777 -QueryPort=27015


echo "Launching TargetVector Dedicated Server..."

echo "🔎 Checking Dependencies"

# Check if Node.js is installed
if ! command -v node &> /dev/null
then
    echo "❌ Node.js not found. Installing Node.js using NVM..."

    # Install NVM
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash

    # Source NVM to make it available in the current shell
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

    # Install the latest LTS version of Node.js
    nvm install --"$NODE_VERSION"

    # Set the installed LTS version as default
    nvm alias default "$NODE_VERSION"/*

    echo "✅ Node.js Installation Complete."
else
    echo "✅ Node.js is already installed."
fi

# --- Launching UE5 Dedicated Server ---

echo "Launching TargetVector Dedicated Server..."

if [ -f "$UE5_SERVER_PATH" ]; then
    "$UE5_SERVER_PATH" "$UE5_SERVER_ARGS"
else
    echo "Error: UE5 Dedicated Server executable not found at $UE5_SERVER_PATH"
    exit 1
fi

echo "UE5 Dedicated Server launched."