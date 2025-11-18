#!/bin/bash
# Nagios plugin to check Docker container status

CONTAINER_NAME=$1

if [ -z "$CONTAINER_NAME" ]; then
    echo "UNKNOWN - Container name not specified"
    exit 3
fi

# Check if docker is running
if ! command -v docker &> /dev/null; then
    echo "CRITICAL - Docker command not found"
    exit 2
fi

# Check if container exists
if ! docker ps -a --format "{{.Names}}" | grep -q "^${CONTAINER_NAME}$"; then
    echo "CRITICAL - Container ${CONTAINER_NAME} does not exist"
    exit 2
fi

# Check container status
STATUS=$(docker inspect -f "{{.State.Status}}" "$CONTAINER_NAME" 2>/dev/null)

if [ "$STATUS" = "running" ]; then
    # Get container uptime
    STARTED=$(docker inspect -f "{{.State.StartedAt}}" "$CONTAINER_NAME")
    echo "OK - Container ${CONTAINER_NAME} is running (Started: ${STARTED})"
    exit 0
elif [ "$STATUS" = "exited" ]; then
    EXIT_CODE=$(docker inspect -f "{{.State.ExitCode}}" "$CONTAINER_NAME")
    echo "CRITICAL - Container ${CONTAINER_NAME} exited with code ${EXIT_CODE}"
    exit 2
else
    echo "WARNING - Container ${CONTAINER_NAME} status: ${STATUS}"
    exit 1
fi
