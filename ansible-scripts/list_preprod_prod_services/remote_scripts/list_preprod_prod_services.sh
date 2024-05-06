#!/bin/bash

rm -f /tmp/result.csv
touch /tmp/result.csv
cd /data/services

HOSTNAME=$(hostname)

for SERVICE in *
do
    if [ -d "${SERVICE}" ]
    then
        cd "${SERVICE}"

        if [ -L prod ]
        then
            lien_prod=$(readlink prod)
            if [[ "${lien_prod}" == *data/services/*/** ]]
            then
                lien_prod=$(readlink prod | cut -d '/' -f5)
            fi

            if [[ "${lien_prod}" == **/* ]]
            then
                lien_prod=$(readlink prod | cut -d '/' -f1)
            fi

            echo "${SERVICE},prod,${lien_prod},${HOSTNAME}" >> /tmp/result.csv
        fi

        if [ -L pre-prod ]
        then
            lien_preprod=$(readlink pre-prod)

            if [[ "$lien_preprod" == *data/services/*/** ]]
            then
                lien_preprod=$(readlink pre-prod | cut -d '/' -f5)
            fi

            if [[ "$lien_preprod" == **/* ]]
            then
                lien_preprod=$(readlink pre-prod | cut -d '/' -f1)
            fi

            echo "${SERVICE},preprod,$lien_preprod,${HOSTNAME}" >> /tmp/result.csv
        fi

        if [ -L preprod ]
        then
            lien_preprod=$(readlink preprod)

            if [[ "$lien_preprod" == *data/services/*/** ]]
            then
                lien_preprod=$(readlink preprod | cut -d '/' -f5)
            fi

            if [[ "${lien_prod}" == **/* ]]
            then
                lien_preprod=$(readlink preprod | cut -d '/' -f1)
            fi

            echo "${SERVICE},preprod,$lien_preprod,${HOSTNAME}" >> /tmp/result.csv
        fi

        cd ..
    fi
done
