#!/bin/bash
# smb-idle.sh: terminate client connection if time connect more than 10 minutes
# nawawi@rutweb.com

idle="10 minutes";
_scan() {
    local line=0 f="" pid="" dt="";
    /usr/bin/smbstatus -S |while read f; do
        [ -z "${f}" ] && continue;
        (( line++ ));
        (( $line < 3 )) && continue;
        nt="$(date -d "-${idle}" "+%s")";
        pid="$(echo $f | awk '{print $2}')";
        dt="$(echo $f | cut -d ' ' -f 4-)";
        dtn="$(date -d "$dt" "+%s")";
        if (( $nt >= $dtn )); then
            if [ -r /proc/$pid ]; then
                #echo "$(date "+%d/%m/%Y %H:%M:%S") >= $(date -d "$dt" "+%d/%m/%Y %H:%M:%S")";
                kill -TERM $pid;
                if [ $? = 0 ]; then
                    echo "${pid} killed";
                fi
            fi
        fi
    done

}

_scan;

exit 0;
