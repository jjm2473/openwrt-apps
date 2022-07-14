#!/bin/bash

# disable job control, make subprocesses in same process group
set +m

TASK_ID="$1"
TASK_CMD="$2"

onexit() {
    /etc/init.d/tasks _task_onstop $TASK_ID
}

trap "onexit; trap - SIGTERM && kill -- -$$" EXIT

exec </dev/null >>"/var/log/tasks/$TASK_ID.log" 2>&1

export HOME=/root
export TERM=xterm-256color

script -efqc "stty cols 80 rows 24 ; $TASK_CMD" /dev/null
RET=$?

trap - EXIT
onexit

exit $RET
