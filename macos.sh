#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${(%):-%N}")" && pwd)"
IMAGE="$SCRIPT_DIR/background.jpg"

echo "Starting macOS setup…"

echo "Configuring Dock..."
defaults write com.apple.dock autohide -bool true
defaults write com.apple.dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.25
killall Dock

echo "Configuring Finder..."
defaults write com.apple.finder ShowSidebar -bool true
defaults write com.apple.finder ShowPathbar -bool true
defaults write com.apple.finder ShowStatusBar -bool true
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv" # list view
defaults write com.apple.finder AppleShowAllFiles -bool true
killall Finder

echo "Enabling Touch ID for sudo..."
if ! grep -q pam_tid /etc/pam.d/sudo; then
  sudo sed -i '' '1i\
auth       sufficient     pam_tid.so
' /etc/pam.d/sudo
fi

echo "Customizing screenshots..."
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture type -string "png"
killall SystemUIServer

echo "Configuring trackpad gestures..."
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 3
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

echo "Disabling Cmd+Shift+3 and Cmd+Shift+4 screenshots..."
# Disable entire screenshot app keyboard shortcuts
defaults write com.apple.screencapture show-thumbnail -bool FALSE

# Remap shortcuts using NSUserKeyEquivalents to empty string
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 28 "{enabled = 0;}" # Cmd+Shift+3
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 29 "{enabled = 0;}" # Cmd+Shift+4
killall SystemUIServer

# Faster key repeat rate (default is 2.5, lower is faster)
defaults write NSGlobalDomain KeyRepeat -int 1 # macos settings correspond to: 120, 90, 60, 30, 12, 6, 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15 # macos settings correspond to: 120, 94, 68, 35, 25, 15

osascript -e 'tell application "System Events" to tell every desktop to set picture to "'"$IMAGE"'"'

echo
echo "Accessibility Reminder"
echo "go to System Settings → Privacy & Security → Accessibility"
echo "and enable Hammerspoon, Borders, and Aerospace manually."
