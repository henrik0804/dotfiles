#!/bin/bash

set -eu -o pipefail

TARGET_WORKSPACE_NAME="browser"

# Get the newly opened Developer Tools window ID (passed as an argument)
new_dev_tool_window_id="$1"

echo "New Developer Tools window detected: $new_dev_tool_window_id"

# Move the new window to the target workspace
echo "Moving new Developer Tools window ($new_dev_tool_window_id) to workspace: $TARGET_WORKSPACE_NAME"
aerospace move-node-to-workspace --window-id $new_dev_tool_window_id $TARGET_WORKSPACE_NAME

# Find an existing Developer Tool window to join with
existing_dev_tool_id=$(aerospace list-windows --all --json | jq -r '.[] | select(."app-name" == "Zen" and ."window-title" | contains("Developer Tools")) | ."window-id"' | head -n 1)

if [ -n "$existing_dev_tool_id" ]; then
    echo "Joining new Developer Tools window ($new_dev_tool_window_id) with existing window ($existing_dev_tool_id)"
    aerospace join-with --window-id $new_dev_tool_window_id accordion-vertical
else
    echo "No existing Developer Tools window found. Keeping window ($new_dev_tool_window_id) as is."
fi
