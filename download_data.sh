#!/bin/bash

echo "Downloading data..."

TABLE_NAMES=(
    "BEST"
    "BESTERL"
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

DB_DIR="/var/lib/firebird/3.0/data"
VOLUME="/"

if [ ! -z "${FIREBIRD_DATABASE}" -a ! -f "${DB_DIR}/${FIREBIRD_DATABASE}.init" ]; then
    mkdir -p "${VOLUME}/tmp"
    for filename in ${TABLE_NAMES[@]}; do
        echo "Downloading ${filename}" && \
        gsutil cp "gs://${FIREBIRD_DATABASE}.blp-digital.com/${filename}.fbx" "${VOLUME}/tmp/${filename}.fbx"
    done
fi

$@