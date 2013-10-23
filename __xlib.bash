# -*-Shell-script-*-
#
# __xlib.bash - Extra function for Bash Scripting language
#
# Copyright (C) 200?-2013 Mohd Nawawi Mohamad Jamili <nawawi@rutweb.com>
#
# This file is distributed under the terms of the GNU General Public
# License (GPL). Copies of the GPL can be obtained from:
# http://www.gnu.org/licenses/gpl.html 
#
# Changelog:
# 26-Jan-2010: Added bash version checking
# 06-Dec-2011: Fork to github
#


# check if bash
[ -z "${BASH_VERSION}" ] && {
	exit 1;
}

# strlen() -- Get string length
# Usage: strlen string
#
# Example:
#
# string="saya suka makan";
# leng=$(strlen "$string");
#
# echo $leng;
#

strlen() {
	echo ${#1};
}

# is_num() -- Check if input is number
# Usage: is_num input
#
# Example:
#
# if is_num 200; then
#	echo "OK";
# fi
#

is_num() {
	[ $# -eq 1 ] || return 1;
	[[ $1 =~ ^([0-9]+)$ ]] && return 0;
	return 1;
}

# str_repeat() -- Repeat a string
# Usage: str_repeat input multiplier
# depend: is_num(): http://www.ronggeng.net/index.php/2009/04/24/is_num/
#
# Example:
#
# str_repeat "test test test" 10;
#

str_repeat() {
	[ $# -eq 2 ] || return 1;
	! is_num "$2" && return 1;
	local _cnt _ret="";
	while ((_cnt < $2 )); do
		_ret+="$1";
		((_cnt++));
        done;
	echo "$_ret";
	return 0;
}

# lcfirst() -- Make a string's first character lowercase
# Usage: lcfirst string
# depend: strtolower(): http://www.ronggeng.net/index.php/2009/04/24/strtolower/
#
# Example:
#
# lcfirst "test test test";
#

if [ -n "${BASH_VERSINFO[0]}" ] && [ ${BASH_VERSINFO[0]} -gt 3 ]; then
	# Updated: 20-Aug-2009 - for bash version 4
	lcfirst() {
		[ $# -eq 1 ] || return 1;
		echo ${1,};
		return 0;
	}
else
	lcfirst() {
		[ $# -eq 1 ] || return 1;
		! type -t strtolower &>/dev/null && return 1;
		echo "$(strtolower "${1:0:1}")${1:1:${#1}}";
		return 0;
	}
fi

# rm_str() -- Remove string/character from string
# Usage: rm_str string string
#
# Example 1:
#
# echo $(rm_str "pungkok hang" "pungkok");
#
# Example 2:
#
# string="$(rm_str "pungkok hang" "pungkok")";
# echo $string;

rm_str() {
	local _str="$1";
	local _chr="$2";
	[ -z "$_chr" ] && _chr='"';
	if [ -n "$_str" -a -n "$_chr" ]; then
		echo ${_str//$_chr};
		return 0;
	fi;
	return 1;
}

# ucwords() -- Uppercase the first character of each word in a string
# Usage: ucwords string
# depend: strtoupper(): http://www.ronggeng.net/index.php/2009/04/24/strtoupper/
#
# Example:
#
# ucwords "test test test";
#

ucwords() {
	[ $# -eq 1 ] || return 1;
	! type -t strtoupper &>/dev/null && return 1;
	local _x _c _p _ret="" _str="$1";
	_p=0;
	for ((_x=0;_x<${#_str};_x++)); do
		_c=${_str:$_x:1};
		if [ "$_c" != " " ] && [ "$_p" = "0" ]; then
			_ret+="$(strtoupper "$_c")";
			_p=1;continue;
		fi;
		[ "$_c" = " " ] && _p=0;
		_ret+="$_c";
	done;
	if [ -n "${_ret:-}" ]; then
		echo "${_ret}";
		return 0;
	fi;
	return 1;
}

# ucfirst() -- Make a string's first character uppercase
# Usage: ucfirst string
# depend: strtoupper(): http://www.ronggeng.net/index.php/2009/04/24/strtoupper/
#
# Example:
#
# ucfirst "test test test";
#

if [ -n "${BASH_VERSINFO[0]}" ] && [ ${BASH_VERSINFO[0]} -gt 3 ]; then
	# Updated: 20-Aug-2009 - for bash version 4
	ucfirst() {
		[ $# -eq 1 ] || return 1;
		echo ${1^};
		return 0;
	}
else
	ucfirst() {
		[ $# -eq 1 ] || return 1;
		! type -t strtoupper &>/dev/null && return 1;
		echo "$(strtoupper "${1:0:1}")${1:1:${#1}}";
		return 0;
	}
fi

# yesno() -- prompt user to accept yes or no
# Usage: yesno [prompt msg]
#
# Example:
#
# while ! yesno "sila taip yes"; do
#	echo "yes ditaip";
# done
#

yesno() {
	[ $# -eq 1 ] || return 1;
	local _prompt="$1";
	local _ANS="";
	read -p "${_prompt} [yes/no]: " _ANS;
	while [ "$_ANS" != "yes" ] && [ "$_ANS" != "no" ]; do
		read -p "Please enter 'yes' or 'no': " _ANS;
	done;
	[ "$_ANS" = "yes" ] && return 0;
	return 1;
}

# basename() -- Returns filename component of path
# Usage: basename filename
#
# Example 1:
#
# echo $(basename "/usr/bin/chak");
#
# Example 2:
#
# string="$(basename "/usr/bin/chak.exe" ".exe")";
# echo $string;

basename() {
	local name="${1##*/}";
	local opt="$2";
	[ -n "$opt" ] && name="${name%.$opt}";
	echo "${name%$2}";
}

# dirname() -- Returns directory name component of path
# Usage: dirname filename
#
# Example 1:
#
# echo $(dirname "/usr/bin/chak");
#
# Example 2:
#
# string="$(dirname "/usr/bin/chak")";
# echo $string;

dirname() {
	local dir="${1%${1##*/}}";
	[ "${dir:=./}" != "/" ] && dir="${dir%?}";
	echo "$dir";
}


# strstr() -- locate a substring
# Usage: strstsr string match
#
# Example 1:
#
# string="saya suka makan";
# if strstr "${string}" "suk"; then
# 	echo "OK";
# fi
#
# Example 2:
#
# buff="$(ps ax)";
# if ! strstr "${buff}" "httpd"; then
#	echo "service httpd down";
# fi

strstr() {
	[ $# -eq 2 ] || return 1;
	[ "$1" = "$2" ] || [[ "$1" = *$2* ]] && return 0;
	return 1;
}


# stristr() -- Case-insensitive strstr()
# Usage: stristsr string match
# depend: strtolower(): http://www.ronggeng.net/index.php/2009/04/24/strtolower/
#
# Example 1:
#
# string="saya SUKA Makan";
# if stristr "${string}" "suk"; then
# 	echo "OK";
# fi
#
# Example 2:
#
# buff="$(ps ax)";
# if ! stirstr "${buff}" "httpd"; then
#	echo "service httpd down";
# fi

stristr() {
	[ $# -eq 2 ] || return 1;
	! type -t strtolower &>/dev/null && return 1;
	local _str1=$(strtolower "$1");
	local _str2=$(strtolower "$2");

	[ "$_str1" = "$_str2" ] || [[ "$_str1" = *$_str2* ]] && return 0;
	return 1;
}

# strtoupper() -- — Make a string uppercase
# Usage: strtoupper string
#
# Example 1:
#
# echo $(strtoupper "saya suka makan");
#
# Example 2:
#
# string="$(strtoupper "saya sukan makan")";
# echo $string;

if [ -n "${BASH_VERSINFO[0]}" ] && [ ${BASH_VERSINFO[0]} -gt 3 ]; then
	# Updated: 20-Aug-2009 - for bash version 4
	strtoupper() {
		[ $# -eq 1 ] || return 1;
		echo ${1^^};
		return 0;
	}
else
	strtoupper() {
		[ $# -eq 1 ] || return 1;
		local _str _cu _cl _x;
		_cu=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
		_cl=(a b c d e f g h i j k l m n o p q r s t u v w x y z);
		_str=$1;
		for ((_x=0;_x<${#_cl[*]};_x++)); do
			_str=${_str//${_cl[$_x]}/${_cu[$_x]}};
		done;
		echo $_str;
		return 0;
	}
fi

# strtolower() -- — Make a string lowercase
# Usage: strtolower string
#
# Example 1:
#
# echo $(strtolower "SAYA SUKAN MAKAN");
#
# Example 2:
#
# string="$(strtolower "SAYA SUKAN MAKAN")";
# echo $string;

if [ -n "${BASH_VERSINFO[0]}" ] && [ ${BASH_VERSINFO[0]} -gt 3 ]; then
	# Updated: 20-Aug-2009 - for bash version 4
	strtolower() {
		[ $# -eq 1 ] || return 1;
		echo ${1,,};
		return 0;
	}
else
	strtolower() {
		[ $# -eq 1 ] || return 1;
		local _str _cu _cl _x;
		_cu=(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z);
		_cl=(a b c d e f g h i j k l m n o p q r s t u v w x y z);
		_str=$1;
		for ((_x=0;_x<${#_cl[*]};_x++)); do
			_str=${_str//${_cu[$_x]}/${_cl[$_x]}};
		done;
		echo $_str;
		return 0;
	}
fi


# _execq() -- Execute command and silent output
# Usage: _execq command
#
# Example:
#
# if _execq "/bin/ps auwx"; then
#	echo "ps OK";
# fi
#

_exeq() {
	local cmd=$@;
	$cmd &>/dev/null;
	return $?;
}

# __pgrepf() -- get pid match program from /proc
# Usage: __pgrepf [name]
# alternative depend: basename(): http://www.ronggeng.net/index.php/2009/04/24/basename/
# dirname(): http://www.ronggeng.net/index.php/2009/04/24/dirname/
#
# Example:
#
# if ! __pgrepf httpd; then
#      /etc/init.d/httpd restart
# fi
#

__pgrepf() {
        [ -n "$1" ] && [ -d "/proc" ] || return 1;
        local _mt="$1" _buf _f _pid _pidr="" _me=$$;
        _mt=${_mt// /};
        for _f in /proc/*/cmdline; do
                _pid=$(basename $(dirname $_f));
                ! [[ $_pid =~ ^([0-9]+)$ ]] && continue;
                (( $_pid <= 9 )) && continue;
                [ "$_pid" = "$_me" ] && continue;
                [ -e $_f ] && _buf=$(< $_f);
                [ -z "$_buf" ] && continue;
                [[ $_buf = *$_mt* ]] && _pidr+="$_pid ";
                unset _pid _buf;
        done;
        [ -n "$_pidr" ] && {
                echo "$_pidr";
                return 0;
        };
        return 1;
}

# trim() -- Strip whitespace from the beginning and end of a string
trim() {
    local str="$@";
    str="${str#"${str%%[![:space:]]*}"}";
    str="${str%"${str##*[![:space:]]}"}";
    echo -n "${str}";
}

# cat() -- cat implement in pure bash
# can handle EOF, but NULL will break it.
# original from http://eatnumber1.blogspot.com/2009/05/pure-bash-cat.html
cat() {
    local INPUTS=( "${@:-"-"}" )
    for i in "${INPUTS[@]}"; do
        # quick hack to get /proc/*/cmdline content that end by null character
        if [[ "${i}" =~ ^(/proc/[0-9]+/.*) ]] && [ -f "${i}" ]; then
            echo $(< $i );
            break;
        fi
        if [[ "${i}" != "-" ]]; then
            exec 3< "${i}" || return 1;
        else
            exec 3<&0
        fi
        while read -ru 3; do
            echo -E "${REPLY}";
        done
    done
    return 0;
}

