#!/bin/bash

#Configurations
CPU_THRESHOLD=80
MEM_THRESHOLD=85
DISK_THRESHOLD=90
SLEEP_INTERVAL=5 #Refresh Interval

#Main Loop
while true; do

	#---clear the screen for clean display
	clear

	#---Get Current Timestamp

	TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
	echo "---System Monitor--- [${TIMESTAMP}] ---"
	echo ""

	#---1.CPU Usage
	# Using vmstat: Get the idle CPU percentage from the second line of output (first is header, second is current)
	  # The 15th column is usually the idle percentage (%id)
	    # We run vmstat for 1 second, 2 times, take the last line to get a recent sample

	    CPU_IDLE=$(vmstat 1 2 | tail -1 | awk '{print $15}')

	 #Calculate CPU Usage percentage(100 - idle)
	 CPU_USAGE=$((100 - CPU_IDLE))
	 echo "CPU Usage : ${CPU_USAGE}%"


	 #---2. Memory Usage
	 # Using free -m (megabytes) for easier calculations
	   # Get the 'Mem:' line, extract total and available memory

	   MEM_INFO=$(free -m | grep '^Mem:')
	   MEM_TOTAL=$(echo "$MEM_INFO" | awk '{print $2}')
	   MEM_AVAILABLE=$(echo "$MEM_INFO" | awk '{print $7}')

	    # Calculate Memory Usage percentage: ( (Total - Available) / Total ) * 100
	      # Use integer arithmetic (scale numerator by 100 first)
	      MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))
	      MEM_USAGE=$((MEM_USED * 100 / MEM_TOTAL))
	      echo "Memory Usage: ${MEM_USAGE}%"

	   # --- 3. Disk Usage ---
	     # Using df -P (POSIX format) to avoid issues with line wrapping
	       # Filter for mounted filesystems starting with '/' (common disk partitions)
	         # Exclude temporary filesystems like tmpfs, devtmpfs, loop devices etc.
		   # Get the usage percentage (5th column), remove '%', sort numerically, take the highest.

		   DISK_USAGE=$(df -P | grep '^/' | grep -vE 'tmpfs|devtmpfs|loop' | awk '{print $5 }' | sed 's/%//g' sort -nr | head -n 1)
		   #Check if DISK_USAGE is empty 

		   if [ -z "$DISK_USAGE" ]; then
			   DISK_USAGE=0
		   fi
		   echo "Disk Usage : ${DISK_USAGE}%(highest)"
		   echo ""


	    #--- 4. Alerting
	    echo "--- Alerts (Thresholds : CPU>${CPU_THRESHOLD}% MEM>${MEM_THRESHOLD}% DISK>${DISK_THRESHOLD}%) ---"
	    ALERT_TRIGGERED=0

	    if [ "$CPU_USAGE" -ge "$CPU_THRESHOLD" ]; then
		    echo "ALERT:High CPU Usage Detected! (${CPU_USAGE}%)"

		    ALERT_TRIGGERED=1
 	    fi
	    if [ "$DISK_USAGE" -ge "$DISK_THRESHOLD" ]; then
		    echo "ALERT: High Disk Usage Detected! (${DISK_USAGE}%)"
		    ALERT_TRIGGERED=1
	    fi
	    if [ "$ALERT_TRIGGERED" -eq 0 ]; then
		    echo "System status normal."
	    fi
	    echo "--------------------------------------------------------------------"

	     # --- Wait before next refresh ---
	     sleep "$SLEEP_INTERVAL"
     done


