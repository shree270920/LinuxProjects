# LinuxProjects

In this project, you will create a Linux system monitor using a shell script. This script will continuously track the CPU, memory, and disk usage of your system, displaying the usage percentages in real time. If the usage of any resource exceeds a preset threshold, an alert will be displayed. By completing this project, you will learn foundational Linux scripting skills while building a practical tool.

**Project Goal**: Create a shell script (system_monitor.sh) that:
1.Runs continuously.
2.Fetches current CPU, Memory, and Disk usage percentages.
3.Displays these percentages in the terminal, refreshing periodically.
4.Compares usage against predefined thresholds.
5.Prints an alert message if any threshold is exceeded.

**Core Linux Commands We'll Use**:
**while, do, done**: For the continuous loop.
**sleep**: To pause between refreshes.
**clear**: To clear the terminal screen for a clean display.
**date**: To show the current timestamp.
**vmstat**: To get CPU idle time (we'll calculate usage from this).
**free**: To get memory usage details.
**df**: To get disk usage details.
**awk, grep, sed, head, tail, sort**: For text processing to extract the specific numbers we need.
**echo**: To display information.
**if, then, fi**: For conditional logic (checking thresholds).


**STEPS TO EXECUTE**
1.Save the file (system_monitor.sh)
2.Make Executable
  ```chmod +x system_monitor.sh```
3.Run
```./system_monitor.sh```

4.Observe Your terminal will clear, and you'll see the CPU, Memory, and Disk usage percentages displayed. The display will refresh every ```SLEEP_INTERVAL``` seconds (5 seconds by default). If any usage exceeds the thresholds defined at the top of the script, an alert message will appear in the "Alerts" section.
5.Stop : : To stop the script, press ```Ctrl + C``` in the terminal where it's running.



**Explanation**:
1.** #!/bin/bash**: Shebang line, specifies the script should be executed with Bash.
2.** Configuration Section**: Variables are set for thresholds and the refresh interval. This makes it easy to adjust the script's behavior without digging through the code.
3.**while true; do ... done**: Creates an infinite loop. The script will run forever until interrupted (Ctrl+C).
4.**clear**: Clears the terminal screen before each update, giving a real-time feel.
5.**date**: Gets and formats the current timestamp for display.
6.**CPU Usage**:
  - **vmstat 1 2**: Runs vmstat capturing statistics over 1 second, twice. We use the second report (tail -1) as it reflects activity during that 1-second interval, avoiding potentially stale initial values.
  - **awk '{print $15}'**: Extracts the 15th field, which is typically the CPU idle percentage (%id).
  - **CPU_USAGE=$((100 - CPU_IDLE))**: Calculates the active CPU usage. Bash performs integer arithmetic here.
7.**Memory Usage**:
  -**free -m**: Shows memory usage in megabytes.
  -**grep '^Mem:'**: Isolates the line containing main memory statistics.
  -**awk '{print $2}' and awk '{print $7}'**: Extract the 'total' and 'available' memory fields. 'Available' memory is generally a better                          indicator of memory pressure than just 'used' vs 'free' as it accounts for buffers/cache that can be freed.
  -**MEM_USAGE=$((MEM_USED * 100 / MEM_TOTAL))**: Calculates the usage percentage using integer arithmetic. Note: MEM_USED is calculated                           first as Total - Available.
8.**Disk Usage**:
  -**df -P**: Shows disk usage in a standard POSIX format, preventing issues with long device names breaking lines.
  -**grep '^/'**: Filters for lines starting with /, typically representing mounted physical or logical volumes.
  -**grep -vE 'tmpfs|devtmpfs|loop'**: Excludes common temporary or virtual filesystems that aren't usually relevant for persistent                                               storage monitoring. You might need to adjust this based on your specific setup.
  -**awk '{ print $5 }'**: Extracts the 5th field, which is the usage percentage string (e.g., "75%").
  -**sed 's/%//g'**: Removes the "%" sign.
  -**sort -nr**: Sorts the percentages numerically (-n) in reverse order (-r), so the highest usage is first.
  -**head -n 1**: Takes only the first line, which is the highest usage percentage.
  -**if [ -z "$DISK_USAGE" ]**: Checks if the command pipeline returned an empty string (maybe no relevant disks found or an error),                                       setting usage to 0 in that case.
9.**Alerting**:
  -Simple ```if``` statements compare the obtained integer usage values (```CPU_USAGE```, ```MEM_USAGE```, ```DISK_USAGE```) with their       respective thresholds using -ge (greater than or equal to).
  -An ```ALERT_TRIGGERED``` flag is used to display a "System status normal" message if no alerts were triggered during the cycle.
10.**sleep "$SLEEP_INTERVAL"**: Pauses the script for the specified number of seconds before the loop repeats.

This script provides a solid foundation for system monitoring. You can expand it further by adding network monitoring, specific process checks, logging to a file, or sending notifications via email/messaging services.
