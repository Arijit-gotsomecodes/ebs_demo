#!/bin/bash

# EB Profile Manager
# Manages AWS profiles for Elastic Beanstalk

CONFIG_FILE=".elasticbeanstalk/config.yml"
VALID_PROFILES=("default" "Personal" "temp")

function switch_profile() {
    local profile=$1
    
    # Validate profile
    if [[ ! " ${VALID_PROFILES[@]} " =~ " ${profile} " ]]; then
        echo "Error: Invalid profile '${profile}'"
        echo "Valid profiles: ${VALID_PROFILES[*]}"
        return 1
    fi
    
    # Check if config file exists
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Error: EB config file not found at $CONFIG_FILE"
        return 1
    fi
    
    # Update profile in config.yml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/profile: .*/profile: ${profile}/" "$CONFIG_FILE"
    else
        # Linux
        sed -i "s/profile: .*/profile: ${profile}/" "$CONFIG_FILE"
    fi
    
    echo "Switched EB profile to: ${profile}"
}

function current_profile() {
    if [[ ! -f "$CONFIG_FILE" ]]; then
        echo "Error: EB config file not found at $CONFIG_FILE"
        return 1
    fi
    
    local profile=$(grep "profile:" "$CONFIG_FILE" | awk '{print $2}')
    
    if [[ -z "$profile" || "$profile" == "null" ]]; then
        echo "Current EB profile: default (not set)"
    else
        echo "Current EB profile: ${profile}"
    fi
}

# Main command router
case "$1" in
    switch)
        if [[ -z "$2" ]]; then
            echo "Usage: eb-profile-manager.sh switch <profile>"
            echo "Valid profiles: ${VALID_PROFILES[*]}"
            exit 1
        fi
        switch_profile "$2"
        ;;
    current)
        current_profile
        ;;
    *)
        echo "EB Profile Manager"
        echo ""
        echo "Usage:"
        echo "  ./eb-profile-manager.sh switch <profile>  - Switch to specified profile"
        echo "  ./eb-profile-manager.sh current           - Show current profile"
        echo ""
        echo "Valid profiles: ${VALID_PROFILES[*]}"
        exit 1
        ;;
esac
