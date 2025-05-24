#!/bin/bash

echo "[INFO] Starting MeshCentral agent forensic cleanup..."

# 1. Detect running Mesh-like agents (with binary path)
echo "[INFO] Detecting running Mesh agent binaries..."
AGENTS=$(ps -eo pid,args | grep -iE 'meshagent|agentcore|meshServiceName' | grep -v grep)

echo "$AGENTS" | while read -r LINE; do
  # Skip empty or invalid lines
  [[ -z "$LINE" ]] && continue

  PID=$(echo "$LINE" | awk '{print $1}')
  CMD=$(echo "$LINE" | cut -d' ' -f2-)

  # Skip if PID or CMD is empty
  [[ -z "$PID" || -z "$CMD" ]] && continue

  echo "[INFO] Found process: PID=$PID"
  
  EXE_PATH=$(readlink -f "/proc/$PID/exe" 2>/dev/null)
  [[ -z "$EXE_PATH" ]] && EXE_PATH=$(echo "$CMD" | awk '{print $1}')

  echo "[INFO] Killing $PID ($EXE_PATH)"
  kill -9 "$PID" 2>/dev/null

  AGENT_DIR=$(dirname "$EXE_PATH")
  if [[ "$AGENT_DIR" == *mesh* && -d "$AGENT_DIR" ]]; then
    echo "[INFO] Removing agent directory: $AGENT_DIR"
    rm -rf "$AGENT_DIR"
  fi
done

# 2. Find and remove all systemd service files referencing Mesh
echo "[INFO] Scanning for Mesh-related systemd services..."
find /etc/systemd/system -type f -name "*.service" | while read -r service; do
  if grep -qiE 'meshagent|agentcore|meshcentral|meshServiceName' "$service"; then
    SERVICE_NAME=$(basename "$service")
    echo "[INFO] Stopping and removing systemd service: $SERVICE_NAME"
    systemctl stop "$SERVICE_NAME" 2>/dev/null
    systemctl disable "$SERVICE_NAME" 2>/dev/null
    rm -f "$service"
  fi
done

# 3. Reload systemd to finalize cleanup
echo "[INFO] Reloading systemd..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl reset-failed

# 4. Final check for anything suspicious
echo "[INFO] Final check for any Mesh-related processes..."
ps aux | grep -i mesh | grep -v grep

echo "[✅ DONE] MeshCentral agent(s) and services cleaned up."
