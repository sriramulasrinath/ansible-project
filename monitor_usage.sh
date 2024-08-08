#!/bin/bash

EMAIL="sriramulasrinath.ss@gmail.com"
SUBJECT="System Usage Alert"

while true; do
    CPU_USAGE=$(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')
    MEMORY_USAGE=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2 }')
    DISK_USAGE=$(df -h | awk '$NF=="/"{printf "%d", $5}')
    
    THRESHOLD_EXCEEDED=false

    if (( $(echo "$CPU_USAGE > 1" | bc -l) )); then
        THRESHOLD_EXCEEDED=true
        CPU_ALERT="CPU Usage: $CPU_USAGE% (Threshold: 70%)"
    fi

    if (( $(echo "$MEMORY_USAGE > 1" | bc -l) )); then
        THRESHOLD_EXCEEDED=true
        MEMORY_ALERT="Memory Usage: $MEMORY_USAGE% (Threshold: 70%)"
    fi

    if (( $DISK_USAGE > 1 )); then
        THRESHOLD_EXCEEDED=true
        DISK_ALERT="Disk Usage: $DISK_USAGE% (Threshold: 80%)"
    fi

    if [ "$THRESHOLD_EXCEEDED" = true ]; then
        BODY="Usage has exceeded the defined threshold.\n\n"
        [ ! -z "$CPU_ALERT" ] && BODY+="$CPU_ALERT\n"
        [ ! -z "$MEMORY_ALERT" ] && BODY+="$MEMORY_ALERT\n"
        [ ! -z "$DISK_ALERT" ] && BODY+="$DISK_ALERT\n"
        
        echo -e "$BODY" | mail -s "$SUBJECT" "$EMAIL"
    fi

    sleep 1
done
