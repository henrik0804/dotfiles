#!/bin/bash

set -eu -o pipefail

LOG_FILE='/tmp/zen_window_manager.log'
focused_window=$(aerospace list-windows --json --focused --format "%{window-id} %{window-title} %{app-bundle-id}")

app_bundle_id=$(echo "$focused_window" | jq -r '.[0]."app-bundle-id"')
if [[ "$app_bundle_id" != "app.zen-browser.zen" ]]; then
    # echo "No Browser instance" >> "$LOG_FILE"
    return
fi

window_id=$(echo "$focused_window" | jq -r '.[0]."window-id"')
window_title=$(echo "$focused_window" | jq -r '.[0]."window-title"')

# echo "Executed anyways" >> "$LOG_FILE"

if [[ "$window_title" == *"Developer Tools"* ]]; then
    echo "Is Dev-Tool" >> "$LOG_FILE"
    aerospace join-with --window-id $window_id right
    aerospace layout --window-id $window_id v_accordion
    echo "window id: $window_id" >> "$LOG_FILE"
fi

