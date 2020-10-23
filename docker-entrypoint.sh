#!/bin/sh
set -euo pipefail

if [ $# -eq 0 ]; then
	mkdir -p $(dirname $SSH_AUTH_SOCK)
	test -f $SSH_AUTH_SOCK && rm -f $SSH_AUTH_SOCK

	ssh-agent -a $SSH_AUTH_SOCK -D &
	socat -d -s TCP-LISTEN:2000,fork,reuseaddr UNIX-CONNECT:$SSH_AUTH_SOCK &
	sleep 1

	key="${PLUGIN_SSH_KEY:-${SSH_KEY:-}}"
	if [ -n "${key:+x}" ]; then
		SSH_KEY_FILE=$(mktemp)
		printf "$key" > $SSH_KEY_FILE
	fi
	if [ -n "${SSH_KEY_FILE:+x}" ]; then
		ssh-add $SSH_KEY_FILE
		ssh-add -l
	fi
	trap 'kill $(jobs -p)' SIGTERM
	wait
elif [ "$1" == "connect" ]; then
	SSH_AUTH_SOCK=$(mktemp)
	test -f $SSH_AUTH_SOCK && rm -f $SSH_AUTH_SOCK
	echo "Connecting to ssh-agent at $2"
	target=$2
	test [ "${target/:/}" == "$target" ] && target="$target:2000"
	socat -d -s UNIX-LISTEN:$SSH_AUTH_SOCK,fork TCP-CONNECT:$target &
	trap 'kill $(jobs -p)' SIGTERM
	shift 2
	exec $@
else
	echo $1
	exec $@
fi
