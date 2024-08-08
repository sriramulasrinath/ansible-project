#!/bin/bash

# Disk Usage
DISK_USAGE=$(df -hT | grep xfs)
DISK_THRESHOLD=10
DISK_MESSAGE=""
while IFS= read -r line
do
    USAGE=$(echo $line | awk -F " " '{print $6}' | cut -d "%" -f1)
    FOLDER=$(echo $line | awk -F " " '{print $NF}')
    if [ $USAGE -ge $DISK_THRESHOLD ]
    then 
        DISK_MESSAGE+="$FOLDER is more than $DISK_THRESHOLD%, current usage: $USAGE%\n"
    fi
done <<< "$DISK_USAGE"

# Memory Usage
MEMORY_USAGE=$(free -mt | grep Total:)
MEMORY_THRESHOLD=300
MEMORY_MESSAGE=""
while IFS= read -r line
do
    USAGE=$(echo $line | awk '{print $4}')
    if [ $USAGE -ge $MEMORY_THRESHOLD ]
    then
        MEMORY_MESSAGE+="Memory usage is more than $MEMORY_THRESHOLD MB, current usage: $USAGE MB\n"
    else
        MEMORY_MESSAGE+="Memory usage is within limits, current usage: $USAGE MB\n"
    fi
done <<< "$MEMORY_USAGE"

# CPU Usage
CPU_USAGE=$(top -bn1 | grep 'Cpu(s)' | awk '{print $2 + $4}')
CPU_THRESHOLD=80
CPU_MESSAGE=""
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    CPU_MESSAGE="CPU Usage is more than $CPU_THRESHOLD%, current usage: $CPU_USAGE%\n"
else
    CPU_MESSAGE="CPU usage is within limits, current usage: $CPU_USAGE%\n"
fi

# Save metrics to a file
echo -e "CPU Usage: $CPU_USAGE%\nRAM Usage: $USAGE MB\nDisk Usage: $DISK_MESSAGE" > /var/www/html/system_info.txt

# Send alerts
EMAIL="admin@example.com"
if [ ! -z "$DISK_MESSAGE" ]; then
    echo -e "Disk Usage Alert:\n$DISK_MESSAGE" | mail -s "Disk Usage Alert" $EMAIL
fi

if [ ! -z "$MEMORY_MESSAGE" ]; then
    echo -e "Memory Usage Alert:\n$MEMORY_MESSAGE" | mail -s "Memory Usage Alert" $EMAIL
fi

if [ ! -z "$CPU_MESSAGE" ]; then
    echo -e "CPU Usage Alert:\n$CPU_MESSAGE" | mail -s "CPU Usage Alert" $EMAIL
fi
