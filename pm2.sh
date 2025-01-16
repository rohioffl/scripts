#!/bin/bash

# Path to the PM2 logs directory
PM2_LOG_DIR="/root/.pm2/logs"

# CloudWatch log group name
LOG_GROUP="PROD2-PM2-Application-logs"

# CloudWatch agent config file path
CLOUDWATCH_CONFIG_FILE="/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"

# Start with an empty config file
echo '{ "logs": { "logs_collected": { "files": { "collect_list": [' > $CLOUDWATCH_CONFIG_FILE

# Flag to check if it's the first log to be added, so we don't add a comma before the first one
first_log=true

# Loop through each out log file
for log in $PM2_LOG_DIR/*-out.log; do
    # Extract the application name from the log file (without the suffix)
    app_name=$(basename "$log" -out.log)
    
    # Add out log stream configuration, avoiding trailing comma
    if [ "$first_log" = true ]; then
        first_log=false
    else
        echo "," >> $CLOUDWATCH_CONFIG_FILE
    fi

    # Log stream name should be app/out-logs
    echo "  {" >> $CLOUDWATCH_CONFIG_FILE
    echo "    \"file_path\": \"$log\"," >> $CLOUDWATCH_CONFIG_FILE
    echo "    \"log_group_name\": \"$LOG_GROUP\"," >> $CLOUDWATCH_CONFIG_FILE
    echo "    \"log_stream_name\": \"$app_name/out-logs\"," >> $CLOUDWATCH_CONFIG_FILE
    echo "    \"timestamp_format\": \"%Y-%m-%d %H:%M:%S\"," >> $CLOUDWATCH_CONFIG_FILE
    echo "    \"timezone\": \"Local\"" >> $CLOUDWATCH_CONFIG_FILE
    echo "  }" >> $CLOUDWATCH_CONFIG_FILE
done

# Loop through each error log file
for log in $PM2_LOG_DIR/*-error.log; do
    # Extract the application name from the log file (without the suffix)
    app_name=$(basename "$log" -error.log)
    
    # Add error log stream configuration, avoiding trailing comma
    if [ "$first_log" = true ]; then
        first_log=false
    else
        echo "," >> $CLOUDWATCH_CONFIG_FILE
    fi

    # Log stream name should be app/error-logs
    echo "  {" >> $CLOUDWATCH_CONFIG_FILE
    echo "    \"file_path\": \"$log\"," >> $CLOUDWATCH_CONFIG_FILE
    echo "    \"log_group_name\": \"$LOG_GROUP\"," >> $CLOUDWATCH_CONFIG_FILE
    echo "    \"log_stream_name\": \"$app_name/error-logs\"," >> $CLOUDWATCH_CONFIG_FILE
    echo "    \"timestamp_format\": \"%Y-%m-%d %H:%M:%S\"," >> $CLOUDWATCH_CONFIG_FILE
    echo "    \"timezone\": \"Local\"" >> $CLOUDWATCH_CONFIG_FILE
    echo "  }" >> $CLOUDWATCH_CONFIG_FILE
done

# Close the JSON
echo "] } } } }" >> $CLOUDWATCH_CONFIG_FILE

# Restart agaent
systemctl restart amazon-cloudwatch-agent
