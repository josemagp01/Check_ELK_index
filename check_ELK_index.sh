#!/bin/bash

ELASTICSEARCH_HOST="<IP_HOST_ELASTICSEARCH>"
ELASTICSEARCH_PORT="<PORT_ELASTICSEARCH>"
ELASTICSEARCH_USER="<USERNAME>"
ELASTICSEARCH_PASSWORD="<PASSWORD>"

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <index_name> <warning_threshold_gb> <critical_threshold_gb>"
  exit 3  # Código de salida para Nagios: Unknown
fi

INDEX_NAME="$1"
WARNING_THRESHOLD_GB="$2"
CRITICAL_THRESHOLD_GB="$3"

response=$(curl -s -u "${ELASTICSEARCH_USER}:${ELASTICSEARCH_PASSWORD}" "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_cat/indices" 2>/dev/null)

while IFS= read -r index_info; do
    index_size=$(echo "$index_info" | awk '{ print $9 }')
    index_name=$(echo "$index_info" | awk '{ print $3 }')
    index_size_gb=$(awk "BEGIN { printf \"%.2f\", $index_size / 1024 / 1024 / 1024 }")

    if [ "$index_name" == "$INDEX_NAME" ]; then
        if (( $(awk "BEGIN { print ($index_size_gb >= $CRITICAL_THRESHOLD_GB) }") )); then
            echo "CRITICAL - Index ${index_name} size is ${index_size_gb} GB"
            exit 2
        elif (( $(awk "BEGIN { print ($index_size_gb >= $WARNING_THRESHOLD_GB) }") )); then
            echo "WARNING - Index ${index_name} size is ${index_size_gb} GB"
            exit 1
        fi
    fi
done <<< "$response"

echo "OK - Index ${INDEX_NAME} size is within thresholds."
exit 0
