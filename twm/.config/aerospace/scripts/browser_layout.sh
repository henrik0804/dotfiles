
#!/bin/bash

set -eu -o pipefail

LOG_FILE='/tmp/zen_window_manager.log'
TARGET_WORKSPACE_NAME="browser"

# Get window ID for an app and open it if not running
get_window_id() {
    local app_name="$1"
    local windows=$(aerospace list-windows --all --json)
    local window_id=$(echo -e "$windows" | jq -r --arg app "$app_name" '.[] | select(.["app-name"] == $app) | .["window-id"]')
    
    if [ -z "$window_id" ]; then
        open -a "$app_name"
        if [ $? -ne 0 ]; then
            echo "Failed to open $app_name" >> "$LOG_FILE"
            exit 1
        fi
        while [ -z "$window_id" ]; do
            windows=$(aerospace list-windows --all --json)
            window_id=$(echo -e "$windows" | jq -r --arg app "$app_name" '.[] | select(.["app-name"] == $app) | .["window-id"]')
            sleep 0.1
        done
    fi
    
    echo "$window_id"
}

aerospace workspace $TARGET_WORKSPACE_NAME

# Get all Zen windows
windows=$(aerospace list-windows --all --json | jq -c '.[] | select(."app-name" == "Zen")')

echo "$windows" >> "$LOG_FILE"

main_window_id=""
developer_tools=()

# Identify main window and developer tools
while read -r window; do
    window_id=$(echo "$window" | jq -r '."window-id"')
    window_title=$(echo "$window" | jq -r '."window-title"')
    echo "$window_title" >> "$LOG_FILE"
    
    if [[ "$window_title" == *"Developer Tools"* ]]; then
        developer_tools+=("$window_id")
    else
        main_window_id="$window_id"
    fi

done <<< "$windows"

exec 2>> "$LOG_FILE"

aerospace flatten-workspace-tree --workspace $TARGET_WORKSPACE_NAME

# Move main window to workspace
if [ -n "$main_window_id" ]; then
    aerospace move-node-to-workspace --window-id $main_window_id $TARGET_WORKSPACE_NAME
    aerospace move --window-id $main_window_id left
fi

# Move developer tool windows to workspace
for dev_window in "${developer_tools[@]}"; do
    aerospace move-node-to-workspace --window-id $dev_window $TARGET_WORKSPACE_NAME
done

# Set up layout
if [ -n "$main_window_id" ]; then
    aerospace move --window-id $main_window_id left
fi

for dev_window in "${developer_tools[@]}"; do
    aerospace join-with --window-id $dev_window right
    aerospace layout --window-id $dev_window v_accordion
done

aerospace focus right
aerospace layout v_accordion

