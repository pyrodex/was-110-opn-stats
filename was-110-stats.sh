#!/usr/bin/env bash


# Version: 1.2
# Date: 2025-09-16
# Creator: Richie C
# Description: This script will leverage pontop command on the WAS-110 and pull out the interface stats then allow prometheus to consume it for reporting
# Changelog:
# 1.0: Initial version
# 1.1: Added log output
# 1.2: Updted code to support the 2.8.2 metrics page
set -euo pipefail
PROM_FILE="/var/tmp/node_exporter/was-110-stats.prom"
WAS_IP="192.168.11.1"
WAS_URL="cgi-bin/luci/8311/metrics"
LOG_FILE="/var/log/was-110-stats.log"
timestamp() {
  date '+%Y-%m-%d %H:%M:%S'
}
echo "$(timestamp): Starting was-110-stats collecting" >"$LOG_FILE"
# Fetch and convert JSON to Prometheus text format once
if RAW_STATS=$(curl -sS -k "https://${WAS_IP}/${WAS_URL}"); then
  jq -r 'to_entries[] | "was_110_\(.key) \(.value)"' <<<"$RAW_STATS" | tee "$PROM_FILE" | while IFS= read -r line; do
    echo "$(timestamp): $line" >>"$LOG_FILE"
  done
else
  echo "$(timestamp): ERROR: Failed to fetch stats from ${WAS_IP}" >>"$LOG_FILE"
  exit 1
fi
echo "$(timestamp): Finished was-110-stats collecting" >>"$LOG_FILE"
