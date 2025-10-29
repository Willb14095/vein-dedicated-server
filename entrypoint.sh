#!/bin/bash
set -e

CONFIG_DIR="/home/steam/vein-dedicated-server/Vein/Saved/Config/LinuxServer"
mkdir -p "$CONFIG_DIR"

# === Game.ini (basic settings) ===
cat > "$CONFIG_DIR/Game.ini" << EOF
[/Script/Engine.GameSession]
MaxPlayers=${VEIN_MAX_PLAYERS:-16}

[/Script/Vein.VeinGameSession]
ServerName="${VEIN_SERVER_NAME:-Vein Docker Server}"
ServerDescription="${VEIN_SERVER_DESCRIPTION:-}"
SuperAdminSteamIDs=${SUPER_ADMIN_STEAM_IDS:-}
AdminSteamIDs=${ADMIN_STEAM_IDS:-}

[OnlineSubsystemSteam]
GameServerQueryPort=${QUERY_PORT:-27015}

[URL]
Port=${GAME_PORT:-7777}
EOF

# === Engine.ini (all VEIN_* → vein.*) ===
cat > "$CONFIG_DIR/Engine.ini" << 'EOF'
[ConsoleVariables]
EOF

# Helper: add line if var exists
add_cvar() {
  local key="$1"
  local value="$2"
  [[ -n "$value" ]] && echo "$key=$value" >> "$CONFIG_DIR/Engine.ini"
}

# Core
add_cvar "vein.ServerName" "\"${VEIN_SERVER_NAME:-Vein Docker Server}\""
add_cvar "vein.ServerDescription" "\"${VEIN_SERVER_DESCRIPTION:-}\""
add_cvar "vein.ServerPassword" "\"${VEIN_PASSWORD:-}\""
add_cvar "vein.MaxPlayers" "${VEIN_MAX_PLAYERS:-16}"
add_cvar "vein.PvP" "$( [[ ${VEIN_PVP:-true} == true ]] && echo 1 || echo 0 )"
add_cvar "vein.Time.TimeMultiplier" "${VEIN_TIME_MULTIPLIER:-16.0}"
add_cvar "vein.Time.NightTimeMultiplier" "${VEIN_NIGHTTIME_MULTIPLIER:-3.0}"
add_cvar "vein.Time.ContinueWithNoPlayers" "${VEIN_TIME_WITH_NO_PLAYERS:-0.0}"
add_cvar "vein.Scarcity.Difficulty" "${VEIN_SCARCITY_DIFFICULTY:-2.0}"
add_cvar "vein.BuildStructure.DecayIntervalHours" "${VEIN_BUILD_STRUCTURE_DECAY:-4.0}"
add_cvar "vein.UtilityCabinet.Interval" "${VEIN_UTILITY_CABINET_INTERVAL:-4.0}"

# Zombies
add_cvar "vein.Zombies.Health" "${VEIN_ZOMBIE_HEALTH:-40.0}"
add_cvar "vein.AISpawner.Hordes.Enabled" "$( [[ ${VEIN_HORDES:-true} == true ]] && echo 1 || echo 0 )"
add_cvar "vein.Zombies.CanClimb" "$( [[ ${VEIN_ZOMBIES_CAN_CLIMB:-true} == true ]] && echo 1 || echo 0 )"
add_cvar "vein.Zombies.HeadshotOnly" "$( [[ ${VEIN_ZOMBIES_HEADSHOTONLY:-false} == true ]] && echo 1 || echo 0 )"
add_cvar "vein.ZombieInfectionChance" "${VEIN_ZOMBIE_INFECTION_CHANCE:-0.01}"
add_cvar "vein.AISpawner.SpawnCapMultiplierZombie" "${VEIN_ZOMBIE_SPAWN_COUNT_MULTIPLIER:-1.0}"

# Misc
add_cvar "vein.PersistentCorpses" "$( [[ ${VEIN_PERSISTENT_CORPSES:-true} == true ]] && echo 1 || echo 0 )"
add_cvar "vein.ShowScoreboardBadges" "${VEIN_SHOW_SCOREBOARD_BADGES:-1.0}"

# === Start server ===
exec /home/steam/steamcmd/steamcmd.sh +login anonymous +app_update 2131400 validate +quit
exec /home/steam/vein-dedicated-server/VeinServer.sh \
  -Port=${GAME_PORT:-7777} \
  -QueryPort=${QUERY_PORT:-27015} \
  -log
