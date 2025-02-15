#!/usr/bin/env bash


# Version: 1.1
# Date: 2024-08-26
# Creator: Richie C
# Description: This script will leverage pontop command on the WAS-110 and pull out the interface stats then allow prometheus to consume it for reporting
# Changelog:
# 1.0: Initial version
# 1.1: Added log output

TEXTFILE_DIR=/var/tmp/node_exporter
WAS_IP="192.168.11.1"
WAS_USER="root"
WAS_CMD="/usr/sbin/ethtool -m pon0"
LOG_FILE="/var/log/was-110-stats.log"

echo "$(date '+%Y-%m-%d %H:%M:%S'): Starting was-110-stats collecting" > $LOG_FILE

RAW_STATS=$(/usr/local/bin/ssh $WAS_USER@$WAS_IP "$WAS_CMD")
IFS=$'\n' read -r -d '' -a file_array <<< "$RAW_STATS"
for file in "${file_array[@]}"; do
    #echo "$file"
    if [[ $file =~ [[:space:]]*Module[[:space:]]temperature[[:space:]]*:[[:space:]]([0-9]+\.[0-9]+)[[:space:]]*degrees[[:space:]]*C ]]; then
    	temperature="${BASH_REMATCH[1]}"
    fi
    if [[ $file =~ [[:space:]]*Module[[:space:]]voltage[[:space:]]*:[[:space:]]([0-9]+\.[0-9]+)[[:space:]]*V ]]; then
    	voltage="${BASH_REMATCH[1]}"
    fi
    if [[ $file =~ [[:space:]]*Laser[[:space:]]bias[[:space:]]current[[:space:]]*:[[:space:]]([0-9]+\.[0-9]+)[[:space:]]*mA ]]; then
    	tx_bias_current="${BASH_REMATCH[1]}"
    fi
    if [[ $file =~ [[:space:]]Laser[[:space:]]output[[:space:]]power[[:space:]]*:[[:space:]]*([0-9]+\.[0-9]+)[[:space:]]*mW ]]; then
    	tx_power_mw="${BASH_REMATCH[1]}"
    fi
    if [[ $file =~ [[:space:]]Laser[[:space:]]output[[:space:]]power[[:space:]]*:[[:space:]]*.*/[[:space:]]([0-9]+\.[0-9]+)[[:space:]]*dBm ]]; then
    	tx_power_dbm="${BASH_REMATCH[1]}"
    fi
    if [[ $file =~ [[:space:]]Receiver[[:space:]]signal[[:space:]]average[[:space:]]optical[[:space:]]power[[:space:]]*:[[:space:]]*([0-9]+\.[0-9]+)[[:space:]]*mW ]]; then
    	rx_power_mw="${BASH_REMATCH[1]}"
    fi
    if [[ $file =~ [[:space:]]Receiver[[:space:]]signal[[:space:]]average[[:space:]]optical[[:space:]]power[[:space:]]*:[[:space:]]*.*/[[:space:]](-?[0-9]+\.[0-9]+)[[:space:]]*dBm ]]; then
    	rx_power_dbm="${BASH_REMATCH[1]}"
    fi
done


echo "$(date '+%Y-%m-%d %H:%M:%S'): Temperature: $temperature" >> $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S'): Voltage: $voltage" >> $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S'): TX Bias Current: $tx_bias_current" >> $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S'): TX Power dBm: $tx_power_dbm" >> $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S'): TX Power mW: $tx_power_mw" >> $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S'): RX Power dBm: $rx_power_dbm" >> $LOG_FILE
echo "$(date '+%Y-%m-%d %H:%M:%S'): RX Power mW: $rx_power_mw" >> $LOG_FILE

echo "$(date '+%Y-%m-%d %H:%M:%S'): Writing the Prometheus textfile output now..." >> $LOG_FILE
cat << EOF > "$TEXTFILE_DIR/was-110-stats.prom.$$"
# HELP was_110_temperature_in_c Last temperature of the module in celsius.
# TYPE was_110_temperature_in_c gauge
was_110_temperature_in_c $temperature
# HELP was_110_voltage Last voltage of the module in voltage.
# TYPE was_110_voltage gauge
was_110_voltage $voltage
# HELP was_110_tx_bias_current Last transmit current of the module in milliamps.
# TYPE was_110_tx_bias_current gauge
was_110_tx_bias_current $tx_bias_current
# HELP was_110_tx_power_mw Last transmit power of the module in milliwatts.
# TYPE was_110_tx_power_mw gauge
was_110_tx_power_mw $tx_power_mw
# HELP was_110_tx_power_dbm Last transmit power of the module in decibel-milliwatts.
# TYPE was_110_tx_power_dbm gauge
was_110_tx_power_dbm $tx_power_dbm
# HELP was_110_rx_power_mw Last receive power of the module in milliwatts.
# TYPE was_110_rx_power_mw gauge
was_110_rx_power_mw $rx_power_mw
# HELP was_110_rx_power_dbm Last receive power of the module in decibel-milliwatts.
# TYPE was_110_rx_power_dbm gauge
was_110_rx_power_dbm $rx_power_dbm
EOF

# Rename the temporary file atomically.
# This avoids the node exporter seeing half a file.
echo "$(date '+%Y-%m-%d %H:%M:%S'): Moving the Prometheus textfile output now" >> $LOG_FILE
/bin/mv "$TEXTFILE_DIR/was-110-stats.prom.$$" "$TEXTFILE_DIR/was-110-stats.prom"
echo "$(date '+%Y-%m-%d %H:%M:%S'): Finished was-110-stats collecting" >> $LOG_FILE
