#!/bin/bash
#
# copybin.sh - Copy binary and linkable library.
#
# Copyright (C) 200?-2011 Mohd Nawawi Mohamad Jamili <nawawi@rutweb.com>
#
# This file is distributed under the terms of the GNU General Public
# License (GPL). Copies of the GPL can be obtained from:
# http://www.gnu.org/licenses/gpl.html 
#
# Changelog:
# 05/11/2011 - Enhance for suitable with general usage
#

_error() {
	local msg=$@;
	echo "[ERROR] $msg";
	exit 1;
}

_exec_echo() {
	local msg=$1;
	echo ">> $msg";
	$msg;	
}

_copy_file() {
	local _SRC="$1" _DST="$2" _DSRC _BSRC _LSRC="";

        if [ $# != 2 ]; then
                _error "${FUNCNAME}: invalid options";
        fi

	if [ ! -e "$_SRC" ]; then
		_error "${FUNCNAME}: file '${_SRC}' not found";
	fi

	_BSRC="$(basename ${_SRC})";

	[ -e "${_DST}/${_BSRC}" ] && return 1;
	
	echo "[*] ${FUNCNAME} ${_SRC} ${_DST}";

	if [ -L "${_SRC}" ]; then
		_exec_echo "cp -fa ${_SRC} ${_DST}";
		_LSRC="${_SRC}";
		_DSRC="$(dirname ${_SRC})";
		while [ -L "${_LSRC}" ]; do
			_LSRC="$(readlink ${_LSRC})";
			# check if not in fullpatch
			if [ ! -e "${_LSRC}" ] && [ -e "${_DSRC}/${_LSRC}" ]; then
				_LSRC="${_DSRC}/${_LSRC}";
			fi
			_exec_echo "cp -fa ${_LSRC} ${_DST}";
			 # strip if not symlink
			_BSRC="$(basename ${_LSRC})";
			if [ ! -L "${_DST}/${_BSRC}" ]; then
				_exec_echo "strip --strip-debug --strip-unneeded ${_DST}/${_BSRC}";
			fi
			unset _BSRC;
		done
	else
		_exec_echo "cp -fa ${_SRC} ${_DST}";
		_exec_echo "strip --strip-debug --strip-unneeded ${_DST}/${_BSRC}";		
	fi
}

_copy_lib() {
        if [ $# != 2 ]; then
                _error "${FUNCNAME}: invalid options";
        fi

        local _SRC="$1" _DST="$2" _BSRC _DSRC _LSRC="";
	local _LO _P;
        echo "[*] ${FUNCNAME} ${_SRC} ${_DST}";
	if [ ! -e "$_SRC" ]; then
		_error "${FUNCNAME}: file '${_SRC}' not found";
	fi
	
	# check in destination
	_BSRC="$(basename ${_SRC})";

	[ -e "${_DST}/${_BSRC}" ] && return 1;
	[ ! -d "${_DST}" ] && _exec_echo "mkdir -p $_DST";
	local _LO="$(_P=$(ldd ${_SRC});echo "${_P}" |tr -d '^\t' |sed -e 's/=>//g' |cut -d ' ' -f 3; echo "${_P}" |tr -d '^\t' |grep -v "=>" |cut -d ' ' -f 1)";
	if [ -n "${_LO:-}" ]; then
		unset _P;
		for _P in ${_LO}; do
			_copy_file "${_P}" "${_DST}";
		done
	fi
}

_copy_bin() {
	if [ "x$1" = "x" -a "x$2" = "x" ]; then
                _error "${FUNCNAME}: invalid options";
        fi

        local __FILE=$1;
	local __ROOT_DIR=$2;

        if [ ! -x "${__FILE}" ]; then
		_error "${FUNCNAME}: ${__FILE} not found";
	fi

	if [ ! -d "${__ROOT_DIR}" ]; then
		_error "${FUNCNAME}: ${__ROOT_DIR} not exist";
	fi

    	echo "[*] ${FUNCNAME}: ${__FILE} ${__ROOT_DIR}";

	local __DNAME=$(dirname $__FILE);
        local __BNAME=$(basename $__FILE);
        local __IBIN="$__ROOT_DIR/bin";
        local __ILIB="$__ROOT_DIR/lib";
	
	[ ! -d "$__IBIN" ] && _exec_echo "mkdir -p ${__IBIN}";
	[ ! -d "$__ILIB" ] && _exec_echo "mkdir -p ${__ILIB}";
	_exec_echo "cp -f $__FILE $__IBIN";
	if [ -f "${__IBIN}/${__BNAME}" ]; then
        	_exec_echo "chmod a-srwx ${__IBIN}/${__BNAME}";
        	_exec_echo "chmod u+rwx ${__IBIN/${__BNAME}";
        	_exec_echo "strip --strip-all ${__IBIN}/${__BNAME}";
		_copy_lib "${__FILE}" "${__ILIB}";
	else
		_error "${FUNCNAME}: ${__FILE} copy failed";
	fi
}

if [ "x$1" = "x" ] || [ "x$2" = "x" ]; then
	echo "Usage: $0 binary destdir";
	exit 1;
fi

_copy_bin "$1" "$2";
exit $?;

