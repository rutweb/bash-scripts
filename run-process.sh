#!/bin/bash
#
# run-process.sh: run script and monitor
#
# Copyright (C) 2012-2013 Mohd Nawawi Mohamad Jamili <nawawi@rutweb.com>
#
# This file is distributed under the terms of the GNU General Public
# License (GPL). Copies of the GPL can be obtained from:
# http://www.gnu.org/licenses/gpl.html 
#

_PATH=$(dirname $0);
_RUNDIR="${_PATH}";
_SCRIPT="${_PATH}/process.php";
_LOCKFILE="${_RUNDIR}/process.lock";
_PHPBIN="$(type -p php-cli)";
if [ ! -x "${_PHPBIN}" ]; then
	_PHPBIN="$(type -p php)";
fi

if [ ! -d "${_RUNDIR}" ]; then
	echo "${_RUNDIR} not exist";
	exit -1;
fi

if [ ! -x "${_PHPBIN}" ]; then
	echo "php binary not found";
	exit -1;
fi

if [ ! -f "${_SCRIPT}" ]; then
	echo "process.php not found";
	exit -1;
fi

if [ -f "${_LOCKFILE}" ]; then
	_PID=$(< $_LOCKFILE);
	if [ -z "${_PID//[0-9]/}" -a -d "/proc/$_PID" ]; then
		echo "process run";
		exit -1;
	else
        echo "process terminated, overwrite lock file";
		rm -f $_LOCKFILE;
	fi
fi


trap "{ rm -f $_LOCKFILE ; exit 1; }" SIGINT SIGTERM SIGHUP SIGKILL SIGABRT EXIT;

echo $$ > $_LOCKFILE;

while true; do
	$_PHPBIN -f $_SCRIPT;
	sleep 30;
done

rm -f $_LOCKFILE;
exit 0;

