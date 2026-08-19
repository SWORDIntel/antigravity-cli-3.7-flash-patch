#!/usr/bin/env bash
# ==============================================================================
# Antigravity CLI Configuration & Patch Utility (Interactive TUI)
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SETTINGS_DIR="${HOME}/.gemini/antigravity-cli"
SETTINGS_FILE="${SETTINGS_DIR}/settings.json"
BACKUP_DIR="${SETTINGS_DIR}/backups"
LOCAL_TEMPLATE="${SCRIPT_DIR}/settings.json"

mkdir -p "${SETTINGS_DIR}"
mkdir -p "${BACKUP_DIR}"

USER_HOME="${HOME}"

# ANSI Colors
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m"

function print_banner() {
  clear
  echo -e "${BOLD}${CYAN}======================================================${NC}"
  echo -e "${BOLD}${CYAN}           Antigravity CLI 3.7 Flash Patch            ${NC}"
  echo -e "${BOLD}${CYAN}======================================================${NC}"
  echo ""
}

function backup_settings() {
  if [ -f "${SETTINGS_FILE}" ]; then
    local TIMESTAMP
    TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
    local BACKUP_FILE="${BACKUP_DIR}/settings_${TIMESTAMP}.json"
    cp "${SETTINGS_FILE}" "${BACKUP_FILE}"
    echo -e "${GREEN}✓ Backup created:${NC} ${BACKUP_FILE}"
  else
    echo -e "${YELLOW}ℹ No existing configuration found to back up.${NC}"
  fi
}

function apply_default_config() {
  print_banner
  echo -e "${BOLD}Applying default configuration...${NC}"
  echo ""
  
  # Step 1: Backup
  backup_settings

  # Step 2: Write default configuration
  if [ -f "${LOCAL_TEMPLATE}" ]; then
    sed "s|\"/home/user\"|\"${USER_HOME}\"|g" "${LOCAL_TEMPLATE}" > "${SETTINGS_FILE}"
  else
    cat <<EOF > "${SETTINGS_FILE}"
{
  "allowNonWorkspaceAccess": true,
  "enableTelemetry": false,
  "model": "Gemini 3.7 Flash (High)",
  "permissions": {
    "allow": [
      "command(*)"
    ]
  },
  "trustedWorkspaces": [
    "${USER_HOME}"
  ]
}
EOF
  fi

  echo ""
  echo -e "${GREEN}✓ Default configuration successfully applied!${NC}"
  echo ""
  echo -e "Settings saved to: ${BOLD}${SETTINGS_FILE}${NC}"
  echo -e "  - Model:                 ${BOLD}Gemini 3.7 Flash (High)${NC}"
  echo -e "  - Telemetry:             ${BOLD}Disabled (false)${NC}"
  echo -e "  - Non-Workspace Access:  ${BOLD}Allowed (true)${NC}"
  echo -e "  - Command Execution:     ${BOLD}Allow All (command(*))${NC}"
  echo -e "  - Trusted Workspace:     ${BOLD}${USER_HOME}${NC}"
  echo ""
  read -rp "Press Enter to return to the menu..."
}

function select_model() {
  print_banner
  echo -e "${BOLD}Select Active Model for Antigravity CLI${NC}"
  echo ""

  # Define model list (with auto-detection or curated list)
  local MODEL_NAMES=(
    "Gemini 3.7 Flash (High)"
    "Gemini 3.7 Flash (Medium)"
    "Gemini 3.7 Flash (Low)"
    "Gemini 3.6 Flash (High)"
    "Gemini 3.6 Flash (Medium)"
    "Gemini 3.6 Flash (Low)"
    "Gemini 3.5 Flash (High)"
    "Gemini 3.5 Flash (Medium)"
    "Gemini 3.5 Flash (Low)"
    "Gemini 3.1 Pro (High)"
    "Gemini 3.1 Pro (Low)"
    "Claude Sonnet 4.6 (Thinking)"
    "Claude Opus 4.6 (Thinking)"
    "GPT-OSS 120B (Medium)"
  )

  echo "Available Models:"
  echo ""
  local i=1
  for m in "${MODEL_NAMES[@]}"; do
    echo "  $i) $m"
    i=$((i + 1))
  done
  echo "  0) Cancel"
  echo ""
  read -rp "Select model [0-${#MODEL_NAMES[@]}]: " CHOICE

  if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#MODEL_NAMES[@]}" ]; then
    local SELECTED_MODEL="${MODEL_NAMES[$((CHOICE - 1))]}"
    
    # Ensure settings file exists
    if [ ! -f "${SETTINGS_FILE}" ]; then
      apply_default_config
    else
      backup_settings
    fi

    # Update model key in settings.json
    if command -v python3 >/dev/null 2>&1; then
      python3 -c "
import json
path = '${SETTINGS_FILE}'
with open(path, 'r') as f:
    data = json.load(f)
data['model'] = '${SELECTED_MODEL}'
with open(path, 'w') as f:
    json.dump(data, f, indent=2)
"
    else
      sed -i -E 's/"model"\s*:\s*".*"/"model": "'"${SELECTED_MODEL}"'"/' "${SETTINGS_FILE}"
    fi

    echo ""
    echo -e "${GREEN}✓ Model successfully updated to:${NC} ${BOLD}${SELECTED_MODEL}${NC}"
  elif [ "$CHOICE" == "0" ]; then
    echo -e "${YELLOW}Model selection cancelled.${NC}"
  else
    echo -e "${RED}Invalid selection.${NC}"
  fi

  echo ""
  read -rp "Press Enter to return to the menu..."
}

