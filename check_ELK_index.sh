#!/bin/bash

# Definimos la configuración del acceso a ELK para obtener información
ELASTICSEARCH_HOST="<IP_HOST_ELASTICSEARCH>"
ELASTICSEARCH_PORT="<PORT_ELASTICSEARCH>"
ELASTICSEARCH_USER="<USERNAME>"
ELASTICSEARCH_PASSWORD="<PASSWORD>"

# Verificar si se proporcionan los argumentos requeridos
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
  echo "Usage: $0 <index_name> <warning_threshold_gb> <critical_threshold_gb>"
  exit 3  # Código de salida para Nagios: Unknown
fi

# Leer los argumentos proporcionados
INDEX_NAME="$1"
WARNING_THRESHOLD_GB="$2"
CRITICAL_THRESHOLD_GB="$3"

# Obtener información de los índices de Elasticsearch
response=$(curl -s -u "${ELASTICSEARCH_USER}:${ELASTICSEARCH_PASSWORD}" "http://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_cat/indices" 2>/dev/null)

# Iterar sobre la información de los índices
while IFS= read -r index_info; do
    index_size=$(echo "$index_info" | awk '{ print $9 }')
    index_name=$(echo "$index_info" | awk '{ print $3 }')
    index_size_gb=$(awk "BEGIN { printf \"%.2f\", $index_size / 1024 / 1024 / 1024 }")
    
    # Verificar si el índice actual coincide con el índice proporcionado
    if [ "$index_name" == "$INDEX_NAME" ]; then
    # Comprobar si el tamaño del índice supera el umbral de CRITICAL
        if (( $(awk "BEGIN { print ($index_size_gb >= $CRITICAL_THRESHOLD_GB) }") )); then
            echo "CRITICAL - El indice ${index_name} tiene el tamaño de ${index_size_gb} GB"
            exit 2 # Código de salida para Nagios: Critical
        # Comprobar si el tamaño del índice supera el umbral de WARNING
        elif (( $(awk "BEGIN { print ($index_size_gb >= $WARNING_THRESHOLD_GB) }") )); then
            echo "WARNING - El indice ${index_name} tiene el tamaño de ${index_size_gb} GB"
            exit 1 # Código de salida para Nagios: Warning
        fi
    fi
done <<< "$response"

# Si el indice no superó ningún umbral, se considera dentro de los límites
echo "OK - El tamaño del indice ${INDEX_NAME} esta dentro de los umbrales definidos."
exit 0 # Código de salida para Nagios: OK
