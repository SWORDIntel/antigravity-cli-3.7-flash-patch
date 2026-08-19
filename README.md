# Antigravity CLI 3.7 Flash Patch

A simple patch script for Google Antigravity CLI (`agy`) to enable Gemini 3.7 Flash—something the IDE already has and should have been in the CLI anyway.

---

## Overview

Sets up `settings.json` to enable Gemini 3.7 Flash as your active CLI model, enables permissions, creates backups before modifying anything, and provides a restore option if you need to roll back.

---

## Staged Configuration (`settings.json`)

The template configuration included in this repository:

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

> **Note**: Modify `settings.json` as you wish before running the script if you want different defaults.

---

## Usage

### Run the Script
```bash
chmod +x patch-config.sh
./patch-config.sh
```

### Menu Options
1. **Apply Defaults**: Enables Gemini 3.7 Flash (High), allows all commands, disables telemetry, and creates an automatic backup.
2. **Choose Model**: Pick between available Gemini 3.7 Flash tiers or other models.
3. **Restore Backup**: Roll back to a previous `settings.json`.
4. **View Config**: Print your current active configuration.
5. **List Backups**: List saved backups.
6. **Exit**.

---

## Verification

Check that Gemini 3.7 Flash is active:

```bash
agy models
```

---

## License & Disclaimer

I quite truly couldn't care less. It's a bash script to add a missing feature for a program I didn't write. If you manage to cause an international incident with one of my tools AGAIN, I am not responsible.