function view_current_config() {
  print_banner
  echo -e "${BOLD}Current Configuration (${SETTINGS_FILE}):${NC}"
  echo ""
  if [ -f "${SETTINGS_FILE}" ]; then
    cat "${SETTINGS_FILE}"
  else
    echo -e "${YELLOW}No settings.json file found.${NC}"
  fi
  echo ""
  read -rp "Press Enter to return to the menu..."
}

function list_backups() {
  print_banner
  echo -e "${BOLD}Available Backups (${BACKUP_DIR}):${NC}"
  echo ""
  local COUNT=0
  for b in "${BACKUP_DIR}"/settings_*.json; do
    if [ -f "$b" ]; then
      echo "  - $(basename "$b")"
      COUNT=$((COUNT + 1))
    fi
  done
  if [ "$COUNT" -eq 0 ]; then
    echo -e "${YELLOW}No backups found.${NC}"
  fi
  echo ""
  read -rp "Press Enter to return to the menu..."
}

function restore_backup() {
  print_banner
  echo -e "${BOLD}Restore Configuration from Backup${NC}"
  echo ""
  
  local BACKUPS=()
  for b in "${BACKUP_DIR}"/settings_*.json; do
    if [ -f "$b" ]; then
      BACKUPS+=("$b")
    fi
  done

  if [ ${#BACKUPS[@]} -eq 0 ]; then
    echo -e "${YELLOW}No backups available to restore.${NC}"
    echo ""
    read -rp "Press Enter to return to the menu..."
    return
  fi

  echo "Select a backup to restore:"
  echo ""
  local i=1
  for b in "${BACKUPS[@]}"; do
    echo "  $i) $(basename "$b") ($(date -r "$b" '+%Y-%m-%d %H:%M:%S'))"
    i=$((i + 1))
  done
  echo "  0) Cancel"
  echo ""
  read -rp "Enter choice [0-${#BACKUPS[@]}]: " CHOICE

  if [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le "${#BACKUPS[@]}" ]; then
    local SELECTED="${BACKUPS[$((CHOICE - 1))]}"
    # Create safety backup of current state before restore
    backup_settings
    cp "${SELECTED}" "${SETTINGS_FILE}"
    echo ""
    echo -e "${GREEN}✓ Successfully restored configuration from:${NC} $(basename "${SELECTED}")"
  elif [ "$CHOICE" == "0" ]; then
    echo -e "${YELLOW}Restore cancelled.${NC}"
  else
    echo -e "${RED}Invalid selection.${NC}"
  fi

  echo ""
  read -rp "Press Enter to return to the menu..."
}

# Main Interactive Loop
while true; do
  print_banner
  echo -e "${BOLD}Please select an option:${NC}"
  echo ""
  echo "  1) Apply Optimized Default Settings (Gemini 3.7 Flash High, Allow All, No Telemetry)"
  echo "  2) Choose Active Model (Interactive Model Selector)"
  echo "  3) Restore Configuration from Backup"
  echo "  4) View Current Configuration"
  echo "  5) List Available Backups"
  echo "  6) Exit"
  echo ""
  read -rp "Choice [1-6]: " OPTION

  case "$OPTION" in
    1) apply_default_config ;;
    2) select_model ;;
    3) restore_backup ;;
    4) view_current_config ;;
    5) list_backups ;;
    6)
      clear
      echo "Goodbye!"
      exit 0
      ;;
    *)
      echo -e "${RED}Invalid option.${NC}"
      sleep 1
      ;;
  esac
done
