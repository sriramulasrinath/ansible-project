#!/bin/bash

# Define output file location
OUTPUT_FILE="/var/www/html/system_info.txt"

# Gather Disk Usage
DISK_USAGE=$(df -h | awk '$NF=="/" {print $5}')
echo "Disk Usage: $DISK_USAGE" > $OUTPUT_FILE

# Gather Memory Usage
RAM_TOTAL=$(free -m | awk '/^Mem:/ {print $2}')
RAM_USED=$(free -m | awk '/^Mem:/ {print $3}')
RAM_USAGE=$(echo "scale=2; $RAM_USED / $RAM_TOTAL * 100" | bc)
echo "Memory Usage: ${RAM_USED}MB used out of ${RAM_TOTAL}MB (${RAM_USAGE}%)" >> $OUTPUT_FILE

# Gather CPU Usage
CPU_IDLE=$(top -bn1 | grep 'Cpu(s)' | awk '{print $8}')
CPU_USAGE=$(echo "scale=2; 100 - $CPU_IDLE" | bc)
echo "CPU Usage: ${CPU_USAGE}%" >> $OUTPUT_FILE

# Print result to the console (optional)
cat $OUTPUT_FILE
