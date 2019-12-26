#! /bin/bash

Tmp_List=/tmp/backup.lst
Log=/tmp/backup.log

fine /share -tye f > ${Tmp_List}

while read LINE
do

MK_DIR=`dirname $LINE`
if [ ! -d ${MK_DIR} ]; then
    mkdir -p /BKUP${MK_DIR}
fi

cp -p $LINE /BKUP${LINE}

if [ $? -eq 0 ]; then
    echo $LINE baskup is sccessed. >> $Log
else
    echo $LINE baskup is failed. >> $Log
fi

done < ${Tmp_List}

tar 

