#!/bin/bash

# Download data
/bin/bash /usr/local/bin/download_data.sh

source /etc/firebird/3.0/SYSDBA.password

sed -i -e '/RemoteBindAddress =/ s/= .*/= /' /etc/firebird/3.0/firebird.conf
echo "${FIREBIRD_DATABASE} = /var/lib/firebird/3.0/data/${FIREBIRD_DATABASE}.fdb" >> /etc/firebird/3.0/databases.conf

DB_DIR=/var/lib/firebird/3.0/data
INIT_DIR=/etc/firebird/3.0/init
mkdir -p ${DB_DIR}

TABLE_NAMES=(
    "BESTERL"
    "BEST"
    "BESTPOS"
    "LIEFRANT"
    "LIEFRANTERL"
    "REWAKON"
    "REWAKONERL"
    "REWAKONPOS"
    "REWAKONPROTOKOLL"
    "WAEIN"
    "WAEINERL"
    "WAEINPOS"
    "WAEINPOSP"
    "CUSTOMER"
    "FIRMA"
    "WANEBKOS"
    "WANEBKOSDEL"
    "REWAKONABWMWST"
    "ARTIKEL"
    "NEBENKOS"
    "PEINHEIT"
    "EINHEIT"
)

SQLDUMP_FILES=(
    "db_create_tables.sql"
    "db_create_index.sql"
    "db_auth.sql"
)

sed -i -e "s/SUB_TYPE BLR/SUB_TYPE BINARY/g" ${INIT_DIR}/db_meta.sql
echo ${TABLE_NAMES[*]} | xargs -n 1 | xargs -I{} awk '/CREATE TABLE {} \(/,/^$/' ${INIT_DIR}/db_meta.sql >> ${INIT_DIR}/db_create_tables.sql
echo ${TABLE_NAMES[*]} | xargs -n 1 | xargs -I{} awk '/CREATE INDEX [^ ]+ ON {} /' ${INIT_DIR}/db_meta.sql >> ${INIT_DIR}/db_create_index.sql



if [ ! -f "${DB_DIR}/${FIREBIRD_DATABASE}.fdb" ]; then

    cat ${INIT_DIR}/db_create.sql | isql-fb
    for filename in ${SQLDUMP_FILES[@]}; do
        isql-fb -i ${INIT_DIR}/${filename} "${DB_DIR}/${FIREBIRD_DATABASE}.fdb"
    done

    for tablename in ${TABLE_NAMES[@]}; do
        fbexport -I -A WIN1252 -V ${tablename} -D "${DB_DIR}/${FIREBIRD_DATABASE}.fdb" -H "" -U "machine" -P ${FIREBIRD_DATABASE} -F "${VOLUME}/tmp/${tablename}.fbx" -R  && \
        rm -f "${VOLUME}/tmp/${tablename}.fbx"
    done
    touch "${DBPATH}/${FIREBIRD_DATABASE}.init"
fi

exec /usr/sbin/fbguard