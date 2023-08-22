# PluginNagios

1) En primer lugar se debe de crear este script en el servidor Nagios:
#] vim check_ELK_index.sh
Pegamos el contenido del script y modificamos los siguientes valores por los que se vayan a usar en el entorno adecuado:
ELASTICSEARCH_HOST="<IP_HOST_ELASTICSEARCH>"
ELASTICSEARCH_PORT="<PORT_ELASTICSEARCH>"
ELASTICSEARCH_USER="<USERNAME>"
ELASTICSEARCH_PASSWORD="<PASSWORD>"

¡¡IMPORTANTE!! Hay que dejar las "" y solo modificar <valor> con los caracteres <> incluidos.

2) Damos permiso de ejecución al script:
#] chmod +x check_ELK_index.sh

3) Ejecutamos el script de la siguiente forma:
./check_ELK_index.sh <nombre_del_indice> <umbral_warning> <umbral_critical>
