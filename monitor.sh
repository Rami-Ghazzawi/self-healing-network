#!/bin/bash

# =========================================
# Docker Container Monitor Script
# Monitors a container and restarts if it stops or becomes unhealthy
# =========================================

# ==== Configuration ==== #
CONTAINER_NAME="nova-nginx"
TIME_INTERVAL=4         # Check every 4 seconds
LOGS_FILE="container_monitoring.log"
WEB_PORT=8080

echo "Monitoring started for container: $CONTAINER_NAME ..."

# ==== Functions ==== #
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - INFO: $1" | tee -a $LOGS_FILE
}

log_warning() {
    echo -e "\a$(date '+%Y-%m-%d %H:%M:%S') - WARNING: $1" | tee -a $LOGS_FILE
}

check_container() {
    if ! docker ps | grep -q "$CONTAINER_NAME"; then
        log_warning "$CONTAINER_NAME is down! Starting..."
        docker start "$CONTAINER_NAME"
    else
        log_info "$CONTAINER_NAME is running."
    fi
}

check_health() {
    if curl -s "http://localhost:$WEB_PORT" > /dev/null; then
        log_info "$CONTAINER_NAME Server is healthy."
    else
        log_warning "$CONTAINER_NAME Server is unhealthy! Restarting..."
        docker restart "$CONTAINER_NAME"
    fi
}

# ==== Main Loop ==== #
while true; do
    check_container
    check_health
    sleep $TIME_INTERVAL
done