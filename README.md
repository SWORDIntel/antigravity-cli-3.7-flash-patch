# Antigravity CLI Configuration Manager (TUI)

An interactive terminal user interface (TUI) utility for **Google Antigravity CLI (`agy`)** to manage settings, enable **Gemini 3.7 Flash (High)**, switch models interactively, configure permissions, and safely handle backups and restores.

---

## Overview

This utility simplifies configuring the Antigravity CLI environment with production-ready defaults:
- Sets the default model to **`Gemini 3.7 Flash (High)`** or lets you select any supported model interactively.
- Enables non-workspace access (`"allowNonWorkspaceAccess": true`).
- Disables telemetry reporting (`"enableTelemetry": false`).
- Grants broad command execution permission (`"command(*)"`).
- Sets the local user home directory as a trusted workspace.
- **Safety First**: Automatically creates timestamped backups before applying modifications.
- **Full Rollback Support**: Provides a built-in interactive menu option to restore any previous backup.

---

## Staged Configuration (`settings.json`)

The baseline template configuration included in this repository:

```json
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
    "/home/user"
  ]
}
```

> **Customization Note**: Modify `settings.json` as you wish before running the script if you want different defaults for your environment.

---

## Usage

### 1. Launch the Interactive TUI
```bash
chmod +x patch-config.sh
./patch-config.sh
```

### 2. Available Menu Options
- **Option 1**: Apply default configuration (Gemini 3.7 Flash High, Allow All, No Telemetry) with automatic backup.
- **Option 2**: Choose Active Model (interactive selection menu for Gemini 3.7 Flash tiers, Claude, etc.).
- **Option 3**: Restore previous configuration from timestamped backups.
- **Option 4**: View current live configuration.
- **Option 5**: List all saved backups stored in `~/.gemini/antigravity-cli/backups/`.
- **Option 6**: Exit.

---

## Verification

To verify that the configuration has taken effect:

```bash
agy models
```

The output will confirm your active model and show all registered models.

---

## License & Disclaimer

I quite truly couldn't care less. It's a bash script to add a missing feature for a program I didn't write. If you manage to cause an international incident with one of my tools AGAIN, I am not responsible.
